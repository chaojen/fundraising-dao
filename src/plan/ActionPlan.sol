// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "src/plan/ActionPlanState.sol";

/// @title 行動方案
contract ActionPlan is AccessControl {
    event Support(address from, uint256 amount);

    bytes32 public constant INITIATOR_ROLE = keccak256("INITIATOR_ROLE");

    /// @notice 平台幣
    IERC20 token;

    /// @notice 發起人
    address initiator;

    /// @notice 贊助人
    address[] sponsors;
    mapping(address => bool) sponsorsIndices;

    /// @notice 贊助金額
    mapping(address => uint256) sponsoreds;

    /// @notice 目標金額
    uint256 goalAmount;

    /// @notice 建立時間
    uint256 createTimestamp;

    /// @notice 開始接受贊助時間
    uint256 startTimestamp;

    /// @notice 接受贊助期間
    uint256 duration;

    /// @notice 已取消
    bool canceled;

    constructor(
        address _initiator,
        address _token,
        uint256 _goalAmount,
        uint256 _createTimestamp,
        uint256 _startTimestamp,
        uint256 _duration
    ) {
        initiator = _initiator;
        token = IERC20(_token);
        goalAmount = _goalAmount;
        createTimestamp = _createTimestamp;
        startTimestamp = _startTimestamp;
        duration = _duration;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(INITIATOR_ROLE, _initiator);
    }

    /// @notice 進行贊助
    function support(uint256 _amount) external {
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amount, "need more allowance to.");

        bool succeeded = token.transferFrom(msg.sender, address(this), _amount);
        if (succeeded) {
            if (!sponsorsIndices[msg.sender]) {
                sponsorsIndices[msg.sender] = true;
                sponsors.push(msg.sender);
            }
            sponsoreds[msg.sender] = sponsoreds[msg.sender] += _amount;
            emit Support(msg.sender, _amount);
        }
    }

    /// @notice 取消贊助
    function withdrawSupport() external {}

    /// @notice 方案狀態
    function state() external view returns (ActionPlanState) {}

    /// @notice 取消方案
    function cancel() external onlyRole(INITIATOR_ROLE) {}

    /// @notice 方案成功達成
    function success() external onlyRole(DEFAULT_ADMIN_ROLE) {}
}
