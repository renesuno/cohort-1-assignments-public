// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MiniAMM is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable tokenX;
    IERC20 public immutable tokenY;

    uint256 public reserveX;
    uint256 public reserveY;

    event LiquidityAdded(
        address indexed provider,
        uint256 amountX,
        uint256 amountY
    );
    event Swapped(
        address indexed user,
        address indexed tokenIn,
        uint256 amountIn,
        uint256 amountOut
    );

    constructor(address _tokenX, address _tokenY) {
        require(
            _tokenX != address(0) && _tokenY != address(0),
            "Invalid token addresses"
        );
        tokenX = IERC20(_tokenX);
        tokenY = IERC20(_tokenY);
    }

    /**
     * @dev 유동성 추가 함수
     * @param amountX 추가할 tokenX 수량
     * @param amountY 추가할 tokenY 수량
     */
    function addLiquidity(
        uint256 amountX,
        uint256 amountY
    ) external nonReentrant {
        require(amountX > 0 && amountY > 0, "Amounts must be greater than 0");

        // 첫 번째 유동성 공급이 아닌 경우, 비율을 맞춰야 함
        if (reserveX > 0 && reserveY > 0) {
            uint256 expectedAmountY = (amountX * reserveY) / reserveX;
            require(amountY == expectedAmountY, "Invalid ratio");
        }

        // 토큰 전송
        tokenX.safeTransferFrom(msg.sender, address(this), amountX);
        tokenY.safeTransferFrom(msg.sender, address(this), amountY);

        // 리저브 업데이트
        reserveX += amountX;
        reserveY += amountY;

        emit LiquidityAdded(msg.sender, amountX, amountY);
    }

    /**
     * @dev X 토큰을 Y 토큰으로 스왑
     * @param amountXIn 입력할 X 토큰 수량
     * @return amountYOut 출력될 Y 토큰 수량
     */
    function swapXForY(
        uint256 amountXIn
    ) external nonReentrant returns (uint256 amountYOut) {
        require(amountXIn > 0, "Amount must be greater than 0");
        require(reserveX > 0 && reserveY > 0, "Insufficient liquidity");

        // k = x * y 공식 사용하여 출력 수량 계산
        // (x + dx) * (y - dy) = x * y
        // dy = (y * dx) / (x + dx)
        amountYOut = (reserveY * amountXIn) / (reserveX + amountXIn);
        require(amountYOut > 0 && amountYOut < reserveY, "Invalid swap");

        // 토큰 전송
        tokenX.safeTransferFrom(msg.sender, address(this), amountXIn);
        tokenY.safeTransfer(msg.sender, amountYOut);

        // 리저브 업데이트
        reserveX += amountXIn;
        reserveY -= amountYOut;

        emit Swapped(msg.sender, address(tokenX), amountXIn, amountYOut);
    }

    /**
     * @dev Y 토큰을 X 토큰으로 스왑
     * @param amountYIn 입력할 Y 토큰 수량
     * @return amountXOut 출력될 X 토큰 수량
     */
    function swapYForX(
        uint256 amountYIn
    ) external nonReentrant returns (uint256 amountXOut) {
        require(amountYIn > 0, "Amount must be greater than 0");
        require(reserveX > 0 && reserveY > 0, "Insufficient liquidity");

        // k = x * y 공식 사용하여 출력 수량 계산
        amountXOut = (reserveX * amountYIn) / (reserveY + amountYIn);
        require(amountXOut > 0 && amountXOut < reserveX, "Invalid swap");

        // 토큰 전송
        tokenY.safeTransferFrom(msg.sender, address(this), amountYIn);
        tokenX.safeTransfer(msg.sender, amountXOut);

        // 리저브 업데이트
        reserveY += amountYIn;
        reserveX -= amountXOut;

        emit Swapped(msg.sender, address(tokenY), amountYIn, amountXOut);
    }

    /**
     * @dev 현재 가격 조회 (X 토큰 1개당 Y 토큰 수량)
     */
    function getPriceXToY() external view returns (uint256) {
        require(reserveX > 0, "No liquidity");
        return (reserveY * 1e18) / reserveX;
    }

    /**
     * @dev 현재 가격 조회 (Y 토큰 1개당 X 토큰 수량)
     */
    function getPriceYToX() external view returns (uint256) {
        require(reserveY > 0, "No liquidity");
        return (reserveX * 1e18) / reserveY;
    }
}
