// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./IFluxSub.sol";

contract FluxSubs is ReentrancyGuard, IFluxSub {
        
    bool public initialized;

    address public fluxWorkerAddress;
    address public aggregatorAddress;

    uint256 public lastSubscriptionId;

    mapping(uint256 => Subscription) public subscriptions;

    modifier onlyWorker() {
        require(msg.sender == fluxWorkerAddress, "Unauthorized");
        _;
    }

    constructor(address _fluxWorkerAddress, address _aggregatorAddress) {
        _initialize(_fluxWorkerAddress, _aggregatorAddress);
    }

    function initialize(address _fluxWorkerAddress, address _aggregatorAddress) public {
        _initialize(_fluxWorkerAddress, _aggregatorAddress);
    }

    function _initialize(address _fluxWorkerAddress, address _aggregatorAddress) internal { 
        require(!initialized, "Already initialized");
        fluxWorkerAddress = _fluxWorkerAddress;
        aggregatorAddress = _aggregatorAddress;
        initialized = true;
    }

    function setFluxWorkerAddress(address _fluxWorkerAddress) public onlyWorker{
        require(_fluxWorkerAddress != address(0), "Invalid address");
        fluxWorkerAddress = _fluxWorkerAddress;
    }

    function createSubscription(address payer, address merchantAddress, address tokenAddress, uint256 amount, uint256 interval) public onlyWorker returns (uint256) {
        require(merchantAddress != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than 0");
        require(duration > 0, "Duration must be greater than 0");

        uint256 subscriptionId = lastSubscriptionId + 1;
        subscriptions[subscriptionId] = Subscription({
            payer: payer,
            merchantAddress: merchantAddress,
            tokenAddress: tokenAddress,
            amount: amount,
            collectedAmount: 0,
            interval: interval,
            active: true,
            triggerTime: block.timestamp  // first payment is now
        });
        lastSubscriptionId = subscriptionId;
        emit SubscriptionCreated(subscriptionId, payer, merchantAddress, amount, duration);
        return subscriptionId;
    }

    function triggerPayment(uint256 subscriptionId) public returns (bool) {
        require(subscriptionId != 0, "Invalid id");
        require(subscriptions[subscriptionId].active, "Not active");
        require(subscriptions[subscriptionId].triggerTime <= block.timestamp, "Trigger time is in the future");
        // transfer tokens from payer to merchant
        try IERC20(subscriptions[subscriptionId].tokenAddress).transferFrom(subscriptions[subscriptionId].payer, address(this), subscriptions[subscriptionId].amount) {
        } catch {
            subscriptions[subscriptionId].active = false;
            emit SubscriptionCancelled(subscriptionId, block.timestamp);
            return false;
        }
        // update collected amount
        subscriptions[subscriptionId].collectedAmount += subscriptions[subscriptionId].amount;
        // update trigger time
        subscriptions[subscriptionId].triggerTime += subscriptions[subscriptionId].interval;
        emit PaymentTriggered(subscriptionId, subscriptions[subscriptionId].amount, subscriptions[subscriptionId].triggerTime);
        return true;
    }

    function collectPayment(uint256 subscriptionId, bytes memory callData, bool approveNeeded) public onlyWorker {
        require(subscriptionId != 0, "Invalid id");
        require(subscriptions[subscriptionId].collectedAmount > 0, "No payment collected");
        uint256 preBalance = IERC20(subscriptions[subscriptionId].tokenAddress).balanceOf(address(this));
        // if approveNeeded is true, approve the aggregator to spend the tokens
        if (approveNeeded) {
            IERC20(subscriptions[subscriptionId].tokenAddress).approve(aggregatorAddress, subscriptions[subscriptionId].collectedAmount);
        }
        // call the function
        (bool success, bytes memory returnData) = aggregatorAddress.call(callData);
        require(success, "Call failed");
        uint256 postBalance = IERC20(subscriptions[subscriptionId].tokenAddress).balanceOf(address(this));
        uint256 amountCollected = preBalance - postBalance;
        require(amountCollected > 0 && amountCollected <= subscriptions[subscriptionId].collectedAmount, "Invalid amount collected");
        subscriptions[subscriptionId].collectedAmount -= amountCollected;
        emit PaymentCollected(subscriptionId, amountCollected, block.timestamp);
    }
        
    function cancelSubscription(uint256 subscriptionId) public {
        require(subscriptionId != 0, "Invalid id");
        require(subscriptions[subscriptionId].payer == msg.sender, "You are not the payer");
        require(subscriptions[subscriptionId].active, "Subscription is not active");
        subscriptions[subscriptionId].active = false;
        emit SubscriptionCancelled(subscriptionId, block.timestamp);
    }
}