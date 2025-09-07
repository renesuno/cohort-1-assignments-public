// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Minimal.sol";

contract MinimalDeploy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        Minimal minimal = new Minimal();
        console.log("Minimal deployed at:", address(minimal));

        vm.stopBroadcast();
    }
}
