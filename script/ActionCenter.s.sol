// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/ActionCenter.sol";

contract ActionCenterScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY_LAUNCH_PAD");
        address account = vm.addr(privateKey);

        vm.startBroadcast(privateKey);

        new ActionCenter(account);

        vm.stopBroadcast();
    }
}
