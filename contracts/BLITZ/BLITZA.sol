// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@pancakeswap/v3-periphery/contracts/libraries/TransferHelper.sol";

interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
    function refundETH() external payable;
}

contract BLITZA is Ownable {
    address public constant CIT_TOKEN = 0x93C31Cc3fF99265B744CE64D76313eDF2A76D3E5;
    ISwapRouter public swapRouter;
    
    uint24 public constant poolFee = 3000; // 0.3% fee tier

    event RouterUpdated(address newRouter);
    event SwapInitiated(uint256 amountIn, uint256 amountOutMin, address tokenOut);
    event SwapCompleted(uint256 amountIn, uint256 amountOut);

    constructor(ISwapRouter _swapRouter) Ownable(msg.sender) {
        require(address(_swapRouter) != address(0), "Invalid router address");
        swapRouter = _swapRouter;
    }

    function updateRouter(ISwapRouter _newRouter) external onlyOwner {
        require(address(_newRouter) != address(0), "Invalid router address");
        swapRouter = _newRouter;
        emit RouterUpdated(address(_newRouter));
    }

    function swapCITForToken(uint256 amountIn, uint256 amountOutMin, address tokenOut, uint256 deadline) external returns (uint256 amountOut) {
        require(tokenOut != CIT_TOKEN, "Cannot swap CIT for CIT");
        require(tokenOut != address(0), "Invalid token address");
        emit SwapInitiated(amountIn, amountOutMin, tokenOut);

        // Transfer CIT tokens from the user to this contract
        TransferHelper.safeTransferFrom(CIT_TOKEN, msg.sender, address(this), amountIn);

        // Approve the router to spend CIT
        TransferHelper.safeApprove(CIT_TOKEN, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: CIT_TOKEN,
            tokenOut: tokenOut,
            fee: poolFee,
            recipient: msg.sender,
            deadline: deadline,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        // Execute the swap
        try swapRouter.exactInputSingle(params) returns (uint256 _amountOut) {
            amountOut = _amountOut;
            emit SwapCompleted(amountIn, amountOut);
        } catch Error(string memory reason) {
            revert(string(abi.encodePacked("PancakeSwap V3 swap failed: ", reason)));
        } catch {
            revert("PancakeSwap V3 swap failed with no error message");
        }

        // Reset the allowance
        TransferHelper.safeApprove(CIT_TOKEN, address(swapRouter), 0);

        // Refund any remaining CIT to the user
        uint256 remainingCIT = IERC20(CIT_TOKEN).balanceOf(address(this));
        if (remainingCIT > 0) {
            TransferHelper.safeTransfer(CIT_TOKEN, msg.sender, remainingCIT);
        }

        return amountOut;
    }

    function getSwapRouter() external view returns (address) {
        return address(swapRouter);
    }

    // Function to receive ETH
    receive() external payable {}
}