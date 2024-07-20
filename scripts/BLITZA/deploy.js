const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const balanceBigNumber = await ethers.provider.getBalance(deployer.address);
  const balance = ethers.formatEther(balanceBigNumber);
  console.log("Account balance before deployment:", balance);

  // Address of the PancakeSwap V3 SwapRouter
  const SWAP_ROUTER_ADDRESS = "0x9a489505a00cE272eAa5e07Dba6491314CaE3796"; // BSC Testnet PancakeSwap V3 SwapRouter

  // Compile and deploy the BLITZA contract
  const BLITZA = await ethers.getContractFactory("BLITZA");
  const blitza = await BLITZA.deploy(SWAP_ROUTER_ADDRESS);

  // Wait for the deployment to be mined
  await blitza.waitForDeployment();
  console.log("Transaction hash:", blitza.deploymentTransaction().hash);

  const blitzaAddress = await blitza.getAddress();
  console.log("BLITZA contract deployed to:", blitzaAddress);

  const balanceBigNumberAfter = await ethers.provider.getBalance(deployer.address);
  const balanceAfter = ethers.formatEther(balanceBigNumberAfter);
  console.log("Account balance after deployment:", balanceAfter);

  // Verify the initial swap router address
  const currentRouter = await blitza.getSwapRouter();
  console.log("Initial SwapRouter address:", currentRouter);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error deploying contract:", error);
    process.exit(1);
  });