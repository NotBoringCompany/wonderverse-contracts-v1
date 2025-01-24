import { vars, type HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import * as dotenv from "dotenv";

dotenv.config();

const deployerWallet: string = process.env.DEPLOYER_PRIVATE_KEY ?? '';
const testDeployerWallet: string = process.env.TEST_DEPLOYER_PRIVATE_KEY ?? '';
const ETHERSCAN_API_KEY = vars.get("ETHERSCAN_API_KEY");

const config: HardhatUserConfig = {
  etherscan: {
    apiKey: {
      kairos: 'unnecessary',
    },
    customChains: [
      {
        network: "kairos",
        chainId: 1001,
        urls: {
          apiURL: "https://api-baobab.klaytnscope.com/api",
          browserURL: "https://kairos.kaiascope.com",
        },
      },
      {
        network: "kaia",
        chainId: 8217,
        urls: {
          apiURL: "https://api.kaia.klaytnscope.com/api",
          browserURL: "https://mainnet.kaiascope.com",
        }
      }
    ]
  },
  networks: {
    kaia: {
      url: `https://kaia.blockpi.network/v1/rpc/public`,
      chainId: 8217,
      accounts: [`0x${deployerWallet}`],
    },
    blastSepolia: {
      url: "https://sepolia.blast.io",
      accounts: [`0x${deployerWallet}`],
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_KEY}`,
      chainId: 11155111,
      accounts: [`0x${deployerWallet}`],
      gasPrice: "auto",
    },
    baseSepolia: {
      url: `https://sepolia.base.org`,
      chainId: 84532,
      accounts: [`0x${deployerWallet}`],
    },
    kairos: {
      url: `https://kaia-kairos.blockpi.network/v1/rpc/public`,
      chainId: 1001,
      accounts: [`0x${deployerWallet}`],
    }
  },
  solidity: {
    version: "0.8.26",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      evmVersion: "cancun",
      viaIR: true,
    }
  }
};

export default config;
