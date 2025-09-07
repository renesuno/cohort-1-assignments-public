// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MockERC20.sol";

contract MockERC20Test is Test {
    MockERC20 public token;

    function setUp() public {
        // 테스트할 때마다 fresh하게 배포
        token = new MockERC20("Mock Token", "MOCK");
    }

    function testFreeMintTo() public {
        address recipient = address(0x123);
        // recipient에게 100 토큰 발행
        token.freeMintTo(recipient, 1000);
        // recipient의 잔고 확인
        assertEq(token.balanceOf(recipient), 1000);
    }

    function testFreeMintToSender() public {
        // msg.sender = 이 테스트 컨트랙트 (address(this))
        token.freeMintToSender(500);

        assertEq(token.balanceOf(address(this)), 500);
    }
}
