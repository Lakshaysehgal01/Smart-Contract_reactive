// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;
import {Ownable} from "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract RewardsEth is Ownable{
    mapping(address => bool ) public goalComplete;
    mapping(address =>uint) public claimRewards;
    uint public totalDonation;
    uint public moneyInContract;
    mapping (address => uint ) public donations;
    event Donation(address indexed donor, uint value);
    event Claimed(address indexed user,uint value); 
    event SetReward(address indexed user, uint indexed value);
    constructor()Ownable(msg.sender) {
   

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
    function claim() public {
        require(goalComplete[msg.sender], "Please complete your daily goals first");
        uint amount = claimRewards[msg.sender];
        require(amount > 0, "No rewards to claim");
        require(moneyInContract >= amount, "Insufficient funds in contract");

        claimRewards[msg.sender] = 0;
        goalComplete[msg.sender] = false;
        moneyInContract -= amount;

        payable(msg.sender).transfer(amount);

        emit Claimed(msg.sender, amount); 
    }

    receive() external payable{
        donation();
    }
}