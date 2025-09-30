// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

// DO NOT change the interface
interface IMiniAMM {
    // MiniAMM 컨트랙트가 반드시 구현해야 하는 함수 시그니처 정의

    function addLiquidity(uint256 xAmountIn, uint256 yAmountIn) external; // 유동성을 풀에 추가하는 함수, // xAmountIn, yAmountIn: 사용자가 넣는 두 토큰의 양, // external: 컨트랙트 외부에서 호출 가능

    function swap(uint256 xAmountIn, uint256 yAmountIn) external; // 토큰을 서로 교환(swap)하는 함수
    // xAmountIn과 yAmountIn 중 하나만 입력 가능, 다른 하나는 0
}

// DO NOT change the interface
interface IMiniAMMEvents {
    // MiniAMM에서 발생하는 이벤트 시그니처 정의
    // 구현체에서 반드시 동일한 이벤트를 발생시켜야 함
    event AddLiquidity(uint256 xAmountIn, uint256 yAmountIn); // addLiquidity 호출 시 발생, 추가된 토큰 양을 기록
    event Swap(uint256 xAmountIn, uint256 yAmountIn); // swap 호출 시 발생, 스왑된 토큰 양을 기록
}
