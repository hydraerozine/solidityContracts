const { ethers } = require("hardhat");
const fs = require('fs');

async function main() {
  const [signer] = await ethers.getSigners();
  console.log("Executing with the account:", signer.address);

  // Address of the deployed MASS contract
  const massContractAddress = "0x31c627ADb3fD72AB2F9bE8fa1ED06a3010Ab0b6C";

  // ABI of the MASS contract (you need to have this)
  const massABI = [
    "function massTransfer(address[] memory recipients, uint256[] memory amounts) external"
  ];

  // Create a contract instance
  const massContract = new ethers.Contract(massContractAddress, massABI, signer);

  // Read the data from the file
  const data = fs.readFileSync('paste.txt', 'utf8');
  const lines = data.split('\n');

  const recipients = [];
  const amounts = [];

  lines.forEach(line => {
    const [address, amount] = line.split('\t');
    if (ethers.isAddress(address)) {
      recipients.push(address);
      // Convert amount to wei (assuming 18 decimals)
      amounts.push(ethers.parseUnits(amount, 18));
    }
  });

  console.log("Number of recipients:", recipients.length);

  // Split into batches of 100 to avoid gas limit issues
  const batchSize = 100;
  for (let i = 0; i < recipients.length; i += batchSize) {
    const recipientsBatch = recipients.slice(i, i + batchSize);
    const amountsBatch = amounts.slice(i, i + batchSize);

    console.log(`Processing batch ${i / batchSize + 1}`);

    // Call the massTransfer function
    const tx = await massContract.massTransfer(recipientsBatch, amountsBatch);
    console.log("Transaction sent. Waiting for confirmation...");

    // Wait for the transaction to be mined
    const receipt = await tx.wait();
    console.log(`Batch ${i / batchSize + 1} processed. Transaction hash:`, receipt.transactionHash);
  }

  console.log("All transfers completed.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error executing mass transfer:", error);
    process.exit(1);
  });