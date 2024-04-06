// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PeerToPeerTransaction is ERC20, Ownable {

    address public admin;

    uint256 public tokenPrice = 0.0001 ether;

    constructor(address initialOwner)
        ERC20("PeerToPeerTransaction", "PTPT")
        Ownable(initialOwner)
    {
        _mint(msg.sender, 10000 * 10 ** decimals());
        admin = initialOwner;
    }

 //   function mint(address to, uint256 amount) public onlyOwner {
 //       _mint(to, amount);
 //   }

    function buyToken() public payable {
        uint256 tokenAmount = msg.value / tokenPrice; // Вычисляем количество токенов по цене
        require(tokenAmount <= balanceOf(address(this)), "Insufficient token balance in contract");
        _transfer(address(this), msg.sender, tokenAmount); // Переводим токены покупателю
    }

    function sellToken(uint256 amount) public payable {
        uint256 etherAmount = amount * tokenPrice; // Вычисляем сумму в эфирах за продажу токенов
        require(address(this).balance >= etherAmount, "Insufficient ether balance in contract");
        _transfer(msg.sender, address(this), amount); // Переводим токены контракту
        payable(msg.sender).transfer(etherAmount); // Переводим эфиры продавцу
    }
}