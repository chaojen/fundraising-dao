// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "src/IActionCenter.sol";
import "src/ActionPlan.sol";

contract ActionCenter is IActionCenter, Ownable {
    using SafeERC20 for IERC20;

    modifier interactivePlan(uint256 _planId) {
        ActionPlan storage plan = plans[_planId];
        require(plan.createTimestamp != 0, "action plan does not exist.");
        require(plan.allocatedAmount == 0, "fundraising has ended.");
        _;
    }

    mapping(uint256 => ActionPlan) public plans;

    constructor(address _owner) Ownable(_owner) {}

    /// @notice 建立新的行動計畫
    function createActionPlan(address _targetToken, uint256 _goalAmount, string memory _description)
        external
        override
    {
        uint256 planId = hashActionPlan({
            _initiator: msg.sender,
            _targetToken: address(_targetToken),
            _goalAmount: _goalAmount,
            _description: _description
        });

        ActionPlan storage plan = plans[planId];
        plan.initiator = msg.sender;
        plan.createTimestamp = block.timestamp;
        plan.targetToken = IERC20(_targetToken);
        plan.goalAmount = _goalAmount;

        emit ActionPlanCreated(planId, msg.sender, address(_targetToken), _goalAmount, _description);
    }

    /// @notice 進行贊助
    function support(uint256 _planId, uint256 _amount) external override interactivePlan(_planId) {
        ActionPlan storage plan = plans[_planId];

        uint256 allowance = plan.targetToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "not enough allowance.");

        plan.targetToken.safeTransferFrom(msg.sender, address(this), _amount);

        if (!plan.sponsorsIndices[msg.sender]) {
            plan.sponsorsIndices[msg.sender] = true;
            plan.sponsors.push(msg.sender);
        }
        plan.totalSponsored += _amount;
        plan.sponsoreds[msg.sender] += _amount;

        emit Support(msg.sender, _amount);
    }

    /// @notice 取消贊助
    function withdrawSupport(uint256 _planId, uint256 _amount) external override interactivePlan(_planId) {
        ActionPlan storage plan = plans[_planId];

        uint256 sponsored = plan.sponsoreds[msg.sender];
        require(sponsored >= _amount, "not enough sponsored amount.");

        plan.totalSponsored -= _amount;
        plan.sponsoreds[msg.sender] -= _amount;

        plan.targetToken.safeTransfer(msg.sender, _amount);

        emit WithdrawSupport(msg.sender, _amount);
    }

    /// @notice 撥款
    function allocate(uint256 planId, uint256 _amount) external override onlyOwner {
        ActionPlan storage plan = plans[planId];

        require(plan.totalSponsored >= plan.goalAmount, "the sponsored amount must be greater than the goal amount.");
        require(plan.totalSponsored - plan.allocatedAmount > 0, "all funds have been allocated.");

        plan.allocatedAmount += _amount;
        plan.targetToken.safeTransfer(plan.initiator, _amount);
        emit Allocated(plan.initiator, _amount);
    }

    /// @notice 行動計畫摘要
    function hashActionPlan(address _initiator, address _targetToken, uint256 _goalAmount, string memory _description)
        public
        pure
        returns (uint256)
    {
        return uint256(keccak256(abi.encode(_initiator, _targetToken, _goalAmount, keccak256(bytes(_description)))));
    }
}
