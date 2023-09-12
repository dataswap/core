import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import "@nomiclabs/hardhat-ethers";
import { deployAndSaveContract, getFilecoinNetwork } from "../scripts/utils";

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments } = hre;
    const roles = await deployments.get("Roles");
    const chainId = await hre.ethers.provider.getNetwork();
    const filecoinType = await getFilecoinNetwork(chainId.chainId);
    await deployAndSaveContract("Filecoin", [filecoinType, roles.address], hre);
};

export default deployFunction;

deployFunction.dependencies = ["Roles"];
deployFunction.tags = ["Filecoin"];
