// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol";
import "../contracts/MyToken.sol";
import "remix_accounts.sol";

contract MyTokenTest is PeerToPeerTransaction{

    PeerToPeerTransaction public token; 

    address acc0; 
    address acc1; 
    address acc2;
    address acc3;
    address acc4;
    address acc5;

    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0);
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
        acc3 = TestsAccounts.getAccount(3);
        acc4 = TestsAccounts.getAccount(4);
        acc5 = TestsAccounts.getAccount(5);
        token = new PeerToPeerTransaction();
    }

    function testMyTokenInitialValues() public {
        Assert.equal(token.name(), "PeerToPeerTransaction", "token name did not match");
        Assert.equal(token.symbol(), "PTPT", "token symbol did not match");
        Assert.equal(token.decimals(), 18, "token decimals did not match");
        Assert.equal(token.totalSupply(), 10000000000000000000000, "token supply did not match");
        Assert.equal(token.tokenPrice(), 100000000000000, "token price did not match");
        Assert.equal(token.balanceOf(address(token)), 10000000000000000000000, "token supply did not match");
    }

/// #value: 400000000000000
    function testBuyToken() public payable {
        uint256 initialBalance = token.balanceOf(address(token));
        uint256 tokenAmount = msg.value / token.tokenPrice();
        uint256 startBalance = address(this).balance;
         
        token.buyToken{value: msg.value}(); 

        Assert.equal(token.balanceOf(address(token)), initialBalance - tokenAmount, "Balance of contract after buying tokens is incorrect");
        Assert.equal(token.balanceOf(address(this)), tokenAmount, "Balance of buyer after buying tokens is incorrect ");
        Assert.equal(address(token).balance, msg.value, "Check conract ETH balance");
        Assert.equal(address(this).balance, startBalance - msg.value, "Check buyer ETH balance");
    }


}
