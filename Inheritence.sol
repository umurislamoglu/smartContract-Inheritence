//SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.7;

contract Inheritence {
    address owner;

    event LogReceiverFundingReceived(address addr , uint amount , uint contractBalance);


    struct Receiver {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }
    Receiver[] public receivers;
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner , "Only the owner can add receiver");
        _;
    }

    function addReceiver(
        address payable walletAddress,
        string memory firstName,
        string memory lastName,
        uint releaseTime,
        uint amount,
        bool canWithdraw
        ) public onlyOwner {
            receivers.push(
                Receiver(
                    walletAddress,
                    firstName,
                    lastName,
                    releaseTime,
                    amount,
                    canWithdraw=false
                )
            );
        }

        function balanceOf() public view returns (uint) {
            return address(this).balance;
        }

        function getIndex(address walletAddress) private view returns(uint) {
            for(uint i = 0; i< receivers.length; i ++) {
                if(receivers[i].walletAddress == walletAddress) {
                    return i;
                } 
            }
            return 999;
        }
          
        function addToReceiversBalance(address walletAddress) private onlyOwner{
            uint i = getIndex(walletAddress);
            receivers[i].amount += msg.value;
            emit LogReceiverFundingReceived(walletAddress , msg.value , balanceOf());
        }

        function deposit(address walletAddress) payable public onlyOwner {
            addToReceiversBalance(walletAddress);
        }

        function availableToWithdraw(address walletAddress) public returns(bool) {
            uint i = getIndex(walletAddress);
            require(block.timestamp > receivers[i].releaseTime , "You are not able to withdraw at this time");
            if(block.timestamp > receivers[i].releaseTime) {
             receivers[i].canWithdraw = true; 
                return true;
            } else {
                return false;
            }
        }

        function withdraw(address payable walletAddress) payable public {
            uint i = getIndex(walletAddress);
            availableToWithdraw(walletAddress);
            require(msg.sender ==receivers[i].walletAddress , "You must be the receiver to withdraw");
            require(receivers[i].canWithdraw== true , "You are not able to withdraw at this time");
            if(receivers[i].canWithdraw){
            receivers[i].walletAddress.transfer(receivers[i].amount);
            receivers[i].amount= 0;
            }
        }

}