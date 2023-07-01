// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
* @title Simple Faucet
* @dev Nguyen Tuan Linh <inbox@linhntaim.com>
*/
contract SimpleFaucet is Ownable {
    uint256 private _amount = 2 * 10**16;
    mapping(address => uint) private _timeouts;

    event Withdrawal(address indexed to, uint256 amount);
    event Deposit(address indexed from, uint256 amount);

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getAmount() public view returns (uint256) {
        return _amount;
    }

    function withdraw() external {
        address sender = _msgSender();
        uint256 balance = getBalance();
        uint256 amount = getAmount();
        
        require(balance >= amount, "This faucet is empty. Please check back later.");
        require(_timeouts[sender] <= block.timestamp - 3 hours, "You can only withdraw once every 3 hours. Please check back later.");
        
        payable(sender).transfer(amount);
        _timeouts[sender] = block.timestamp;
        
        emit Withdrawal(sender, amount);
    }
    
    receive() external payable {
        address sender = _msgSender();
        uint256 depositAmount = msg.value;
        uint256 withdrawAmount = getAmount();

        // If sender gives an amount of 75% withdrawal amount or bigger, the restriction time for withdrawing will be reset
        if (depositAmount >= withdrawAmount / 4 * 3) {
            _timeouts[sender] = block.timestamp - 3 hours;
        }

        emit Deposit(sender, depositAmount);
    }
}