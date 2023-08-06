import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.21",
  paths: {
    artifacts: './artifacts',
    cache: './cache-hardhat',
    sources: './src',
    tests: './test',
  },
};

export default config;
