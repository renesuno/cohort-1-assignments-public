// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/MockERC20.sol";

contract TestDeploy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // 아주 간단한 배포만 시도
        MockERC20 token = new MockERC20("Test", "TST");
        console.log("Token deployed at:", address(token));

        vm.stopBroadcast();
    }
}
