// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 募資項目狀態
enum ActionPlanState {
    Pending,
    Active,
    Canceled,
    Defeated,
    Succeeded
}
