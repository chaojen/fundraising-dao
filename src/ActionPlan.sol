// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title SDGs 行動計畫
struct ActionPlan {
    /// @notice 發起人
    address initiator;
    /// @notice 建立時間
    uint256 createTimestamp;
    /// @notice 目標代幣
    IERC20 targetToken;
    /// @notice 目標代幣量
    uint256 goalAmount;
    /// @notice 贊助人
    address[] sponsors;
    mapping(address => bool) sponsorsIndices;
    /// @notice 獲得贊助代幣量
    uint256 totalSponsored;
    mapping(address => uint256) sponsoreds;
    /// @notice 已發送代幣量
    uint256 allocatedAmount;
}
