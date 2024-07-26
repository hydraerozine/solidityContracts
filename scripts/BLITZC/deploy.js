const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const balanceBigNumber = await ethers.provider.getBalance(deployer.address);
  const balance = ethers.formatEther(balanceBigNumber);
  console.log("Account balance before deployment:", balance);

  // Compile and deploy the BLITZC contract
  const BLITZC = await ethers.getContractFactory("BLITZC");
  const blitzc = await BLITZC.deploy();

  // Wait for the deployment to be mined
  await blitzc.waitForDeployment();
  console.log("Transaction hash:", blitzc.deploymentTransaction().hash);

  console.log("BLITZC contract deployed to:", blitzc.target);

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