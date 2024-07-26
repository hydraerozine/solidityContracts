const { ethers } = require("hardhat");

async function main() {
  const [signer] = await ethers.getSigners();
  console.log("Executing with the account:", signer.address);

  // Replace with your deployed BLITZC contract address
  const contractAddress = "0x640323ea4BB94394516Bd18Ce1D39CC7697b62FF";

  // The ABI for the owner function
  const abi = [
    "function owner() public view returns (address)"
  ];

  // Create a contract instance
  const contract = new ethers.Contract(contractAddress, abi, signer);

  console.log("Checking owner of BLITZC contract:", contractAddress);

  try {
    // Call the owner function
    const currentOwner = await contract.owner();

    console.log("Current owner of the contract:", currentOwner);
  } catch (error) {
    console.error("Error fetching owner:", error.message);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error checking ownership:", error);
    process.exit(1);
  });