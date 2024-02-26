// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "src/crowdfunding/Crowdfunding.sol";

abstract contract CrowdfundingGovernorStorage {
    /// @notice 募款項目列表
    mapping(uint256 crowdfundingId => Crowdfunding crowdfunding) internal crowdfundings;

    /// @notice 募款項目資助人列表
    mapping(uint256 crowdfundingId => address[] funders) internal fundersOf;
    mapping(uint256 crowdfundingId => mapping(address funder => bool)) internal fundersIndices;

    /// @notice 項目募得資金
    mapping(uint256 crowdfundingId => mapping(address funder => uint256 funded)) internal fundedOf;

    /// @notice 資助人資金餘額
    mapping(address funder => uint256 balance) public balanceOf;

    /// @notice 資助人資助項目列表
    mapping(address funder => uint256[] crowdfundingIds) internal fundedsOf;
    mapping(address funder => mapping(uint256 fundingId => bool)) internal fundedsIndices;
}
