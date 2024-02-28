// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/governor/SDGsUSD.sol";

contract DistributionScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY_LAUNCH_PAD");
        address account = vm.addr(privateKey);
        address usdt = vm.envAddress("CONTRACT_SEPOLIA_USDT");

        vm.startBroadcast(privateKey);

        new SDGsUSD(account, usdt);

        vm.stopBroadcast();
    }
}
