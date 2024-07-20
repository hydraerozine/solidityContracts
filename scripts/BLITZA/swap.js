const { ethers } = require("hardhat");

async function main() {
  const BLITZA_ADDRESS = "0x439a7B0BBbC82Bb81B3c7E7cab1be9eCc2e725f9"; // Update this if you've redeployed
  const TOKEN_OUT_ADDRESS = "0x8d008B313C1d6C7fE2982F62d32Da7507cF43551";
  const AMOUNT_IN = ethers.parseUnits("10", 18); // Reduced amount for testing
  const AMOUNT_OUT_MIN = ethers.parseUnits("0", 18);
  const DEADLINE = Math.floor(Date.now() / 1000) + 300;

  const [signer] = await ethers.getSigners();
  console.log("Swapping tokens with the account:", signer.address);

  // Updated ABI to match your contract
  const BLITZA_ABI = [
    "function CIT_TOKEN() public view returns (address)",
    "function swapRouter() public view returns (address)",
    "function getSwapRouter() external view returns (address)",
    "function swapCITForToken(uint256 amountIn, uint256 amountOutMin, address tokenOut, uint256 deadline) external returns (uint256)",
    "event SwapInitiated(uint256 amountIn, uint256 amountOutMin, address tokenOut)",
    "event SwapCompleted(uint256 amountIn, uint256 amountOut)"
  ];

  const blitza = new ethers.Contract(BLITZA_ADDRESS, BLITZA_ABI, signer);
  
  const CIT_TOKEN_ADDRESS = await blitza.CIT_TOKEN();
  console.log("CIT Token Address:", CIT_TOKEN_ADDRESS);

  const cit = await ethers.getContractAt("IERC20", CIT_TOKEN_ADDRESS);

  const citBalance = await cit.balanceOf(signer.address);
  console.log("CIT Balance:", ethers.formatUnits(citBalance, 18));

  const currentRouter = await blitza.getSwapRouter();
  console.log("Current SwapRouter:", currentRouter);

  console.log("Approving BLITZA contract to spend CIT tokens...");
  const approveTx = await cit.approve(BLITZA_ADDRESS, AMOUNT_IN);
  await approveTx.wait();
  console.log("Approval transaction hash:", approveTx.hash);

  const allowance = await cit.allowance(signer.address, BLITZA_ADDRESS);
  console.log("Allowance:", ethers.formatUnits(allowance, 18));

  console.log("Swapping CIT tokens...");
  try {
    const swapTx = await blitza.swapCITForToken(AMOUNT_IN, AMOUNT_OUT_MIN, TOKEN_OUT_ADDRESS, DEADLINE, {
      gasLimit: 1000000 // Increased gas limit
    });
    console.log("Swap transaction hash:", swapTx.hash);
    
    console.log("Waiting for transaction to be mined...");
    const receipt = await swapTx.wait();
    console.log("Transaction mined. Block number:", receipt.blockNumber);

    console.log("Parsing logs...");
    const parsedLogs = receipt.logs.map(log => {
      try {
        return blitza.interface.parseLog(log);
      } catch (e) {
        return null;
      }
    }).filter(log => log !== null);

    console.log("All parsed logs:", parsedLogs);

    const swapInitiatedEvent = parsedLogs.find(log => log.name === 'SwapInitiated');
    const swapCompletedEvent = parsedLogs.find(log => log.name === 'SwapCompleted');
    
    if (swapInitiatedEvent) {
      console.log("Swap Initiated Event:", {
        amountIn: ethers.formatUnits(swapInitiatedEvent.args.amountIn, 18),
        amountOutMin: ethers.formatUnits(swapInitiatedEvent.args.amountOutMin, 18),
        tokenOut: swapInitiatedEvent.args.tokenOut
      });
    } else {
      console.log("SwapInitiated event not found in the logs");
    }

    if (swapCompletedEvent) {
      console.log("Swap Completed Event:", {
        amountIn: ethers.formatUnits(swapCompletedEvent.args.amountIn, 18),
        amountOut: ethers.formatUnits(swapCompletedEvent.args.amountOut, 18)
      });
    } else {
      console.log("SwapCompleted event not found in the logs");
    }

    console.log("Swap completed successfully!");
  } catch (error) {
    console.error("Swap failed. Error details:", error);
    
    if (error.data) {
      try {
        const decodedError = blitza.interface.parseError(error.data);
        console.error("Decoded error:", decodedError);
      } catch (decodeError) {
        console.error("Failed to decode error:", decodeError);
      }
    }
    
    try {
      const result = await blitza.callStatic.swapCITForToken(AMOUNT_IN, AMOUNT_OUT_MIN, TOKEN_OUT_ADDRESS, DEADLINE);
      console.log("Static call result:", result);
    } catch (staticCallError) {
      console.error("Static call failed:", staticCallError.message);
      if (staticCallError.data) {
        try {
          const decodedStaticError = blitza.interface.parseError(staticCallError.data);
          console.error("Decoded static call error:", decodedStaticError);
        } catch (decodeError) {
          console.error("Failed to decode static call error:", decodeError);
        }
      }
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error in main execution:", error);
    process.exit(1);
  });