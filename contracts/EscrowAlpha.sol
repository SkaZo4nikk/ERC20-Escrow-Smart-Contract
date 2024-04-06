// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EscrowContract is Ownable {
    struct Deal {
        address buyer; //client
        address seller; //implementer
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

    function createDeal(address seller, uint256 amount) external returns (uint256) {
        uint256 dealId = nextDealId++;
        deals[dealId] = Deal(msg.sender, seller, amount, false, false);
        return dealId;
    }

    function depositTokens(uint256 dealId) external {
        Deal storage deal = deals[dealId];
        require(msg.sender == deal.buyer, "Only the buyer can deposit tokens for the deal.");
        require(token.transferFrom(msg.sender, address(this), deal.amount), "Token transfer failed");
        deal.fundsDeposited = true;
    }

    function completeDeal(uint256 dealId) external onlyOwner {
        Deal storage deal = deals[dealId];
        require(!deal.dealCompleted, "Deal is already completed.");
        require(token.transfer(deal.seller, deal.amount), "Token transfer failed");
        deal.dealCompleted = true;
    }

        function denyDeal(uint256 dealId) external onlyOwner {
        Deal storage deal = deals[dealId];
        require(deal.fundsDeposited, "No funds deposited for this deal");
        require(!deal.dealCompleted, "Deal is already completed");

        deal.dealCompleted = true;
        uint256 refundAmount = deal.amount;
        deal.fundsDeposited = false;

        require(token.transfer(deal.buyer, refundAmount), "Refund failed");
    }

    function finalizeDeal(uint256 dealId, uint256 sellerPercentage) external onlyOwner {
        Deal storage deal = deals[dealId];
        require(deal.fundsDeposited, "No funds deposited for this deal");
        require(!deal.dealCompleted, "Deal is already completed");

        deal.dealCompleted = true; 
        uint256 sellerAmount = deal.amount * sellerPercentage / 100;
        uint256 buyerRefund = deal.amount - sellerAmount;

        require(token.transfer(deal.seller, sellerAmount), "Transfer to seller failed");
        if (buyerRefund > 0) {
            require(token.transfer(deal.buyer, buyerRefund), "Refund to buyer failed");
        }
    }

}
