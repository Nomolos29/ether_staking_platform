// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Objective: Write an Ether staking smart contract that allows users to stake Ether for a specified period.

// Requirements:
// Users should be able to stake Ether by sending a transaction to the contract.
// The contract should record the staking time for each user.
// Implement a reward mechanism where users earn rewards based on how long they have staked their Ether.
// The rewards should be proportional to the duration of the stake.
// Users should be able to withdraw both their staked Ether and the earned rewards after the staking period ends.
// Ensure the contract is secure, especially in handling users’ funds and calculating rewards.

contract stakeEther {
    // initaialising Owner Address
    address owner;
    uint initialContractBalance;

    // Creating struct to record and track time to funds
    struct Stake {
        uint unlockTime;
        uint stakedAmount;
    }

    constructor() payable {
        // Setting Owner Address to deployer address
        owner = msg.sender;
        initialContractBalance = msg.value;
    }

    // mapping struct by account address
    mapping (address => Stake) internal stakes;

    // mapping reward amount to staker's address
    mapping (address => uint) internal rewardBalance;

    // Events for transactions
    event depositSuccessful(address indexed owner, uint indexed amount, uint indexed lockTime);
    event withdrawalSuccessful(uint indexed amount, address indexed _address);
    event withdrawAllFundSuccessful(uint indexed stakedAmount, uint indexed reward, uint indexed totalAmount);

    // checkers modifiers
    modifier isSenderAddressZero() {
        require(msg.sender != address(0), "Zero address detected!");
        _;
    }

    modifier stakeLocked() {
        require(stakes[msg.sender].unlockTime <= block.timestamp, "Try again after stake lock time enlapse");
        _;
    }

    function calculateReward(uint _days) internal {
        uint stakedBalance = stakes[msg.sender].stakedAmount;
        uint reward = (stakedBalance / 200000) * _days;

        initialContractBalance -= reward;

        require(reward <= initialContractBalance, "Reward Exceeded and Staking is Closed");
        rewardBalance[msg.sender] += reward;
    }

    function stakeDeposit(uint _days) external payable isSenderAddressZero {
        require(stakes[msg.sender].unlockTime == 0, "You have an unexpiried staking");
        require(msg.value > 0, "You cannot deposit zero");
        require(_days > 0, "You have to stake for at least one day");

        uint _unlockTime = block.timestamp + (_days * 24 * 60 * 60);
        // uint _unlockTime = block.timestamp + _days;

        stakes[msg.sender].stakedAmount = stakes[msg.sender].stakedAmount + msg.value;
        stakes[msg.sender].unlockTime = _unlockTime;
        calculateReward(_days);

        emit depositSuccessful(msg.sender, msg.value, _unlockTime);
    }

    function myStakedBalance() external view returns(uint) {
        return stakes[msg.sender].stakedAmount;
    }

    function getStakeReward() external view returns(uint balance) {
        return rewardBalance[msg.sender];
    }

    function withdrawStakedAmount() external isSenderAddressZero stakeLocked {
        require(stakes[msg.sender].stakedAmount > 0, "This account does not exit or balance has been deducted!");

        uint stakedBalance = stakes[msg.sender].stakedAmount;

        stakes[msg.sender].stakedAmount = stakes[msg.sender].stakedAmount - stakes[msg.sender].stakedAmount;
        (bool sent,) = msg.sender.call{value: stakedBalance}("");
        
        
        require(sent, "Withdrawal failed!");

        stakes[msg.sender].unlockTime = 0;
        emit withdrawalSuccessful(stakes[msg.sender].stakedAmount, msg.sender);
    }

    function withdrawAllFunds() external isSenderAddressZero stakeLocked {
        require(stakes[msg.sender].stakedAmount > 0, "This account does not exit or balance has been deducted!");

        uint withdrawalAmount = stakes[msg.sender].stakedAmount + rewardBalance[msg.sender];
        rewardBalance[msg.sender] = 0;
        stakes[msg.sender].stakedAmount = stakes[msg.sender].stakedAmount - stakes[msg.sender].stakedAmount;
        (bool sent,) = msg.sender.call{value: withdrawalAmount}("");

        
        require(sent, "Withdrawal failed!");

        stakes[msg.sender].unlockTime = 0;
        emit withdrawAllFundSuccessful(stakes[msg.sender].stakedAmount, rewardBalance[msg.sender], withdrawalAmount);
    }

    // function adminDeposit() external payable isSenderAddressZero {
    //     require(msg.sender == owner, "You are not the Owner!!");
    //     address(this).balance += msg.value;
    //     // require(sent, "Withdrawal failed!");
    // }

}
