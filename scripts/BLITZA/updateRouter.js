const { ethers } = require("hardhat");

async function main() {
  // Address of your deployed BLITZA contract
  const BLITZA_ADDRESS = "0x439a7B0BBbC82Bb81B3c7E7cab1be9eCc2e725f9";
  
  // New router address (PancakeSwap V3 router)
  const NEW_ROUTER_ADDRESS = "0x9a489505a00cE272eAa5e07Dba6491314CaE3796";
  //SmartRouter
  //0x9a489505a00cE272eAa5e07Dba6491314CaE3796
  //Peripheral
  //0x1b81D678ffb9C0263b24A97847620C99d213eB14

  const [signer] = await ethers.getSigners();

  console.log("Updating router with the account:", signer.address);

  // Get the BLITZA contract instance
  const blitza = await ethers.getContractAt("BLITZA", BLITZA_ADDRESS);

  // Get the current router address
  let currentRouter;
  try {
    currentRouter = await blitza.getSwapRouter();
  } catch {
    currentRouter = await blitza.getSwapRouter();
  }
  console.log("Current PancakeSwap Router:", currentRouter);

  // Update the router
  console.log("Updating router address...");
  try {
    const updateTx = await blitza.updateRouter(NEW_ROUTER_ADDRESS);
    await updateTx.wait();
    console.log("Router update transaction hash:", updateTx.hash);

    // Verify the update
    let newRouter;
    try {
      newRouter = await blitza.getPancakeRouter();
    } catch {
      newRouter = await blitza.getSwapRouter();
    }
    console.log("New PancakeSwap Router:", newRouter);

    if (newRouter === NEW_ROUTER_ADDRESS) {
      console.log("Router address updated successfully!");
    } else {
      console.log("Router address update failed. Please check the transaction.");
    }
  } catch (error) {
    console.error("Failed to update router address. Error details:", error);
    
    if (error.data) {
      try {
        const decodedError = blitza.interface.parseError(error.data);
        console.error("Decoded error:", decodedError);
      } catch (decodeError) {
        console.error("Could not decode error data:", decodeError);
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