import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import "@nomiclabs/hardhat-ethers";
import { deployAndSaveContract } from "../scripts/utils";
import { governanceAddress } from "../scripts/constants";

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments } = hre;
    const roles = await deployments.get("Roles");
    const escrow = await deployments.get("Escrow");
    await deployAndSaveContract("Datasets", [governanceAddress, roles.address, escrow.address], hre);
};

export default deployFunction;

deployFunction.dependencies = ["Roles", "Escrow"];
deployFunction.tags = ["Datasets"];
