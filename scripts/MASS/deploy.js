const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const balanceBigNumber = await ethers.provider.getBalance(deployer.address);
  const balance = ethers.formatEther(balanceBigNumber);
  console.log("Account balance before deployment:", balance);

  // Address of the RAA token contract
  const raaTokenAddress = "0xaCe069Cc75C49De1B7D12BD31Da8AE3Be7A7e073";

  // Compile and deploy the MASS contract
  const MASS = await ethers.getContractFactory("MASS");
  const mass = await MASS.deploy(raaTokenAddress);

  // Wait for the deployment to be mined
  await mass.waitForDeployment();
  console.log("Transaction hash:", mass.deploymentTransaction().hash);

  console.log("MASS contract deployed to:", mass.target);

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

  //npx hardhat run scripts/MASS/sendcsv.js --network bscTestnet