// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EscrowContract is Ownable {

    struct Deal {
        address client; //client
        address implementer; //implementer
        uint256 amount;
        bool dealCompleted;
        bool fundsDeposited;
    }

    uint256 public nextDealId;
    mapping(uint256 => Deal) public deals;
    IERC20 public token;

    constructor(IERC20 _token) Ownable(msg.sender) {
        token = _token;
        nextDealId = 1;
    }

    function createDeal(address implementer, uint256 amount) external returns (uint256) {
        uint256 dealId = nextDealId++;
        deals[dealId] = Deal(msg.sender, implementer, amount, false, false);
        return dealId;
    }

    function depositTokens(uint256 dealId) external {
        Deal storage deal = deals[dealId];
        require(msg.sender == deal.client, "Only the client can deposit tokens for the deal.");
        require(token.transferFrom(msg.sender, address(this), deal.amount), "Token transfer failed");
        deal.fundsDeposited = true;
    }

    function completeDeal(uint256 dealId) external onlyOwner {
        Deal storage deal = deals[dealId];
        require(!deal.dealCompleted, "Deal is already completed.");
        require(token.transfer(deal.implementer, deal.amount), "Token transfer failed");
        deal.dealCompleted = true;
    }

        function denyDeal(uint256 dealId) external onlyOwner {
        Deal storage deal = deals[dealId];
        require(deal.fundsDeposited, "No funds deposited for this deal");
        require(!deal.dealCompleted, "Deal is already completed");

        deal.dealCompleted = true;
        uint256 refundAmount = deal.amount;
        deal.fundsDeposited = false;

        require(token.transfer(deal.client, refundAmount), "Refund failed");
    }

    function finalizeDeal(uint256 dealId, uint256 implementerPercentage) external onlyOwner {
        Deal storage deal = deals[dealId];
        require(deal.fundsDeposited, "No funds deposited for this deal");
        require(!deal.dealCompleted, "Deal is already completed");

        deal.dealCompleted = true; 
        uint256 implementerAmount = deal.amount * implementerPercentage / 100;
        uint256 clientRefund = deal.amount - implementerAmount;

        require(token.transfer(deal.implementer, implementerAmount), "Transfer to implementer failed");
        if (clientRefund > 0) {
            require(token.transfer(deal.client, clientRefund), "Refund to client failed");
        }
    }

}
