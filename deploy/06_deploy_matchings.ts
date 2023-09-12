import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import "@nomiclabs/hardhat-ethers";
import { deployAndSaveContract } from "../scripts/utils";
import { governanceAddress } from "../scripts/constants";

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments } = hre;
    const roles = await deployments.get("Roles");
    const filecoin = await deployments.get("Filecoin");
    const filplus = await deployments.get("Filplus");
    const carstore = await deployments.get("Carstore");
    const datasets = await deployments.get("Datasets");
    await deployAndSaveContract("Matchings", [governanceAddress, roles.address, filplus.address, filecoin.address, carstore.address, datasets.address], hre);
};

export default deployFunction;

deployFunction.dependencies = ["Roles", "Filecoin", "Filplus", "Carstore", "Datasets"];
deployFunction.tags = ["Matchings"];
