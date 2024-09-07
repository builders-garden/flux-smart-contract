// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IFluxSub {
    struct Subscription {
        address payer;
        address merchantAddress;
        address tokenAddress;
        uint256 amount;
        uint256 collectedAmount;
        uint256 interval;
        bool active;
        uint256 triggerTime;
    }

    event SubscriptionCreated(uint256 subscriptionId, address payer, address merchantAddress, uint256 amount, uint256 interval);
    event SubscriptionCancelled(uint256 subscriptionId, uint256 timestamp);
    event PaymentTriggered(uint256 subscriptionId, uint256 amount, uint256 nextTriggerTime);
    event PaymentCollected(uint256 subscriptionId, uint256 amount, uint256 timestamp);
}



