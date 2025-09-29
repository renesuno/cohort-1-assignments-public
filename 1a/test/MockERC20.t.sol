// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol"; // Foundry 테스트용 기본 Test 라이브러리 임포트
import {MockERC20} from "../src/MockERC20.sol"; // 테스트 대상 MockERC20 컨트랙트 임포트

contract MockERC20Test is Test {
    // MockERC20 테스트 컨트랙트 정의, Test 상속
    MockERC20 public token; // 테스트용 MockERC20 인스턴스
    // 테스트용 유저 주소 2개
    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        // 테스트 실행 전 초기화 함수
        token = new MockERC20("Mock Token", "MTK"); // MockERC20 컨트랙트 배포
    }

    function test_Constructor() public view {
        // 컨트랙트 생성자 테스트
        assertEq(token.name(), "Mock Token"); // 이름 확인
        assertEq(token.symbol(), "MTK"); // 심볼 확인
        assertEq(token.decimals(), 18); // 소수점 자리수 확인
        assertEq(token.totalSupply(), 0); // 초기 총 공급량 확인
    }

    function test_FreeMintTo() public {
        // freeMintTo 함수 테스트

        uint256 mintAmount = 1000 * 10 ** 18; // // 1000 토큰(18자리)

        // Initial balance should be 0
        assertEq(token.balanceOf(alice), 0); // 초기 alice 잔액 0 확인

        // Mint tokens to alice
        token.freeMintTo(mintAmount, alice); // alice에게 토큰 발행

        // Check that alice received the tokens
        assertEq(token.balanceOf(alice), mintAmount); // alice가 받은 토큰 확인
        assertEq(token.totalSupply(), mintAmount); // 총 공급량 증가 확인
    }

    function test_FreeMintToSender() public {
        // freeMintToSender 함수 테스트

        uint256 mintAmount = 2000 * 10 ** 18; // 2000 tokens

        // Start acting as alice
        vm.startPrank(alice); // alice가 트랜잭션 수행

        // Initial balance should be 0
        assertEq(token.balanceOf(alice), 0); // 초기 잔액 확인

        // Mint tokens to sender (alice)
        token.freeMintToSender(mintAmount); // sender(alice)에게 토큰 발행

        // Check that alice received the tokens
        assertEq(token.balanceOf(alice), mintAmount); // alice가 받은 토큰 확인
        assertEq(token.totalSupply(), mintAmount); // 총 공급량 증가 확인

        vm.stopPrank(); // 트랜잭션 수행 종료
    }
}
