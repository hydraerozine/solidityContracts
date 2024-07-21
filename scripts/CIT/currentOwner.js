const { ethers } = require("hardhat");

async function main() {
  const [signer] = await ethers.getSigners();
  console.log("Executing with the account:", signer.address);

  const contractAddress = "0x5B557643E677608A7B13897d497a0e659dD6E127";

  // The ABI for the owner function
  const abi = [
    "function owner() public view returns (address)"
  ];

  // Create a contract instance
  const contract = new ethers.Contract(contractAddress, abi, signer);

  console.log("Fetching the current owner of the contract:", contractAddress);

  // Call the owner function
  const currentOwner = await contract.owner();

  console.log("The current owner of the contract is:", currentOwner);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error fetching the owner:", error);
    process.exit(1);
  });
