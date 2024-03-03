// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "forge-std/Script.sol";
import "src/governance/SDGsDAO.sol";
import "src/governance/Timelock.sol";
import "src/erc1155/GovToken.sol";
import "src/ActionCenter.sol";

contract SDGsDAOScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY_LAUNCH_PAD");
        address account = vm.addr(privateKey);

        vm.startBroadcast(privateKey);

        // create contracts
        ActionCenter actionCenter = new ActionCenter();
        GovToken token = new GovToken(address(actionCenter));
        Timelock timelock = new Timelock(1 minutes, account);
        SDGsDAO governor = new SDGsDAO(token, 1 minutes, 1 hours, 1, timelock);

        // timelock settings
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));
        timelock.revokeRole(timelock.DEFAULT_ADMIN_ROLE(), account);

        // transferOwnership
        actionCenter.transferOwnership(address(timelock));
        token.transferOwnership(address(timelock));

        vm.stopBroadcast();

        console.log("CONTRACT_ACTION_CENTER=", address(actionCenter));
        console.log("CONTRACT_GOV_TOKEN=", address(token));
        console.log("CONTRACT_TIMELOCK=", address(timelock));
        console.log("CONTRACT_SDGs_DAO=", address(governor));
    }
}
