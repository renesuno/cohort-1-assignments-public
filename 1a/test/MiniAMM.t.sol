// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol"; // Foundry 테스트용 기본 Test 라이브러리 임포트
import {console} from "forge-std/console.sol"; // Foundry의 콘솔 로그 기능 임포트, 디버깅용
import {MiniAMM} from "../src/MiniAMM.sol"; // 테스트 대상 MiniAMM 컨트랙트 임포트
import {IMiniAMMEvents} from "../src/IMiniAMM.sol"; // MiniAMM 이벤트 인터페이스 임포트
import {MockERC20} from "../src/MockERC20.sol"; // 테스트용 MockERC20 임포트

contract MiniAMMTest is Test {
    // MiniAMM 테스트 컨트랙트 정의, Test 상속

    MiniAMM public miniAMM; // 테스트용 MiniAMM 인스턴스
    MockERC20 public token0; // 테스트용 첫 번째 토큰
    MockERC20 public token1; // 테스트용 두 번째 토큰

    // 테스트용 유저 주소 3개
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public charlie = address(0x3);

    // Import events
    // 이벤트 정의, 실제 MiniAMM 이벤트와 동일 시그니처로 선언해야 vm.expectEmit 사용 가능
    event AddLiquidity(uint256 xAmountIn, uint256 yAmountIn);
    event Swap(uint256 xAmountIn, uint256 yAmountIn);

    function setUp() public {
        // 테스트 실행 전 초기화 함수

        // Deploy mock tokens
        token0 = new MockERC20("Token A", "TKA");
        token1 = new MockERC20("Token B", "TKB");

        // Deploy MiniAMM with the tokens
        miniAMM = new MiniAMM(address(token0), address(token1)); // MiniAMM 컨트랙트 배포, 토큰 주소 전달

        // Mint tokens to test addresses
        // 각 테스트 계정에 충분한 토큰 발행
        token0.freeMintTo(10000 * 10 ** 18, alice);
        token1.freeMintTo(10000 * 10 ** 18, alice);
        token0.freeMintTo(10000 * 10 ** 18, bob);
        token1.freeMintTo(10000 * 10 ** 18, bob);
        token0.freeMintTo(10000 * 10 ** 18, charlie);
        token1.freeMintTo(10000 * 10 ** 18, charlie);

        // Approve tokens for MiniAMM
        // alice가 MiniAMM에 토큰 사용 권한 부여
        vm.startPrank(alice);
        token0.approve(address(miniAMM), type(uint256).max);
        token1.approve(address(miniAMM), type(uint256).max);
        vm.stopPrank();

        // bob도 동일하게 부여
        vm.startPrank(bob);
        token0.approve(address(miniAMM), type(uint256).max);
        token1.approve(address(miniAMM), type(uint256).max);
        vm.stopPrank();

        // charlie도 동일하게 부여
        vm.startPrank(charlie);
        token0.approve(address(miniAMM), type(uint256).max);
        token1.approve(address(miniAMM), type(uint256).max);
        vm.stopPrank();
    }

    function test_Constructor() public view {
        // Check that tokens are set (order doesn't matter for this test)
        // MiniAMM 생성자 테스트
        assertTrue(
            miniAMM.tokenX() == address(token0) ||
                miniAMM.tokenX() == address(token1)
        );
        assertTrue(
            miniAMM.tokenY() == address(token0) ||
                miniAMM.tokenY() == address(token1)
        );
        assertTrue(miniAMM.tokenX() != miniAMM.tokenY());

        // 토큰 주소가 올바르게 세팅되고 서로 다름을 검증, // 초기 k, xReserve, yReserve가 0임을 확인
        assertEq(miniAMM.k(), 0);
        assertEq(miniAMM.xReserve(), 0);
        assertEq(miniAMM.yReserve(), 0);
    }

    function test_ConstructorTokenOrdering() public {
        // 토큰 순서가 항상 tokenX < tokenY가 되도록 테스트
        // Test that tokens are ordered correctly (tokenX < tokenY)
        MockERC20 tokenA = new MockERC20("Token A", "TKA");
        MockERC20 tokenB = new MockERC20("Token B", "TKB");

        MiniAMM amm1 = new MiniAMM(address(tokenA), address(tokenB));
        assertEq(amm1.tokenX(), address(tokenA));
        assertEq(amm1.tokenY(), address(tokenB));

        MiniAMM amm2 = new MiniAMM(address(tokenB), address(tokenA));
        assertEq(amm2.tokenX(), address(tokenA));
        assertEq(amm2.tokenY(), address(tokenB));
    }

    function test_ConstructorRevertZeroAddress() public {
        // 토큰 주소가 0이면 생성자 revert 테스트
        vm.expectRevert("tokenX cannot be zero address");
        new MiniAMM(address(0), address(token1));

        vm.expectRevert("tokenY cannot be zero address");
        new MiniAMM(address(token0), address(0));
    }

    function test_ConstructorRevertSameToken() public {
        // 두 토큰이 같으면 revert 테스트
        vm.expectRevert("Tokens must be different");
        new MiniAMM(address(token0), address(token0));
    }

    function test_AddLiquidityFirstTime() public {
        // 최초 유동성 추가 테스트
        uint256 xAmount = 1000 * 10 ** 18;
        uint256 yAmount = 2000 * 10 ** 18;

        vm.startPrank(alice); // alice가 트랜잭션 수행

        // Get the actual token addresses from MiniAMM
        address actualToken0 = miniAMM.tokenX();
        address actualToken1 = miniAMM.tokenY();

        // Determine which of our tokens corresponds to token0 and token1
        // 토큰 매핑 확인
        MockERC20 token0Actual = actualToken0 == address(token0)
            ? token0
            : token1;
        MockERC20 token1Actual = actualToken1 == address(token1)
            ? token1
            : token0;

        uint256 aliceToken0Before = token0Actual.balanceOf(alice);
        uint256 aliceToken1Before = token1Actual.balanceOf(alice);

        miniAMM.addLiquidity(xAmount, yAmount); // 유동성 추가

        // Check that tokens were transferred (xAmount and yAmount correspond to token0 and token1)
        // 토큰이 MiniAMM로 이동했는지 확인
        assertEq(token0Actual.balanceOf(alice), aliceToken0Before - xAmount);
        assertEq(token1Actual.balanceOf(alice), aliceToken1Before - yAmount);

        // Check that MiniAMM received the tokens
        // MiniAMM 잔액 확인
        assertEq(token0Actual.balanceOf(address(miniAMM)), xAmount);
        assertEq(token1Actual.balanceOf(address(miniAMM)), yAmount);

        // Check that reserves and k were set correctly
        // reserves와 k 값 확인
        assertEq(miniAMM.xReserve(), xAmount);
        assertEq(miniAMM.yReserve(), yAmount);
        assertEq(miniAMM.k(), xAmount * yAmount);

        vm.stopPrank();
    }

    function test_AddLiquidityNotFirstTime() public {
        // 기존 유동성 후 추가 유동성 테스트
        // First, add initial liquidity
        uint256 xInitial = 1000 * 10 ** 18;
        uint256 yInitial = 2000 * 10 ** 18;

        vm.prank(alice);
        miniAMM.addLiquidity(xInitial, yInitial);

        // Now add more liquidity maintaining the ratio
        uint256 xDelta = 500 * 10 ** 18;
        uint256 yRequired = (xDelta * yInitial) / xInitial; // Calculate exact amount needed

        vm.startPrank(bob);

        // Get the actual token addresses from MiniAMM
        address actualToken0 = miniAMM.tokenX();
        address actualToken1 = miniAMM.tokenY();

        // Determine which of our tokens corresponds to token0 and token1
        MockERC20 token0Actual = actualToken0 == address(token0)
            ? token0
            : token1;
        MockERC20 token1Actual = actualToken1 == address(token1)
            ? token1
            : token0;

        uint256 bobToken0Before = token0Actual.balanceOf(bob);
        uint256 bobToken1Before = token1Actual.balanceOf(bob);

        miniAMM.addLiquidity(xDelta, yRequired);

        // Check that tokens were transferred (exact amounts)
        assertEq(token0Actual.balanceOf(bob), bobToken0Before - xDelta);
        assertEq(token1Actual.balanceOf(bob), bobToken1Before - yRequired);

        // Check that reserves were updated correctly
        assertEq(miniAMM.xReserve(), xInitial + xDelta);
        assertEq(miniAMM.yReserve(), yInitial + yRequired);
        assertEq(miniAMM.k(), (xInitial + xDelta) * (yInitial + yRequired));

        vm.stopPrank();
    }

    function test_AddLiquidityNotFirstTimeExactAmount() public {
        // First, add initial liquidity
        uint256 xInitial = 1000 * 10 ** 18;
        uint256 yInitial = 2000 * 10 ** 18;

        vm.prank(alice);
        miniAMM.addLiquidity(xInitial, yInitial);

        // Now add more liquidity with exact amount needed
        uint256 xDelta = 500 * 10 ** 18;
        uint256 yRequired = (xDelta * yInitial) / xInitial; // 1000 tokens

        vm.startPrank(bob);

        // Get the actual token addresses from MiniAMM
        address actualToken0 = miniAMM.tokenX();
        address actualToken1 = miniAMM.tokenY();

        // Determine which of our tokens corresponds to token0 and token1
        MockERC20 token0Actual = actualToken0 == address(token0)
            ? token0
            : token1;
        MockERC20 token1Actual = actualToken1 == address(token1)
            ? token1
            : token0;

        uint256 bobToken0Before = token0Actual.balanceOf(bob);
        uint256 bobToken1Before = token1Actual.balanceOf(bob);

        miniAMM.addLiquidity(xDelta, yRequired);

        // Check that tokens were transferred correctly
        // xDelta should be fully transferred
        assertEq(token0Actual.balanceOf(bob), bobToken0Before - xDelta);

        // yRequired should be fully transferred (no excess handling)
        assertEq(token1Actual.balanceOf(bob), bobToken1Before - yRequired);

        vm.stopPrank();
    }

    function test_AddLiquidityRevertZeroAmount() public {
        vm.expectRevert("Amounts must be greater than 0");
        vm.prank(alice);
        miniAMM.addLiquidity(0, 1000 * 10 ** 18);

        vm.expectRevert("Amounts must be greater than 0");
        vm.prank(alice);
        miniAMM.addLiquidity(1000 * 10 ** 18, 0);
    }

    function test_SwapToken0ForToken1() public {
        // Add initial liquidity
        uint256 xInitial = 1000 * 10 ** 18;
        uint256 yInitial = 2000 * 10 ** 18;

        vm.prank(alice);
        miniAMM.addLiquidity(xInitial, yInitial);

        // Swap token0 for token1
        uint256 xSwap = 100 * 10 ** 18;

        vm.startPrank(bob);

        // Get the actual token addresses from MiniAMM
        address actualToken0 = miniAMM.tokenX();
        address actualToken1 = miniAMM.tokenY();

        // Determine which of our tokens corresponds to token0 and token1
        MockERC20 token0Actual = actualToken0 == address(token0)
            ? token0
            : token1;
        MockERC20 token1Actual = actualToken1 == address(token1)
            ? token1
            : token0;

        uint256 bobToken0Before = token0Actual.balanceOf(bob);
        uint256 bobToken1Before = token1Actual.balanceOf(bob);

        miniAMM.swap(xSwap, 0);

        // Check that token0 was transferred to MiniAMM
        assertEq(token0Actual.balanceOf(bob), bobToken0Before - xSwap);

        // Calculate expected token1 output using constant product formula
        // k = x * y = (x + xSwap) * (y - yOut)
        // yOut = y - k/(x + xSwap)
        uint256 k = miniAMM.k();
        uint256 expectedYOut = yInitial - (k / (xInitial + xSwap));

        // Check that bob received token1
        assertEq(token1Actual.balanceOf(bob), bobToken1Before + expectedYOut);

        // Check that reserves were updated
        assertEq(miniAMM.xReserve(), xInitial + xSwap);
        assertEq(miniAMM.yReserve(), yInitial - expectedYOut);

        vm.stopPrank();
    }

    function test_SwapToken1ForToken0() public {
        // Add initial liquidity
        uint256 xInitial = 1000 * 10 ** 18;
        uint256 yInitial = 2000 * 10 ** 18;

        vm.prank(alice);
        miniAMM.addLiquidity(xInitial, yInitial);

        // Swap token1 for token0
        uint256 ySwap = 200 * 10 ** 18;

        vm.startPrank(bob);

        // Get the actual token addresses from MiniAMM
        address actualToken0 = miniAMM.tokenX();
        address actualToken1 = miniAMM.tokenY();

        // Determine which of our tokens corresponds to token0 and token1
        MockERC20 token0Actual = actualToken0 == address(token0)
            ? token0
            : token1;
        MockERC20 token1Actual = actualToken1 == address(token1)
            ? token1
            : token0;

        uint256 bobToken0Before = token0Actual.balanceOf(bob);
        uint256 bobToken1Before = token1Actual.balanceOf(bob);

        miniAMM.swap(0, ySwap);

        // Check that token1 was transferred to MiniAMM
        assertEq(token1Actual.balanceOf(bob), bobToken1Before - ySwap);

        // Calculate expected token0 output using constant product formula
        // k = x * y = (x - xOut) * (y + ySwap)
        // xOut = x - k/(y + ySwap)
        uint256 k = miniAMM.k();
        uint256 expectedXOut = xInitial - (k / (yInitial + ySwap));

        // Check that bob received token0
        assertEq(token0Actual.balanceOf(bob), bobToken0Before + expectedXOut);

        // Check that reserves were updated
        assertEq(miniAMM.xReserve(), xInitial - expectedXOut);
        assertEq(miniAMM.yReserve(), yInitial + ySwap);

        vm.stopPrank();
    }

    function test_SwapRevertNoLiquidity() public {
        vm.expectRevert("No liquidity in pool");
        vm.prank(alice);
        miniAMM.swap(100 * 10 ** 18, 0);
    }

    function test_SwapRevertBothDirections() public {
        // Add initial liquidity
        uint256 xInitial = 1000 * 10 ** 18;
        uint256 yInitial = 2000 * 10 ** 18;

        vm.prank(alice);
        miniAMM.addLiquidity(xInitial, yInitial);

        vm.expectRevert("Can only swap one direction at a time");
        vm.prank(bob);
        miniAMM.swap(100 * 10 ** 18, 100 * 10 ** 18);
    }

    function test_SwapRevertZeroAmount() public {
        // Add initial liquidity
        uint256 xInitial = 1000 * 10 ** 18;
        uint256 yInitial = 2000 * 10 ** 18;

        vm.prank(alice);
        miniAMM.addLiquidity(xInitial, yInitial);

        vm.expectRevert("Must swap at least one token");
        vm.prank(bob);
        miniAMM.swap(0, 0);
    }

    function test_SwapRevertInsufficientLiquidity() public {
        // Add initial liquidity
        uint256 xInitial = 1000 * 10 ** 18;
        uint256 yInitial = 2000 * 10 ** 18;

        vm.prank(alice);
        miniAMM.addLiquidity(xInitial, yInitial);

        vm.expectRevert("Insufficient liquidity");
        vm.prank(bob);
        miniAMM.swap(xInitial + 1, 0); // Try to swap more than available
    }

    function test_SwapPriceImpact() public {
        // Add initial liquidity
        uint256 xInitial = 1000 * 10 ** 18;
        uint256 yInitial = 2000 * 10 ** 18;

        vm.prank(alice);
        miniAMM.addLiquidity(xInitial, yInitial);

        // Get the actual token addresses from MiniAMM
        address actualToken0 = miniAMM.tokenX();
        address actualToken1 = miniAMM.tokenY();

        // Determine which of our tokens corresponds to token0 and token1
        MockERC20 token0Actual = actualToken0 == address(token0)
            ? token0
            : token1;
        MockERC20 token1Actual = actualToken1 == address(token1)
            ? token1
            : token0;

        // Small swap
        vm.startPrank(bob);
        miniAMM.swap(10 * 10 ** 18, 0);
        uint256 smallSwapOutput = token1Actual.balanceOf(bob);

        // Reset bob's balance by transferring tokens back to MiniAMM
        uint256 bobToken1Balance = token1Actual.balanceOf(bob);
        token1Actual.transfer(address(miniAMM), bobToken1Balance);

        // Large swap
        miniAMM.swap(100 * 10 ** 18, 0);
        uint256 largeSwapOutput = token1Actual.balanceOf(bob);

        // Large swap should have worse price (more slippage)
        // The larger swap should have a worse price per token
        uint256 smallSwapPricePerToken = (smallSwapOutput * 10 ** 18) /
            (10 * 10 ** 18);
        uint256 largeSwapPricePerToken = (largeSwapOutput * 10 ** 18) /
            (100 * 10 ** 18);

        assertLt(largeSwapPricePerToken, smallSwapPricePerToken); // Larger swap has worse price

        vm.stopPrank();
    }

    function test_AddLiquidityEvent() public {
        uint256 xAmount = 1000 * 10 ** 18;
        uint256 yAmount = 2000 * 10 ** 18;

        vm.expectEmit(true, true, true, true);
        emit AddLiquidity(xAmount, yAmount);

        vm.prank(alice);
        miniAMM.addLiquidity(xAmount, yAmount);
    }

    function test_SwapEvent() public {
        // Add initial liquidity
        uint256 xInitial = 1000 * 10 ** 18;
        uint256 yInitial = 2000 * 10 ** 18;

        vm.prank(alice);
        miniAMM.addLiquidity(xInitial, yInitial);

        uint256 xSwap = 100 * 10 ** 18;
        uint256 k = miniAMM.k();
        uint256 expectedYOut = yInitial - (k / (xInitial + xSwap));

        vm.expectEmit(true, true, true, true);
        emit Swap(xSwap, expectedYOut);

        vm.prank(bob);
        miniAMM.swap(xSwap, 0);
    }
}
