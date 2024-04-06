// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./MyToken.sol";

contract Escrow {

    address clientAddress;
    address implementerAddress;

    uint256 public totalBalance;

    PeerToPeerTransaction public token;

    constructor(PeerToPeerTransaction _token, address _clientAddress) {
        token = _token;
        clientAddress = _clientAddress;
    }


    //mapping(address => mapping(address => Transaction)) public balances;

//    modifier onlyClient{
//        require(clientAddress, "Only client can use this function");
//        _;
//    }

    function accept(uint256 _amount) external returns (uint256) {
        require(token.transfer(address(this), _amount), "Transfer failed");
        totalBalance += _amount;
        return token.balanceOf(msg.sender);
}

}