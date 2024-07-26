// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BLITZC is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public constant CIT = IERC20(0x2fDB6558d48AddFa3321EE400e2dE736FaD4750f);

    uint256 public counter;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event EmergencyWithdrawal(address indexed token, uint256 amount);
    event CounterIncremented(uint256 newValue);
    event CounterDecremented(uint256 newValue);

    constructor() Ownable(msg.sender) {
        counter = 0;
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        CIT.safeTransferFrom(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= CIT.balanceOf(address(this)), "Insufficient balance");
        CIT.safeTransfer(msg.sender, _amount);
        emit Withdrawal(msg.sender, _amount);
    }

    function getCITBalance() external view returns (uint256) {
        return CIT.balanceOf(address(this));
    }

    function withdrawAllTokens(address _token) external onlyOwner {
        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        token.safeTransfer(owner(), balance);
        emit EmergencyWithdrawal(_token, balance);
    }

    function incrementCounter() external {
        counter += 1;
        emit CounterIncremented(counter);
    }

    function decrementCounter() external {
        require(counter > 0, "Counter cannot be negative");
        counter -= 1;
        emit CounterDecremented(counter);
    }
}