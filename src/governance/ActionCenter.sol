// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/plan/ActionPlan.sol";
import "src/governance/IActionCenter.sol";

contract ActionCenter is IActionCenter, Ownable {
    mapping(uint256 => ActionPlan) public actionPlans;

    IERC20 private tokenUSDGs;

    constructor(address _owner, address _tokenUSDGs) Ownable(_owner) {
        tokenUSDGs = IERC20(_tokenUSDGs);
    }

    /// @notice 建立新的行動計畫
    function createActionPlan(uint256 _goalAmount, string memory _description) external override returns (uint256) {
        uint256 planId = hashActionPlan({
            _initiator: msg.sender,
            _targetToken: address(tokenUSDGs),
            _goalAmount: _goalAmount,
            _description: _description
        });

        actionPlans[planId] = new ActionPlan({
            _admin: address(this),
            _initiator: msg.sender,
            _targetToken: address(tokenUSDGs),
            _goalAmount: _goalAmount
        });
        emit ActionPlanCreated(msg.sender, address(tokenUSDGs), _goalAmount, _description);

        return planId;
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
