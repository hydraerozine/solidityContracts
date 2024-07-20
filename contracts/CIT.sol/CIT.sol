// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CIT is ERC20, ReentrancyGuard, Ownable {
    constructor() ERC20("Celestial Interoperability Token", "CIT") Ownable(msg.sender) {
        // 900 trillion with 18 decimals
        _mint(msg.sender, 900_000_000_000_000 * (10 ** uint256(decimals())));
    }

    function transfer(address recipient, uint256 amount) public virtual override nonReentrant returns (bool) {
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override nonReentrant returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }
}