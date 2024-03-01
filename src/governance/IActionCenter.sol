// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "src/plan/ActionPlan.sol";

interface IActionCenter {
    event ActionPlanCreated(
        uint256 planId, address initiator, address targetToken, uint256 goalAmount, string description
    );

    function createActionPlan(uint256 _goalAmount, string memory _description) external returns (uint256);
}
