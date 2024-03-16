// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IActionCenter {
    event Received(address sender, uint256 value);
    event ActionPlanCreated(
        uint256 planId, SDGoal[] goals, address initiator, address targetToken, uint256 goalAmount, string description
    );
    /// @notice 贊助
    event Support(address from, uint256 amount);
    /// @notice 取消贊助
    event WithdrawSupport(address from, uint256 _amount);
    /// @notice 撥款
    event Allocated(address to, uint256 _amount);

    enum SDGoal {
        NoPoverty,
        ZeroHunger,
        GoodHealthAndWellBeing,
        QualityEducation,
        GenderEquality,
        CleanWaterAndSanitation,
        AffordableAndCleanEnergy,
        DecentWorkAndEconomicGrowth,
        IndustryInnovationAndInfrastructure,
        ReducedInequalities,
        SustainableCitiesAndCommunities,
        ResponsibleConsumptionAndProduction,
        ClimateAction,
        LifeBelowWater,
        LifeOnLand,
        PeaceJusticeAndStrongInstitutions,
        PartnershipsForTheGoals
    }

    function createActionPlan(
        SDGoal[] calldata _goals,
        address _targetToken,
        uint256 _goalAmount,
        string calldata _description
    ) external;
    function support(uint256 _planId, uint256 _amount) external;
    function withdrawSupport(uint256 _planId, uint256 _amount) external;
    function allocate(uint256 _planId, uint256 _amount) external;
}
