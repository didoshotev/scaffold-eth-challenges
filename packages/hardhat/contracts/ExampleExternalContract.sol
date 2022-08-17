// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract ExampleExternalContract { 

    uint256 stakedAmount;

    function complete() external payable { 
        stakedAmount += msg.value;
    }

    function getBalance() public view returns(uint256) { 
        return address(this).balance;
    }

    function getStakedAmount() public view returns(uint256) { 
        return stakedAmount;
    }
}