// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract CITA is ERC20, ReentrancyGuard, Ownable {
    IUniswapV3Factory public immutable uniswapV3Factory;
    ISwapRouter public immutable swapRouter;

    constructor(
        address _uniswapV3Factory,
        address _swapRouter
    ) ERC20("Celestial Interoperability Token", "CIT") Ownable(msg.sender) {
        require(_uniswapV3Factory != address(0), "Invalid factory address");
        require(_swapRouter != address(0), "Invalid router address");

        uniswapV3Factory = IUniswapV3Factory(_uniswapV3Factory);
        swapRouter = ISwapRouter(_swapRouter);

        _mint(msg.sender, 1000000000000000 * (10 ** uint256(decimals())));
    }

    function createUniswapV3Pool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external onlyOwner returns (address pool) {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        pool = uniswapV3Factory.createPool(tokenA, tokenB, fee);
    }

    function swapExactInputSingle(
        uint256 amountIn,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint160 sqrtPriceLimitX96
    ) external nonReentrant returns (uint256 amountOut) {
        require(tokenIn != address(0) && tokenOut != address(0), "Invalid token address");

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: fee,
            recipient: msg.sender,
            deadline: block.timestamp + 15,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: sqrtPriceLimitX96
        });

        amountOut = swapRouter.exactInputSingle(params);
    }
}