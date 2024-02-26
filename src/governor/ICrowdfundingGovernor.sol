// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "src/crowdfunding/CrowdfundingState.sol";

/// @title 鏈上募資事件
interface ICrowdfundingGovernor {
    /// @notice 募資發起
    event CrowdfundingCreated(
        uint256 fundingId,
        address initiator,
        uint256 targetAmount,
        uint256 startTimestamp,
        uint256 duration,
        string description
    );

    /// @notice 募資取消
    event CrowdfundingCanceled();

    /// @notice 資助
    event Funded();

    /// @notice 資金存入
    event Deposit(address funder, uint256 amount);

    /// @notice 資金提取
    event Withdraw(address funder, uint256 amount);

    /// @notice 募資不存在
    error CrowdfundingNotExisted(uint256 crowdfundingId);

    /// @notice 發起群眾募資
    function createCrowdfunding(
        address _initiator,
        uint256 _goalAmount,
        uint256 _startTimestamp,
        uint256 _duration,
        string memory _description
    ) external returns (uint256 crowdfundingId);

    /// @notice 取消募資
    function cancelCrowdfunding(address _initiator, uint256 _goalAmount, string memory _description) external;

    /// @notice 結束募資
    function closeCrowdfunding() external;

    /// @notice 進行資助
    function fund(uint256 _fundingId, uint256 _amount) external;

    /// @notice 存款
    function deposit() external payable;

    /// @notice 取款
    function withdraw(uint256 _amount) external;
}
