// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CLAIM is Ownable, ReentrancyGuard {
    IERC20 public immutable token;

    struct User {
        uint256 balance;
        bool exists;
    }

    mapping(address => User) public users;
    address[] public userAddresses;

    event UserAdded(address indexed userAddress, uint256 balance);
    event BalanceUpdated(address indexed userAddress, uint256 newBalance);
    event Withdrawal(address indexed userAddress, uint256 amount);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        require(_tokenAddress != address(0), "Invalid token address");
        token = IERC20(_tokenAddress);
    }

    function addUser(address _userAddress, uint256 _balance) external onlyOwner {
        require(_userAddress != address(0), "Invalid address");
        require(!users[_userAddress].exists, "User already exists");

        users[_userAddress] = User(_balance, true);
        userAddresses.push(_userAddress);

        emit UserAdded(_userAddress, _balance);
    }

    function updateUserBalance(address _userAddress, uint256 _newBalance) external onlyOwner {
        require(users[_userAddress].exists, "User does not exist");

        users[_userAddress].balance = _newBalance;

        emit BalanceUpdated(_userAddress, _newBalance);
    }

    function withdraw() external nonReentrant {
        require(users[msg.sender].exists, "User does not exist");
        require(users[msg.sender].balance > 0, "No balance to withdraw");

        uint256 amount = users[msg.sender].balance;
        users[msg.sender].balance = 0;

        require(token.transfer(msg.sender, amount), "Token transfer failed");

        emit Withdrawal(msg.sender, amount);
    }

    function getUserBalance(address _userAddress) external view returns (uint256) {
        require(users[_userAddress].exists, "User does not exist");
        return users[_userAddress].balance;
    }

    function getUserCount() external view returns (uint256) {
        return userAddresses.length;
    }

    function withdrawContractTokens() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");

        require(token.transfer(owner(), balance), "Token transfer failed");
    }
}