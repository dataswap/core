import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import "@nomiclabs/hardhat-ethers";
import { deployAndSaveContract } from "../scripts/utils";
import { governanceAddress } from "../scripts/constants";

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments } = hre;
    const roles = await deployments.get("Roles");
    const filplus = await deployments.get("Filplus");
    const carstore = await deployments.get("Carstore");
    const datasets = await deployments.get("Datasets");
    const datasetsRequirement = await deployments.get("DatasetsRequirement");
    const datasetsProof = await deployments.get("DatasetsProof");
    const escrow = await deployments.get("Escrow");
    await deployAndSaveContract("MatchingsTarget", [governanceAddress, roles.address, filplus.address, carstore.address, datasets.address, datasetsRequirement.address, datasetsProof.address, escrow.address], hre);
};

export default deployFunction;

deployFunction.dependencies = ["Roles", "Filplus", "Carstore", "Datasets", "DatasetsRequirement", "DatasetsProof", "Escrow"];
deployFunction.tags = ["MatchingsTarget"];
