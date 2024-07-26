const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const balanceBigNumber = await ethers.provider.getBalance(deployer.address);
  const balance = ethers.formatEther(balanceBigNumber);
  console.log("Account balance before deployment:", balance);

  const tokenAddress = "0x34Bc6240266F24F178A39238175a6548d609B9B4";

  // Compile and deploy the TokenUserBalanceList contract
  const TokenUserBalanceList = await ethers.getContractFactory("TokenUserBalanceList");
  const tokenUserBalanceList = await TokenUserBalanceList.deploy(tokenAddress);

  // Wait for the deployment to be mined
  await tokenUserBalanceList.waitForDeployment();
  console.log("Transaction hash:", tokenUserBalanceList.deploymentTransaction().hash);

  console.log("TokenUserBalanceList contract deployed to:", tokenUserBalanceList.target);

  const balanceBigNumberAfter = await ethers.provider.getBalance(deployer.address);
  const balanceAfter = ethers.formatEther(balanceBigNumberAfter);
  console.log("Account balance after deployment:", balanceAfter);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error deploying contract:", error);
    process.exit(1);
  });