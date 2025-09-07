// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// IERC20: OpenZeppelin의 ERC20 인터페이스를 사용하여 토큰 컨트랙트와 상호작용
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// 1. 컨트랙트 구조 및 상태 변수 정의
// MiniAMM 컨트랙트는 두 ERC20 토큰(X, Y)으로 구성된 풀을 관리
// 상태 변수로 풀의 토큰 잔고와 상수 곱(k)을 유지
contract MiniAMM {
    IERC20 public tokenX; // 첫 번째 토큰
    IERC20 public tokenY; // 두 번째 토큰
    uint256 public reserveX; // 토큰 X의 풀 잔고
    uint256 public reserveY; // 토큰 Y의 풀 잔고

    // constructor - 배포 시 두 토큰의 주소를 받아 초기화
    constructor(address _tokenX, address _tokenY) {
        tokenX = IERC20(_tokenX);
        tokenY = IERC20(_tokenY);
    }

    // 2. addLiquidity 함수 구현
    // 사용자가 토큰 X와 Y를 풀에 공급하여 유동성을 추가하도록 합니다.
    // 첫 공급은 자유 비율로, 이후 공급은 기존 비율(reserveX/reserveY)을 유지
    function addLiquidity(uint256 amountX, uint256 amountY) external {
        if (reserveX == 0 && reserveY == 0) {
            // 첫 유동성 공급: 비율 자유
            require(amountX > 0 && amountY > 0, "Invalid amounts");
        } else {
            // 이후 공급: 기존 비율 유지 (reserveX/reserveY = amountX/amountY)
            require(amountX * reserveY == amountY * reserveX, "Invalid ratio");
        }

        // 토큰 전송
        require(
            tokenX.transferFrom(msg.sender, address(this), amountX),
            "Transfer X failed"
        );
        require(
            tokenY.transferFrom(msg.sender, address(this), amountY),
            "Transfer Y failed"
        );

        // 잔고 업데이트
        reserveX += amountX;
        reserveY += amountY;
    }

    // 3. swap 함수 구현
    // 사용자가 토큰 X를 주고 토큰 Y를 받거나, 토큰 Y를 주고 토큰 X를 받습니다.
    // 상수 곱 공식 k = (x + dx) * (y - dy)를 유지하며, dx를 입력받아 dy를 계산
    function swap(address tokenIn, uint256 dx) external returns (uint256 dy) {
        require(
            tokenIn == address(tokenX) || tokenIn == address(tokenY),
            "Invalid token"
        );
        require(dx > 0, "Invalid amount");
        require(reserveX > 0 && reserveY > 0, "No liquidity");

        uint256 newReserveIn;
        uint256 newReserveOut;
        IERC20 tokenOut;

        if (tokenIn == address(tokenX)) {
            // 토큰 X를 주고 토큰 Y를 받음
            tokenOut = tokenY;
            newReserveIn = reserveX + dx;
            newReserveOut = (reserveX * reserveY) / newReserveIn; // k = x * y 유지
            dy = reserveY - newReserveOut;
        } else {
            // 토큰 Y를 주고 토큰 X를 받음
            tokenOut = tokenX;
            newReserveIn = reserveY + dx;
            newReserveOut = (reserveX * reserveY) / newReserveIn;
            dy = reserveX - newReserveOut;
        }

        // 토큰 전송
        require(
            IERC20(tokenIn).transferFrom(msg.sender, address(this), dx),
            "Transfer in failed"
        );
        require(tokenOut.transfer(msg.sender, dy), "Transfer out failed");

        // 잔고 업데이트
        if (tokenIn == address(tokenX)) {
            reserveX = newReserveIn;
            reserveY = newReserveOut;
        } else {
            reserveX = newReserveOut;
            reserveY = newReserveIn;
        }
    }
}
