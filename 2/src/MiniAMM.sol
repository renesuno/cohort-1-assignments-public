// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {IMiniAMM, IMiniAMMEvents} from "./IMiniAMM.sol";
import {MiniAMMLP} from "./MiniAMMLP.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Add as many variables or functions as you would like
// for the implementation. The goal is to pass `forge test`.
contract MiniAMM is IMiniAMM, IMiniAMMEvents, MiniAMMLP {
    uint256 public k = 0;
    uint256 public xReserve = 0;
    uint256 public yReserve = 0;

    address public tokenX;
    address public tokenY;

    // 0.3% swap fee (3/1000)
    uint256 public constant FEE_NUMERATOR = 3;
    uint256 public constant FEE_DENOMINATOR = 1000;

    // implement constructor
    constructor(address _tokenX, address _tokenY) MiniAMMLP(_tokenX, _tokenY) {
        require(_tokenX != address(0), "tokenX cannot be zero address"); // 🔴 분리
        require(_tokenY != address(0), "tokenY cannot be zero address"); // 🔴 분리
        require(_tokenX != _tokenY, "Tokens must be different");

        // Sort tokens to ensure consistent ordering
        (tokenX, tokenY) = _tokenX < _tokenY
            ? (_tokenX, _tokenY)
            : (_tokenY, _tokenX);
    }

    // Helper function to calculate square root
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }

    // add parameters and implement function.
    // this function will determine the 'k'.
    function _addLiquidityFirstTime(
        uint256 xAmountIn,
        uint256 yAmountIn
    ) internal returns (uint256 lpMinted) {
        require(xAmountIn > 0 && yAmountIn > 0, "Zero amount");

        // Transfer tokens from user
        IERC20(tokenX).transferFrom(msg.sender, address(this), xAmountIn);
        IERC20(tokenY).transferFrom(msg.sender, address(this), yAmountIn);

        // Calculate LP tokens: sqrt(x * y)
        lpMinted = sqrt(xAmountIn * yAmountIn);
        require(lpMinted > 0, "Insufficient liquidity minted");

        // Update reserves
        xReserve = xAmountIn;
        yReserve = yAmountIn;
        k = xReserve * yReserve;

        // Mint LP tokens
        _mintLP(msg.sender, lpMinted);

        emit AddLiquidity(xAmountIn, yAmountIn);
    }

    // add parameters and implement function.
    // this function will increase the 'k'
    // because it is transferring liquidity from users to this contract.
    function _addLiquidityNotFirstTime(
        uint256 xAmountIn,
        uint256 yAmountIn
    ) internal returns (uint256 lpMinted) {
        require(xAmountIn > 0 && yAmountIn > 0, "Zero amount");

        // Calculate required amounts to maintain ratio
        uint256 yAmountRequired = (xAmountIn * yReserve) / xReserve;
        require(yAmountIn >= yAmountRequired, "Insufficient Y amount");

        // Transfer tokens from user
        IERC20(tokenX).transferFrom(msg.sender, address(this), xAmountIn);
        IERC20(tokenY).transferFrom(msg.sender, address(this), yAmountRequired);

        // Calculate LP tokens proportional to existing supply
        lpMinted = (xAmountIn * totalSupply()) / xReserve;
        require(lpMinted > 0, "Insufficient liquidity minted");

        // Update reserves
        xReserve += xAmountIn;
        yReserve += yAmountRequired;
        k = xReserve * yReserve;

        // Mint LP tokens
        _mintLP(msg.sender, lpMinted);

        emit AddLiquidity(xAmountIn, yAmountRequired);
    }

    // complete the function. Should transfer LP token to the user.
    function addLiquidity(
        uint256 xAmountIn,
        uint256 yAmountIn
    ) external returns (uint256 lpMinted) {
        if (k == 0) {
            return _addLiquidityFirstTime(xAmountIn, yAmountIn);
        } else {
            return _addLiquidityNotFirstTime(xAmountIn, yAmountIn);
        }
    }

    // Remove liquidity by burning LP tokens
    function removeLiquidity(
        uint256 lpAmount
    ) external returns (uint256 xAmount, uint256 yAmount) {
        require(lpAmount > 0, "Zero LP amount");
        require(balanceOf(msg.sender) >= lpAmount, "Insufficient LP tokens");

        uint256 totalLp = totalSupply();

        // Calculate token amounts proportional to LP tokens
        xAmount = (lpAmount * xReserve) / totalLp;
        yAmount = (lpAmount * yReserve) / totalLp;

        require(xAmount > 0 && yAmount > 0, "Insufficient liquidity burned");

        // Burn LP tokens
        _burnLP(msg.sender, lpAmount);

        // Update reserves
        xReserve -= xAmount;
        yReserve -= yAmount;
        k = xReserve * yReserve;

        // Transfer tokens to user
        IERC20(tokenX).transfer(msg.sender, xAmount);
        IERC20(tokenY).transfer(msg.sender, yAmount);
    }

    // complete the function
    function swap(uint256 xAmountIn, uint256 yAmountIn) external {
        require(xAmountIn > 0 || yAmountIn > 0, "Must swap at least one token");
        require(
            !(xAmountIn > 0 && yAmountIn > 0),
            "Can only swap one direction at a time"
        );
        require(k > 0, "No liquidity in pool");

        uint256 xAmountOut = 0;
        uint256 yAmountOut = 0;

        if (xAmountIn > 0) {
            // Swap X -> Y
            // Apply fee: amountIn * (1 - 0.003) = amountIn * 997/1000

            require(xAmountIn <= xReserve, "Insufficient liquidity"); // 🔴 추가: 너무 큰 입력 방지

            // ✅ 수정됨: 수수료 계산 공식 변경
            uint256 amountInWithFee = xAmountIn *
                (FEE_DENOMINATOR - FEE_NUMERATOR); // 🔴 변수명 변경
            uint256 numerator = amountInWithFee * yReserve; // 🔴 numerator/denominator로 분리
            uint256 denominator = xReserve * FEE_DENOMINATOR + amountInWithFee;
            yAmountOut = numerator / denominator; // 🔴 계산 방식 변경

            // ✅ 수정됨: require 분리
            require(yAmountOut > 0, "Insufficient liquidity"); // 🔴 && 조건 분리
            require(yAmountOut < yReserve, "Insufficient liquidity");

            // Transfer tokens
            IERC20(tokenX).transferFrom(msg.sender, address(this), xAmountIn);
            IERC20(tokenY).transfer(msg.sender, yAmountOut);

            // Update reserves
            xReserve += xAmountIn;
            yReserve -= yAmountOut;
        } else {
            // Swap Y -> X
            require(yAmountIn <= yReserve, "Insufficient liquidity"); // 🔴 추가: 너무 큰 입력 방지

            uint256 yAmountInWithFee = yAmountIn *
                (FEE_DENOMINATOR - FEE_NUMERATOR);

            xAmountOut =
                xReserve -
                (k * FEE_DENOMINATOR) /
                (yReserve * FEE_DENOMINATOR + yAmountInWithFee);

            require(
                xAmountOut > 0 && xAmountOut < xReserve,
                "Insufficient liquidity"
            );

            // Transfer tokens
            IERC20(tokenY).transferFrom(msg.sender, address(this), yAmountIn);
            IERC20(tokenX).transfer(msg.sender, xAmountOut);

            // Update reserves
            yReserve += yAmountIn;
            xReserve -= xAmountOut;
        }

        // Update k (includes accumulated fees)
        k = xReserve * yReserve;

        emit Swap(xAmountIn, yAmountIn, xAmountOut, yAmountOut);
    }
}
