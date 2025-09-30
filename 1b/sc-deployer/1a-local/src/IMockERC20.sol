// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

// DO NOT change the interface
interface IMockERC20 {
    // MockERC20 컨트랙트가 반드시 구현해야 하는 함수 시그니처 정의

    function freeMintTo(uint256 amount, address to) external;

    // 특정 주소(to)에게 지정한 수량(amount)의 토큰을 새로 발행(Mint)하는 함수
    // 테스트 용도로 사용, 실제 ERC20의 mint와 유사

    function freeMintToSender(uint256 amount) external; // 호출자(sender)에게 지정한 수량(amount)의 토큰을 새로 발행(Mint)하는 함수
    // 테스트 시 편리하게 자기 자신에게 토큰을 발행
}
