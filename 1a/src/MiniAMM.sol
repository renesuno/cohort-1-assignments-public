// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {IMiniAMM, IMiniAMMEvents} from "./IMiniAMM.sol"; // MiniAMM 인터페이스와 이벤트 인터페이스 가져오기
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // ERC20 표준 인터페이스 가져오기 (토큰 전송 및 조회 용도)

// Add as many variables or functions as you would like for the implementation.
// The goal is to pass `forge test`.
contract MiniAMM is IMiniAMM, IMiniAMMEvents {
    // MiniAMM 컨트랙트 정의, IMiniAMM과 IMiniAMMEvents 인터페이스를 구현

    uint256 public k = 0; // 상수 곱: xReserve * yReserve, 풀 상태를 나타냄
    uint256 public xReserve = 0; // x 토큰의 현재 예치량
    uint256 public yReserve = 0; // y 토큰의 현재 예치량

    address public tokenX; // 풀에서 x 토큰 주소
    address public tokenY; // 풀에서 y 토큰 주소

    // implement constructor
    constructor(address _tokenX, address _tokenY) {} // MiniAMM 컨트랙트 생성자, // 두 토큰 주소를 받아 풀을 초기화, 실제 구현 필요

    // add parameters and implement function.
    // this function will determine the initial 'k'.
    function _addLiquidityFirstTime() internal {} // 최초 유동성 추가 시 호출되는 내부 함수, // 초기 k 값 결정 및 xReserve, yReserve 설정

    // add parameters and implement function. This function will increase the 'k'
    // because it is transferring liquidity from users to this contract.
    function _addLiquidityNotFirstTime() internal {} // 이미 유동성이 있는 경우 추가 유동성 처리, // 기존 k 값을 유지하면서 xReserve, yReserve 증가

    // complete the function
    function addLiquidity(uint256 xAmountIn, uint256 yAmountIn) external {
        if (k == 0) {
            // add params
            _addLiquidityFirstTime(); // k가 0이면 최초 유동성 추가
        } else {
            // add params
            _addLiquidityNotFirstTime(); // 기존 유동성 있는 경우
        }
    }

    // complete the function
    function swap(uint256 xAmountIn, uint256 yAmountIn) external {} // 토큰 교환(swap) 함수
    // xAmountIn 또는 yAmountIn 중 하나만 입력 가능, k를 기반으로 출력 토큰 계산
}
