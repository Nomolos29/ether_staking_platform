import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
dotenv.config();

const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    hardhat: {
      forking: {
        url: `${ALCHEMY_API_KEY}`, 
      }
    },

    'lisk-sepolia': {
      url: `${process.env.LISK_API_KEY}`,
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
  },

  etherscan: {
    // Use "123" as a placeholder, because Blockscout doesn't need a real API key, and Hardhat will complain if this property isn't set.
    apiKey: {
      "lisk-sepolia": "123"
    },
    customChains: [
      {
          network: "lisk-sepolia",
          chainId: 4202,
          urls: {
              apiURL: "https://sepolia-blockscout.lisk.com/api",
              browserURL: "https://sepolia-blockscout.lisk.com"
          }
      }
    ]
  },
  sourcify: {
    enabled: false
  },


};

export default config;