// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MASS is Ownable {
    IERC20 public raaToken;

    constructor(address _raaTokenAddress) Ownable(msg.sender) {
        raaToken = IERC20(_raaTokenAddress);
    }

    function massTransfer(address[] memory recipients, uint256[] memory amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Recipients and amounts arrays must have the same length");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(raaToken.transfer(recipients[i], amounts[i]), "Transfer failed");
        }
    }

    function withdrawRemainingTokens() external onlyOwner {
        uint256 balance = raaToken.balanceOf(address(this));
        require(raaToken.transfer(owner(), balance), "Withdrawal failed");
    }
}