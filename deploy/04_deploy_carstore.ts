import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import "@nomiclabs/hardhat-ethers";
import { deployAndSaveContract } from "../scripts/utils";

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments } = hre;
    const roles = await deployments.get("Roles");
    const filecoin = await deployments.get("Filecoin");
    const filplus = await deployments.get("Filplus");
    await deployAndSaveContract("Carstore", [roles.address, filplus.address, filecoin.address], hre);
};

export default deployFunction;

deployFunction.dependencies = ["Roles", "Filecoin", "Filplus"];
deployFunction.tags = ["Carstore"];
