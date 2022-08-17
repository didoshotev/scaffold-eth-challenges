// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;
    mapping(address => uint256) public balances;

    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 72 hours;
    bool public openForWithdrawal = false;
    bool public completed = false;

    event Stake(address indexed sender, uint256 value);

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    modifier notCompleted() {
        require(!completed, "External contract already complete");
        _;
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    function stake() public payable notCompleted {
        require(
            block.timestamp < deadline,
            "Deadline already passed, too late to stake"
        );
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
    function execute() public notCompleted {
        require(block.timestamp >= deadline, "Deadline not yet reached, wait");
        if (address(this).balance >= threshold) {
            completed = true;
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdrawal = true;
        }
    }

    // if the `threshold` was not met, allow everyone to call a `withdraw()` function
    // Add a `withdraw(address payable)` function lets users withdraw their balance
    function withdraw(address payable withdrawer) public notCompleted {
        require(openForWithdrawal, "Not yet open for withdrawal");
        // do this first to guard against reentrancy (not problem here but good practice)
        uint256 value = balances[withdrawer];
        balances[withdrawer] = 0;

        withdrawer.call{value: value}("");
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}