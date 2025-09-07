// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/MockERC20.sol";
import "../src/MiniAMM.sol";

contract MiniAMMDeployment is Script {
    function run() public {
        // 배포자 지갑 불러오기
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // 배포자 주소 확인
        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deployer address:", deployer);

        // 잔고 확인
        uint256 balance = deployer.balance;
        console.log("Deployer balance:", balance);

        // Broadcast 모드 활성화, 배포 시작
        vm.startBroadcast(deployerPrivateKey);

        // 1. MockERC20 두 개 배포
        console.log("Deploying TokenX...");
        MockERC20 tokenX = new MockERC20("TokenX", "TKX");
        console.log("TokenX deployed at:", address(tokenX));

        console.log("Deploying TokenY...");
        MockERC20 tokenY = new MockERC20("TokenY", "TKY");
        console.log("TokenY deployed at:", address(tokenY));

        // 2. MiniAMM 배포 (토큰 주소 전달)
        console.log("Deploying MiniAMM...");
        MiniAMM amm = new MiniAMM(address(tokenX), address(tokenY));
        console.log("MiniAMM deployed at:", address(amm));

        // 배포 종료
        vm.stopBroadcast();

        // 터미널에 로그 출력
        console.log("TokenX deployed at:", address(tokenX));
        console.log("TokenY deployed at:", address(tokenY));
        console.log("MiniAMM deployed at:", address(amm));
    }
}
