// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "src/crowdfunding/Crowdfunding.sol";
import "src/crowdfunding/CrowdfundingState.sol";
import "src/governor/ICrowdfundingGovernor.sol";
import "src/governor/CrowdfundingGovernorStorage.sol";

/// @title 募資管理平台
contract CrowdfundingGovernor is ICrowdfundingGovernor, CrowdfundingGovernorStorage {
    receive() external payable {
        this.deposit();
    }

    /// @notice 發起群眾募資
    function createCrowdfunding(
        address _initiator,
        uint256 _goalAmount,
        uint256 _startTimestamp,
        uint256 _duration,
        string memory _description
    ) external override returns (uint256 crowdfundingId) {
        require(_initiator != address(0), "must need initiator.");
        require(_goalAmount > 0, "goal amount must > 0.");
        require(_startTimestamp > block.timestamp, "start timestamp must after now.");
        require(_duration > 0, "duration must > 0.");
        require(bytes(_description).length > 0, "must need description.");

        crowdfundingId = hashCrowdfunding(_initiator, _goalAmount, _description);

        Crowdfunding storage crowdfunding = crowdfundings[crowdfundingId];
        crowdfunding.initiator = _initiator;
        crowdfunding.goalAmount = _goalAmount;
        crowdfunding.createTimestamp = block.timestamp;
        crowdfunding.startTimestamp = _startTimestamp;
        crowdfunding.duration = _duration;

        emit CrowdfundingCreated(crowdfundingId, _initiator, _goalAmount, _startTimestamp, _duration, _description);
    }

    /// @notice 取消募資
    function cancelCrowdfunding(address _initiator, uint256 _goalAmount, string memory _description) external override {
        require(_initiator != address(0), "must need initiator.");
        require(_goalAmount > 0, "goal amount must > 0.");
        require(bytes(_description).length > 0, "must need description.");

        uint256 crowdfundingId = hashCrowdfunding(_initiator, _goalAmount, _description);
        Crowdfunding storage crowdfunding = crowdfundings[crowdfundingId];

        require(msg.sender == crowdfunding.initiator, "only initiator.");

        crowdfunding.canceled = true;

        // TODO 執行退款
        address[] memory funders = fundersOf[crowdfundingId];
        for (uint256 i = 0; i < funders.length; ++i) {
            funders[i];
        }

        emit CrowdfundingCanceled();
    }

    /// @notice 結束募資
    function closeCrowdfunding() external override {
        // TODO 抵達結束日期後才可執行
        // TODO 若達成目標則撥款
        // TODO 若未達目標則退款
    }

    /// @notice 進行資助
    function fund(uint256 _fundingId, uint256 _amount) external override {
        Crowdfunding storage funding = crowdfundings[_fundingId];

        emit Funded();
    }

    /// @notice 存款
    function deposit() external payable override {
        balanceOf[msg.sender] = balanceOf[msg.sender] + msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    /// @notice 取款
    function withdraw(uint256 _amount) external override {
        uint256 balance = balanceOf[msg.sender];
        require(balance > _amount, "balance not enough.");

        (bool success, bytes memory data) = msg.sender.call{value: _amount}("");
        require(success, string(data));

        balanceOf[msg.sender] = balance - _amount;

        emit Withdraw(msg.sender, _amount);
    }

    /// @notice 募資項目狀態
    function state(uint256 _crowdfundingId) public view returns (CrowdfundingState) {
        Crowdfunding memory crowdfunding = crowdfundings[_crowdfundingId];

        if (crowdfunding.createTimestamp == 0) {
            revert CrowdfundingNotExisted(_crowdfundingId);
        }

        if (block.timestamp < crowdfunding.startTimestamp) {
            return CrowdfundingState.Pending;
        }

        bool crowdfundingCanceled = crowdfunding.canceled;
        if (crowdfundingCanceled) {
            return CrowdfundingState.Canceled;
        }

        // Pending,
        // Active,
        // Canceled,
        // Defeated,
        // Succeeded
        // TODO 判斷募資項目狀態
    }

    /// @notice 取得募資摘要
    function hashCrowdfunding(address _initiator, uint256 _goalAmount, string memory _description)
        public
        pure
        returns (uint256)
    {
        return uint256(keccak256(abi.encode(_initiator, _goalAmount, keccak256(bytes(_description)))));
    }
}
