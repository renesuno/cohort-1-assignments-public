// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    /**
     * @dev 지정된 주소로 토큰을 무료로 민팅
     * @param to 토큰을 받을 주소
     * @param amount 민팅할 토큰 수량
     */
    function freeMintTo(address to, uint256 amount) external {
        _mint(to, amount);
    }

    /**
     * @dev 호출자(msg.sender)에게 토큰을 무료로 민팅
     * @param amount 민팅할 토큰 수량
     */
    function freeMintToSender(uint256 amount) external {
        _mint(msg.sender, amount);
    }
}
