import "hardhat-deploy";
import "hardhat-preprocessor";
import "@nomiclabs/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades";
import "@nomicfoundation/hardhat-ledger";
import "@nomicfoundation/hardhat-toolbox";

import { HardhatUserConfig, task } from "hardhat/config";

import * as fs from "fs";
import * as dotenv from "dotenv";
dotenv.config();

task("upgrade", "Upgrade a contract")
  .addParam("address", "The proxy Contract's address")
  .addParam("name", "The new implementation contract name")
  .setAction(async (taskArgs, hre) => {
    const newImplementationContract = await hre.ethers.getContractFactory(taskArgs.name as string);
    await hre.upgrades.upgradeProxy(taskArgs.address, newImplementationContract);
    console.log(`Contract upgraded to new implementation: ${taskArgs.name}`);
  });

task("getProxyAddress", "Get a contract proxy address")
  .addParam("type", "The deployment network")
  .addParam("name", "The new implementation contract name")
  .setAction(async (taskArgs, hre) => {
    const dynamicJson = await import('./deployments' + '/' + taskArgs.type + '/' + taskArgs.name + '.json');
    console.log(dynamicJson.default.address);
  });


function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean) // remove empty lines
    .map((line) => line.trim().split("="));
}

const config: HardhatUserConfig = {
  namedAccounts: {
    deployer: {
      default: 0,
    },
    dev: {
      default: 1,
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.21",
        settings: {
          optimizer: {
            enabled: true,
            runs: 0,
            details: {
              yul: false,
              constantOptimizer: true,
            },
          },
        },
      },
    ],
  },
  defaultNetwork: "localnet",
  networks: {
    hardhat: {},
    development: {
      url: "http://0.0.0.0:8545",
      chainId: 1337,
    },
    localnet: {
      url: "http://127.0.0.1:1234/rpc/v1",
      chainId: 31415926,
      accounts: [`${process.env.PRIVATE_KEY}`],
      saveDeployments: true,
      // gasPrice: 100000000,
      // gasMultiplier: 8000,
      live: true,
    },
    filecoin: {
      url: `${process.env.FILECOIN_MAINNET_RPC_URL}`,
      chainId: 314,
      ledgerAccounts: [`${process.env.DEPLOYER_ADDRESS}`],
      live: true,
      saveDeployments: true,
      timeout: 2600000,
    },
    calibration: {
      url: `${process.env.CALIBRATION_RPC_URL}`,
      chainId: 314159,
      accounts: [`${process.env.PRIVATE_KEY}`],
      //ledgerAccounts: [`${process.env.DEPLOYER_ADDRESS}`],
      live: true,
      saveDeployments: true,
      timeout: 2600000,
    },
  },
  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          for (const [from, to] of getRemappings()) {
            if (line.includes(from)) {
              line = line.replace(from, to);
              break;
            }
          }
        }
        return line;
      },
    }),
  },
  paths: {
    artifacts: './artifacts',
    cache: './cache-hardhat',
    sources: './src',
    tests: './hardhat/v0.8',
  },
};

export default config;
