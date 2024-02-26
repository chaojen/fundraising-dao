// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "src/crowdfunding/CrowdfundingState.sol";

/// @title 募資項目
struct Crowdfunding {
    /// @notice 發起人
    address initiator;
    /// @notice 目標募資金額
    uint256 goalAmount;
    /// @notice 建立時間
    uint256 createTimestamp;
    /// @notice 起始時間
    uint256 startTimestamp;
    /// @notice 募資期間
    uint256 duration;
    /// @notice 已取消
    bool canceled;
}
