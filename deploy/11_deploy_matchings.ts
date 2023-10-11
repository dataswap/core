import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import "@nomiclabs/hardhat-ethers";
import { deployAndSaveContract } from "../scripts/utils";
import { governanceAddress } from "../scripts/constants";

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments } = hre;
    const roles = await deployments.get("Roles");
    const datasetsRequirement = await deployments.get("DatasetsRequirement");
    await deployAndSaveContract("Matchings", [governanceAddress, roles.address, datasetsRequirement.address], hre);
};

export default deployFunction;

deployFunction.dependencies = ["Roles", "DatasetsRequirement"];
deployFunction.tags = ["Matchings"];
