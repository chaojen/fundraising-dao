// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "src/plan/IActionPlan.sol";

/// @title SDGs 行動計畫
contract ActionPlan is IActionPlan, AccessControl {
    bytes32 public constant INITIATOR_ROLE = keccak256("INITIATOR_ROLE");

    /// @notice 發起人
    address public initiator;

    /// @notice 建立時間
    uint256 public createTimestamp;

    /// @notice 目標代幣
    IERC20 public targetToken;

    /// @notice 目標金額
    uint256 public goalAmount;

    /// @notice 贊助人
    address[] public sponsors;
    mapping(address => bool) public sponsorsIndices;

    /// @notice 贊助人 => 贊助金額
    mapping(address => uint256) public sponsoreds;

    /// @notice 已撥款金額
    uint256 public allocatedAmount;

    constructor(address _admin, address _initiator, address _targetToken, uint256 _goalAmount) {
        initiator = _initiator;
        createTimestamp = block.timestamp;
        targetToken = IERC20(_targetToken);
        goalAmount = _goalAmount;

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(INITIATOR_ROLE, _initiator);
    }

    /// @notice 進行贊助
    function support(uint256 _amount) external override {
        require(allocatedAmount == 0, "fundraising has ended.");

        uint256 allowance = targetToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "need more allowance to.");

        bool succeeded = targetToken.transferFrom(msg.sender, address(this), _amount);
        if (succeeded) {
            if (!sponsorsIndices[msg.sender]) {
                sponsorsIndices[msg.sender] = true;
                sponsors.push(msg.sender);
            }
            sponsoreds[msg.sender] += _amount;
            emit Support(msg.sender, _amount);
        }
    }

    /// @notice 取消贊助
    function withdrawSupport(uint256 _amount) external override {
        require(allocatedAmount == 0, "fundraising has ended.");

        uint256 sponsored = sponsoreds[msg.sender];
        require(sponsored >= _amount, "not enough sponsored amount.");

        bool succeeded = targetToken.transfer(msg.sender, _amount);
        if (succeeded) {
            sponsoreds[msg.sender] -= _amount;
            emit WithdrawSupport(msg.sender, _amount);
        }
    }

    /// @notice 撥款
    function allocate(uint256 _amount) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balanceOfPlan = totalSponsoredAmount() + allocatedAmount;
        require(balanceOfPlan >= goalAmount, "the sponsored amount must be greater than the goal amount.");

        bool succeeded = targetToken.transfer(initiator, _amount);
        if (succeeded) {
            allocatedAmount += _amount;
            emit Allocated(initiator, _amount);
        }
    }

    /// @notice 總贊助金額
    function totalSponsoredAmount() public view returns (uint256 amount) {
        return targetToken.balanceOf(address(this));
    }
}
