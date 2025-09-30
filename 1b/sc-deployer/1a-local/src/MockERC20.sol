// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // OpenZeppelin ERC20 구현체 가져오기
import {IMockERC20} from "./IMockERC20.sol"; // IMockERC20 인터페이스 가져오기

// Add as many variables or functions as you would like
// for the implementation. The goal is to pass `forge test`.
contract MockERC20 is ERC20, IMockERC20 {
    // MockERC20 컨트랙트 정의, ERC20을 상속하고 IMockERC20 인터페이스 구현

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {} // 컨트랙터 생성자, // ERC20 이름과 심볼을 초기화

    // Implement
    function freeMintTo(uint256 amount, address to) external {
        _mint(to, amount); // IMockERC20 인터페이스 함수 구현
    }

    // 특정 주소(to)에게 토큰(amount) 발행
    // 테스트 시 유동성 공급이나 잔액 세팅 용도로 사용

    // Implement
    function freeMintToSender(uint256 amount) external {
        _mint(msg.sender, amount); // IMockERC20 인터페이스 함수 구현
    }
    // 호출자(sender)에게 토큰(amount) 발행
    // 테스트 시 편리하게 자기 자신에게 토큰 발행
}
