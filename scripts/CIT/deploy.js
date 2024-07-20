const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const balanceBigNumber = await ethers.provider.getBalance(deployer.address);
  const balance = ethers.formatEther(balanceBigNumber);
  console.log("Account balance before deployment:", balance);

  // Compile and deploy the CIT token contract
  const CIT = await ethers.getContractFactory("CIT");
  const cit = await CIT.deploy();

  // Wait for the deployment to be mined
  await cit.waitForDeployment();
  console.log("Transaction hash:", cit.deploymentTransaction().hash);

  console.log("CIT token contract deployed to:", cit.target);

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
