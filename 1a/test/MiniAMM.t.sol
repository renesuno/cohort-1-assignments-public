// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MockERC20.sol";
import "../src/MiniAMM.sol";

contract MiniAMMTest is Test {
    MockERC20 tokenX;
    MockERC20 tokenY;
    MiniAMM amm;

    address user = address(0x123);

    function setUp() public {
        tokenX = new MockERC20("Token X", "TKX");
        tokenY = new MockERC20("Token Y", "TKY");
        amm = new MiniAMM(address(tokenX), address(tokenY));

        // 유저에게 토큰 민트
        tokenX.freeMintTo(user, 10000);
        tokenY.freeMintTo(user, 10000);

        // 유저가 AMM에 토큰 전송 허용
        vm.startPrank(user);
        tokenX.approve(address(amm), 10000);
        tokenY.approve(address(amm), 10000);
        vm.stopPrank();
    }

    function testAddLiquidityFirst() public {
        vm.prank(user);
        amm.addLiquidity(1000, 2000);
        assertEq(amm.reserveX(), 1000);
        assertEq(amm.reserveY(), 2000);
        assertEq(tokenX.balanceOf(address(amm)), 1000);
        assertEq(tokenY.balanceOf(address(amm)), 2000);
    }

    function testAddLiquidityRatio() public {
        vm.prank(user);
        amm.addLiquidity(1000, 2000); // 초기 비율 1:2

        vm.prank(user);
        amm.addLiquidity(500, 1000); // 비율 유지
        assertEq(amm.reserveX(), 1500);
        assertEq(amm.reserveY(), 3000);
    }

    function testSwapXtoY() public {
        vm.prank(user);
        amm.addLiquidity(1000, 2000); // k = 1000 * 2000 = 2,000,000

        vm.prank(user);
        uint256 dy = amm.swap(address(tokenX), 100); // dx = 100
        // 명시적 정수 계산
        uint256 k = 1000 * 2000;
        uint256 newReserveX = 1000 + 100;
        uint256 newReserveY = k / newReserveX;
        uint256 expectedDy = 2000 - newReserveY; // 1818
        assertEq(dy, expectedDy, "Swap X to Y failed");
        assertEq(amm.reserveX(), 1100);
        assertEq(amm.reserveY(), 2000 - dy);
    }

    function testSwapYtoX() public {
        vm.prank(user);
        amm.addLiquidity(1000, 2000);

        vm.prank(user);
        uint256 dy = amm.swap(address(tokenY), 200); // dx = 200
        // 명시적 정수 계산
        uint256 k = 1000 * 2000;
        uint256 newReserveY = 2000 + 200;
        uint256 newReserveX = k / newReserveY;
        uint256 expectedDy = 1000 - newReserveX; // 909
        assertEq(dy, expectedDy, "Swap Y to X failed");
        assertEq(amm.reserveX(), 1000 - dy);
        assertEq(amm.reserveY(), 2200);
    }
}
