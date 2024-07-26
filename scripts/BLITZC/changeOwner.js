const { ethers } = require("hardhat");

async function main() {
  const [signer] = await ethers.getSigners();
  console.log("Executing with the account:", signer.address);

  // Replace with your deployed BLITZC contract address
  const contractAddress = "0x640323ea4BB94394516Bd18Ce1D39CC7697b62FF";
  // Replace with the address you want to transfer ownership to
  const newOwnerAddress = "0xb23F87AC8b0edBf373D5B86aD731a685059Ff478";

  // The ABI for the transferOwnership function
  const abi = [
    "function transferOwnership(address newOwner) public"
  ];

  // Create a contract instance
  const contract = new ethers.Contract(contractAddress, abi, signer);

  console.log("Transferring ownership of BLITZC contract:", contractAddress);
  console.log("New owner will be:", newOwnerAddress);

  // Get the current gas price using the provider
  const feeData = await ethers.provider.getFeeData();
  const gasPrice = feeData.gasPrice;

  // Increase gas price by 20% using explicit BigInt conversions
  const increasedGasPrice = gasPrice * BigInt(120) / BigInt(100);

  // Call the transferOwnership function with increased gas parameters
  const tx = await contract.transferOwnership(newOwnerAddress, {
    gasLimit: 100000n, // Use BigInt for gas limit
    gasPrice: increasedGasPrice // Use increased gas price as BigInt
  });

  console.log("Transaction sent. Waiting for confirmation...");

  // Wait for the transaction to be mined with a timeout
  const receipt = await tx.wait(5); // Wait for 5 confirmations

  console.log("Ownership transfer transaction hash:", tx.hash);
  console.log("Ownership has been transferred successfully.");
  console.log("Gas used:", receipt.gasUsed.toString());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error changing ownership:", error);
    process.exit(1);
  });