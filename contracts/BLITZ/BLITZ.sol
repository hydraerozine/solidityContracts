// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPancakeRouter02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract BLITZ {
    address public constant CIT_TOKEN = 0x93C31Cc3fF99265B744CE64D76313eDF2A76D3E5;
    address public constant PANCAKE_ROUTER = 0x9A082015c919AD0E47861e5Db9A1c7070E81A2C7; // PancakeSwap Router address on BSC

    function swapCITForToken(uint256 amountIn, uint256 amountOutMin, address tokenOut, uint256 deadline) external {
        require(tokenOut != CIT_TOKEN, "Cannot swap CIT for CIT");

        IERC20 citToken = IERC20(CIT_TOKEN);
        require(citToken.transferFrom(msg.sender, address(this), amountIn), "TransferFrom failed");
        require(citToken.approve(PANCAKE_ROUTER, 0), "Approve reset failed"); // First, clear any existing allowance
        require(citToken.approve(PANCAKE_ROUTER, amountIn), "Approve failed");

        address[] memory path = new address[](2);
        path[0] = CIT_TOKEN;
        path[1] = tokenOut;

        IPancakeRouter02(PANCAKE_ROUTER).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
    }
}