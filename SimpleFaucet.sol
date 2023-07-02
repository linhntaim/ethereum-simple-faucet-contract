// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title Simple Faucet
 * @dev Nguyen Tuan Linh <inbox@linhntaim.com>
 */
contract SimpleFaucet is Ownable {
    uint256 private _sendingAmount = (2 * 10**18) / 100;
    uint256 private _maxDonatingAmount = 10 * 10**18;
    uint256 private _delayMinutes = 180;
    mapping(address => uint256) private _timeouts;

    event Withdraw(address indexed to, uint256 amount);
    event Deposit(address indexed from, uint256 amount);

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getSendingAmount() public view returns (uint256) {
        return _sendingAmount;
    }

    function setSendingAmount(uint256 value) public onlyOwner {
        require(
            value >= 10**18 / 100 && value <= 10**18,
            "Sending amount must be in range of [10^16 -> 10^18]."
        );
        _sendingAmount = value;
    }

    function getMaxDonatingAmount() public view returns (uint256) {
        return _maxDonatingAmount;
    }

    function setMaxDonatingAmount(uint256 value) public onlyOwner {
        require(
            value >= 10**18 / 100 && value <= 100 * 10**18,
            "Max donating amount must be in range of [10^16 -> 10^20]."
        );
        _maxDonatingAmount = value;
    }

    function getDelayMinutes() public view returns (uint256) {
        return _delayMinutes;
    }

    function setDelayMinutes(uint256 value) public onlyOwner {
        require(
            value >= 15 && value <= 1440,
            "Delay value must be in range of [15 -> 1440]."
        );
        _delayMinutes = value;
    }

    function sendMe() external {
        address sender = _msgSender();
        uint256 balance = getBalance();
        uint256 timeout = block.timestamp - _timeouts[sender];

        require(
            balance >= _sendingAmount,
            "Fund is empty now. Please check back later."
        );
        require(
            timeout >= _delayMinutes * 60,
            string.concat(
                "You can only get coins once every ",
                Strings.toString(_delayMinutes),
                " minutes. Please check back later."
            )
        );

        payable(sender).transfer(_sendingAmount);
        _timeouts[sender] = block.timestamp;

        emit Withdraw(sender, _sendingAmount);
    }

    receive() external payable {
        address sender = _msgSender();
        uint256 donatingAmount = msg.value;

        require(
            donatingAmount <= _maxDonatingAmount,
            "The donating amount is too big. Thanks but we do not receive that much."
        );

        // If sender gives an amount of 75% withdrawal amount or bigger, the restriction time for withdrawing will be reset
        if (donatingAmount >= (_sendingAmount / 4) * 3) {
            _timeouts[sender] = block.timestamp - _delayMinutes * 60;
        }

        emit Deposit(sender, donatingAmount);
    }
}
