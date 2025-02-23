// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;
import './lib/reactive-lib/src/abstract-base/AbstractCallback.sol';

//this is final for now
contract RewardsEth is AbstractCallback{
    address private owner;
    modifier onlyOwner{
        require(msg.sender==owner,"You are not the owner of the contract");
        _;
    }
    mapping(address => bool ) public goalComplete;
    mapping(address =>uint) public claimRewards;
    uint public totalDonation;
    uint public moneyInContract;
    mapping (address => uint ) public donations;
    event Donation(address indexed donor, uint value);
    event Claimed(address indexed user,uint value); 
    event SetReward(address indexed user, uint indexed value);
    constructor(address callback) AbstractCallback(callback) payable {
        owner=msg.sender;
    }
    function donation() public payable{
        require(msg.value>0,"Please donate money more than zero");
        donations[msg.sender]+=msg.value;
        totalDonation+=msg.value;
        moneyInContract+=msg.value;
        emit Donation(msg.sender, msg.value);
    }
    function setGoalComplete(address _user, uint _value) public onlyOwner{
        goalComplete[_user]=true;
        claimRewards[_user]+=_value;
        emit SetReward(_user,_value);
    }
    function claim(address /*spender*/,address _user) public {
        require(goalComplete[_user], "Please complete your daily goals first");
        uint amount = claimRewards[_user];
        require(amount > 0, "No rewards to claim");
        require(moneyInContract >= amount, "Insufficient funds in contract");

        claimRewards[_user] = 0;
        goalComplete[_user] = false;
        moneyInContract -= amount;

        payable(_user).transfer(amount);

        emit Claimed(_user, amount); 
    }

}