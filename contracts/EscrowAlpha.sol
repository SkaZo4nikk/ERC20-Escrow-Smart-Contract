// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EscrowContract is Ownable {

    struct Deal {
        address client; //client
        address implementer; //implementer
        IERC20 token;
        uint256 amount;
        bool dealCompleted;
        bool fundsDeposited;
    }

    mapping(uint256 => Deal) public deals;

    constructor() Ownable(msg.sender) {}

    function createDeal(uint256 id, address implementer, IERC20 token, uint256 amount) external returns (uint256) {
        uint256 dealId = id;
        deals[dealId] = Deal(msg.sender, implementer, token, amount, false, false);
        return dealId;
    }

    function depositTokens(uint256 dealId) external {
        Deal storage deal = deals[dealId];
        require(msg.sender == deal.client, "Only the client can deposit tokens for the deal.");
        require(deal.token.transferFrom(msg.sender, address(this), deal.amount), "Token transfer failed");
        deal.fundsDeposited = true;
    }

    function completeDeal(uint256 dealId) external onlyOwner {
        Deal storage deal = deals[dealId];
        require(!deal.dealCompleted, "Deal is already completed.");
        require(deal.token.transfer(deal.implementer, deal.amount), "Token transfer failed");
        deal.dealCompleted = true;
    }

        function denyDeal(uint256 dealId) external onlyOwner {
        Deal storage deal = deals[dealId];
        require(deal.fundsDeposited, "No funds deposited for this deal");
        require(!deal.dealCompleted, "Deal is already completed");

        deal.dealCompleted = true;
        uint256 refundAmount = deal.amount;
        deal.fundsDeposited = false;

        require(deal.token.transfer(deal.client, refundAmount), "Refund failed");
    }

    function finalizeDeal(uint256 dealId, uint256 implementerPercentage) external onlyOwner {
        Deal storage deal = deals[dealId];
        require(deal.fundsDeposited, "No funds deposited for this deal");
        require(!deal.dealCompleted, "Deal is already completed");

        deal.dealCompleted = true; 
        uint256 implementerAmount = deal.amount * implementerPercentage / 100;
        uint256 clientRefund = deal.amount - implementerAmount;

        require(deal.token.transfer(deal.implementer, implementerAmount), "Transfer to implementer failed");
        if (clientRefund > 0) {
            require(deal.token.transfer(deal.client, clientRefund), "Refund to client failed");
        }
    }

}