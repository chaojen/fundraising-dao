// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/governance/USDGs.sol";
import "src/governance/ActionCenter.sol";

contract ActionCenterScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY_LAUNCH_PAD");
        address account = vm.addr(privateKey);
        address tokenUSDGs = vm.envAddress("CONTRACT_SEPOLIA_USDT");

        vm.startBroadcast(privateKey);

        new ActionCenter(account, tokenUSDGs);

        vm.stopBroadcast();
    }
}
