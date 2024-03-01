// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IActionPlan {
    /// @notice 贊助
    event Support(address from, uint256 amount);
    /// @notice 取消贊助
    event WithdrawSupport(address from, uint256 _amount);
    /// @notice 撥款
    event Allocated(address to, uint256 _amount);

    function support(uint256 _amount) external;
    function withdrawSupport(uint256 _amount) external;
    function allocate(uint256 _amount) external;
}
