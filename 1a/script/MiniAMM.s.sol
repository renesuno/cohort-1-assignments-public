// Title: Foundry용 배포 스크립트

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30; // Solidity 컴파일러 버전 지정, 라이선스는 없음

import {Script} from "forge-std/Script.sol"; // Foundry에서 제공하는 Script 모듈을 가져옴, 배포 스크립트 작성에 사용
import {MiniAMM} from "../src/MiniAMM.sol"; // MiniAMM 스마트 계약을 가져옴, 배포 및 테스트에 사용
import {MockERC20} from "../src/MockERC20.sol"; // MockERC20 스마트 계약을 가져옴, 테스트용 ERC20 토큰 배포에 사용

// Foundry 배포용 스크립트 컨트랙트 정의
contract MiniAMMScript is Script {
    MiniAMM public miniAMM; // 배포될 MiniAMM 컨트랙트 인스턴스를 저장할 변수
    MockERC20 public token0; // 배포될 첫 번째 MockERC20 토큰 인스턴스
    MockERC20 public token1; // 배포될 두 번째 MockERC20 토큰 인스턴스

    function setUp() public {} // Foundry에서 테스트나 스크립트 실행 전 초기 설정 함수, 여기서는 비워둠

    function run() public {
        // Foundry 스크립트 실행 시 호출되는 '메인' 함수
        vm.startBroadcast(); // 실제 블록체인에 배포 트랜잭션을 전송하기 시작

        // Deploy mock ERC20 tokens
        // 실제 코드에서는 token0, token1 배포가 여기에 들어가야 함
        // Deploy MiniAMM with the tokens
        // 실제 코드에서는 MiniAMM를 token0, token1 주소와 함께 배포

        vm.stopBroadcast(); // 블록체인으로의 트랜잭션 전송 종료
    }
}
