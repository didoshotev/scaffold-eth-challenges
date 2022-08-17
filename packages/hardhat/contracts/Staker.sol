// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";
import "hardhat/console.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances;
    uint256 public treshold = 0;
    uint256 deadline = 0;
    // uint256 public deadline = block.timestamp + 30 seconds;
    bool canWithdraw = false;

    event Stake(address, uint256);
    event Executed(uint256);
    event Withdraw(address, uint256);

    constructor(address _exampleExternalContract) {
        exampleExternalContract = ExampleExternalContract(
            _exampleExternalContract
        );
    }

    modifier isWithdrawable() {
        require(canWithdraw == true, "Not Withdrawable");
        _;
    }

    function stake() external payable {
        balances[msg.sender] += msg.value;
        _stake(msg.value);
        console.log("receive new balance: ", address(this).balance);
    }

    function _stake(uint256 stakedValue) internal {
        treshold += stakedValue;
        deadline++;
        emit Stake(msg.sender, msg.value);
    }

    function execute() public payable {
        require(deadline >= 3, "At least 3 stakings are required");
        if (address(this).balance >= 0.002 ether) {
            treshold = 0;
            deadline = 0;
            emit Executed(address(this).balance);
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            canWithdraw = true;
        }
    }

    function withdraw() public payable isWithdrawable {
        address payable receiver = payable(msg.sender);
        (bool sent, ) = receiver.call{value: balances[receiver]}("");
        require(sent, "Failed to send Ether");
        treshold -= balances[receiver];
        balances[receiver] = 0;
        emit Withdraw(receiver, balances[receiver]);
    }

    function getDeadline() public view returns (uint256) {
        return deadline;
    }

    function getCanWithdraw() public view returns (bool) {
        return canWithdraw;
    }

    function getUserBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function getTreshold() public view returns (uint256) {
        return treshold;
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
        _stake(msg.value);
        console.log("receive new balance: ", address(this).balance);
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function

    // Add a `withdraw()` function to let users withdraw their balance

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

    // Add the `receive()` special function that receives eth and calls stake()
}
