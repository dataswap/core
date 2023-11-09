import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import "@nomiclabs/hardhat-ethers";
import { deployAndSaveContract } from "../scripts/utils";
import { governanceAddress } from "../scripts/constants";

const deployFunction: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments } = hre;
    const roles = await deployments.get("Roles");
    const datasetsProof = await deployments.get("DatasetsProof");
    const merkleUtils = await deployments.get("MerkleUtils");
    const escrow = await deployments.get("Escrow");
    await deployAndSaveContract("DatasetsChallenge", [governanceAddress, roles.address, datasetsProof.address, merkleUtils.address, escrow.address], hre);
};

export default deployFunction;

deployFunction.dependencies = ["Roles", "DatasetsProof", "MerkleUtils", "Escrow"];
deployFunction.tags = ["DatasetsChallenge"];
