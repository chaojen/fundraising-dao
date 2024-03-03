// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/TimelockController.sol";

/// @title SDGsDAO 執行 Timelock
contract Timelock is TimelockController {
    constructor(uint256 _minDelay, address _admin)
        TimelockController(_minDelay, new address[](0), new address[](0), _admin)
    {}
}
