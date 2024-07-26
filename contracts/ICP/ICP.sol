// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ICP is ERC20, Ownable {
    constructor() ERC20("Internet Computer", "ICP") Ownable(msg.sender) {
        // 8,292.6832 with 18 decimals
        _mint(msg.sender, 8_292_683_200_000_000_000_000);
    }
}