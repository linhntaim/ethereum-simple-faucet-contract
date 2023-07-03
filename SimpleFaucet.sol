// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title Simple Faucet
 * @dev Nguyen Tuan Linh <inbox@linhntaim.com>
 */
contract SimpleFaucet is Ownable {
    uint256 private _sendingAmount = (2 * 10**18) / 100; // 0.02
    uint256 private _maxDonatingAmount = 10 * 10**18; // 10
    uint256 private _delayMinutes = 180; // 3h
    uint256 private _cap = 10**3 * 10**18; // 1000
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
            "Sending amount must be in range of [10^16 -> 10^18]." // 0.01 -> 1
        );
        _sendingAmount = value;
    }

    function getMaxDonatingAmount() public view returns (uint256) {
        return _maxDonatingAmount;
    }

    function setMaxDonatingAmount(uint256 value) public onlyOwner {
        require(
            value >= 10**18 / 100 && value <= 100 * 10**18,
            "Max donating amount must be in range of [10^16 -> 10^20]." // 0.01 -> 100
        );
        _maxDonatingAmount = value;
    }

    function getCap() public view returns (uint256) {
        return _cap;
    }

    function setCap(uint256 value) public onlyOwner {
        uint256 balance = getBalance();
        require(
            value >= balance && value <= 100 * 10**3 * 10**18,
            "Cap must be in range of [{current balance} -> 10^23]." // balance -> 100,000
        );
        _cap = value;
    }

    function getDelayMinutes() public view returns (uint256) {
        return _delayMinutes;
    }

    function setDelayMinutes(uint256 value) public onlyOwner {
        require(
            value >= 15 && value <= 1440,
            "Delay value must be in range of [15 -> 1440]." // 15m -> 1d
        );
        _delayMinutes = value;
    }

    function getTimeout() public view returns (uint256) {
        address sender = _msgSender();
        return _timeouts[sender];
    }

    function send(address to) public onlyOwner {
        _send(to);
    }

    function sendMe() external {
        _send(_msgSender());
    }

    function _send(address sender) private {
        uint256 balance = getBalance();

        require(
            balance >= _sendingAmount,
            "Fund is empty now. Please check back later."
        );
        require(
            block.timestamp - _timeouts[sender] >= _delayMinutes * 60,
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
        uint256 balance = getBalance();
        uint256 donatingAmount = msg.value;

        require(
            balance <= _cap + donatingAmount, // balance included donatingAmount already
            "Fund is full now. Please come to donate later. Thank you!"
        );
        require(
            donatingAmount <= _maxDonatingAmount,
            "The donating amount is too big. Thanks but we do not receive that much."
        );

        // If sender gives an amount of 75% withdrawal amount or bigger, the restriction time for withdrawing will be reset
        if (donatingAmount >= (_sendingAmount / 4) * 3) {
            _timeouts[sender] = 0;
        }

        emit Deposit(sender, donatingAmount);
    }
}
