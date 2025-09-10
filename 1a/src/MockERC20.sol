// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// MockERC20
// 테스트용으로 누구나 자유롭게 mint 할 수 있는 ERC-20
contract MockERC20 is ERC20 {
    // 이름과 심볼은 배포 시 지정 (예: "Mock Token", "MOCK")
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {}

    // 누구나 원하는 주소(to)로 원하는 양(amount)을 발행(토큰을 mint)
    // @param - to 토큰을 받을 주소
    // @param - amount 발행량 (18 decimals 기준: 1 토큰 = 1e18)
    function freeMintTo(address to, uint256 amount) external {
        _mint(to, amount);
    }

    // 호출자(msg.sender)에게 지정된 양(amount)만큼 토큰을 발행(mint)
    // freeMintTo와 유사하지만, 주소가 자동으로 sender로 설정
    // @param - amount 발행량
    function freeMintToSender(uint256 amount) external {
        _mint(msg.sender, amount);
    }
}
