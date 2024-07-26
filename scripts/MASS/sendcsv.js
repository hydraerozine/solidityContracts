const { ethers } = require("hardhat");
const fs = require('fs');
const csv = require('csv-parser');
const path = require('path');

function parseAmount(amount) {
  try {
    const floatAmount = parseFloat(amount);
    if (isNaN(floatAmount)) {
      throw new Error(`Invalid amount: ${amount}`);
    }
    const decimalStr = floatAmount.toFixed(18).replace(/\.?0+$/, "");
    return ethers.parseUnits(decimalStr, 18);
  } catch (error) {
    console.error(`Error parsing amount: ${amount}`, error);
    return ethers.parseUnits("0", 18);
  }
}

async function readCSV(filePath) {
  return new Promise((resolve, reject) => {
    const recipients = [];
    const amounts = [];
    fs.createReadStream(filePath)
      .pipe(csv())
      .on('data', (row) => {
        const address = row['address'];
        const amount = row['amount'];
        if (ethers.isAddress(address)) {
          recipients.push(address);
          amounts.push(parseAmount(amount));
        } else {
          console.warn(`Invalid address: ${address}`);
        }
      })
      .on('end', () => {
        resolve({ recipients, amounts });
      })
      .on('error', (error) => reject(error));
  });
}

async function main() {
  try {
    const [signer] = await ethers.getSigners();
    console.log("Executing with the account:", signer.address);

    const massContractAddress = "0xa18754ECC6bE8Bf505Ec2AD928Bd1a815840DEf4";
    const raaTokenAddress = "0xaCe069Cc75C49De1B7D12BD31Da8AE3Be7A7e073";

    const raaABI = [
      "function balanceOf(address account) view returns (uint256)",
      "function transfer(address to, uint256 amount) returns (bool)",
      "function approve(address spender, uint256 amount) returns (bool)"
    ];

    const massABI = [
      "function massTransfer(address[] memory recipients, uint256[] memory amounts) external",
      "function balanceOf(address account) view returns (uint256)"
    ];

    const raaContract = new ethers.Contract(raaTokenAddress, raaABI, signer);
    const massContract = new ethers.Contract(massContractAddress, massABI, signer);

    const signerRAABalance = await raaContract.balanceOf(signer.address);
    console.log("RAA Balance of signer:", ethers.formatUnits(signerRAABalance, 18), "RAA");

    const massContractRAABalance = await raaContract.balanceOf(massContractAddress);
    console.log("RAA Balance in MASS contract:", ethers.formatUnits(massContractRAABalance, 18), "RAA");

    const csvPath = path.join(__dirname, 'cleaned_mass.csv');
    const { recipients, amounts } = await readCSV(csvPath);
    console.log("Number of recipients:", recipients.length);

    const totalAmount = amounts.reduce((a, b) => a + b, BigInt(0));
    console.log("Total RAA to be transferred:", ethers.formatUnits(totalAmount, 18), "RAA");

    if (massContractRAABalance < totalAmount) {
      const amountToTransfer = totalAmount - massContractRAABalance;
      console.log("Transferring", ethers.formatUnits(amountToTransfer, 18), "RAA to MASS contract");

      const approveTx = await raaContract.approve(massContractAddress, amountToTransfer);
      await approveTx.wait();
      console.log("Approval transaction completed");

      const transferTx = await raaContract.transfer(massContractAddress, amountToTransfer);
      await transferTx.wait();
      console.log("Transfer to MASS contract completed");

      const newMassContractRAABalance = await raaContract.balanceOf(massContractAddress);
      console.log("New RAA Balance in MASS contract:", ethers.formatUnits(newMassContractRAABalance, 18), "RAA");
    }

    console.log("Proceeding with mass transfer");
    const batchSize = 100;
    for (let i = 0; i < recipients.length; i += batchSize) {
      const recipientsBatch = recipients.slice(i, i + batchSize);
      const amountsBatch = amounts.slice(i, i + batchSize);
      console.log(`Processing batch ${Math.floor(i / batchSize) + 1} of ${Math.ceil(recipients.length / batchSize)}`);

      try {
        const tx = await massContract.massTransfer(recipientsBatch, amountsBatch);
        console.log("Transaction sent. Waiting for confirmation...");
        const receipt = await tx.wait();
        console.log(`Batch ${Math.floor(i / batchSize) + 1} processed. Transaction hash:`, receipt.transactionHash);
      } catch (error) {
        console.error(`Error processing batch ${Math.floor(i / batchSize) + 1}:`, error);
        continue;
      }
    }

    console.log("All transfers completed.");
  } catch (error) {
    console.error("Error executing transfers:", error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Unhandled error:", error);
    process.exit(1);
  });
