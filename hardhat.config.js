require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.26",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.4.18",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  defaultNetwork: "ethereumMainnet",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    goerliTestnet: {
      url: process.env.QUICKNODE_TESTNET_RPC_GOERLI,
      gasPrice: "auto",
      accounts: [`0x${process.env.PK1}`],
    },
    sepolia: {
      url: process.env.ARB_TEST,
      gasPrice: "auto",
      accounts: [`0x${process.env.PK1}`],
    },
    ethereumMainnet: {
      url: process.env.MAINNET_ETHEREUM,
      gasPrice: "auto",
      accounts: [`0x${process.env.PK1}`],
    },
    bscTestnet: {
      url: process.env.TESTNET_BSC,
      gasPrice: "auto",
      accounts: [`0x${process.env.PK1}`],
      gas: 2000000,  // Increase this value
      gasPrice: 10000000000,
    },
    bscMainnet: {
      url: process.env.MAINNET_BSC,
      gasPrice: "auto",
      accounts: [`0x${process.env.PK1}`],
    },
    skaleNebula: {
      url: process.env.SKALE_NEBULA,
      gasPrice: "auto",
      accounts: [`0x${process.env.PK1}`],
    },
    rootStockMain: {
      url: process.env.RSK_MAINNET_RPC_URL,
      gasPrice: "auto",
      accounts: [`0x${process.env.PK1}`],
    },
    rootStockTest: {
      url: process.env.RSK_TESTNET_RPC_URL,
      gasPrice: "auto",
      accounts: [`0x${process.env.PK1}`],
    },
    arbMain: {
      url: process.env.ARB_MAIN,
      gasPrice: "auto",
      accounts: [`0x${process.env.PKA1}`],
    },
    eclipse: {
      url: process.env.ECLIPSE_TESTNET_RPC_URL,
      gasPrice: "auto",
      accounts: [`0x${process.env.PK1}`],
    },
  },
  etherscan: {
    apiKey: process.env.BSC_ETHERSCAN_API_KEY,
  },
  mocha: {
    timeout: 20000,
  },
};

//npx hardhat verify --network bscMainnet 0x914298d8Eed75214A7001e53D3Ed6b2D87cD8cD8 "0x5087AfA51c7E0383A70b5D1369DF812B38f8E453" "0xe16fE62e009961682F3a7F42642F36F5E46962F8"

//npx hardhat run scripts/CIT/deploy.js --network bscMainnet

//npx hardhat verify --network bscMainnet 0x1142D06DeD7348C5E0b78A53ADa7BBf115484739

//npx hardhat verify --network bscMainnet --contract contracts/CIT.sol:CIT 0x1142D06DeD7348C5E0b78A53ADa7BBf115484739
