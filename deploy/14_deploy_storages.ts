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
    const matchings = await deployments.get("Matchings");
    const matchingsTarget = await deployments.get("MatchingsTarget");
    const matchingsBids = await deployments.get("MatchingsBids");
    const escrow = await deployments.get("Escrow");
    const datasets = await deployments.get("Datasets");
    await deployAndSaveContract("Storages", [governanceAddress, roles.address, filplus.address, filecoin.address, carstore.address, matchings.address, matchingsTarget.address, matchingsBids.address, escrow.address, datasets.address], hre);
};

export default deployFunction;

deployFunction.dependencies = ["Roles", "Filecoin", "Filplus", "Carstore", "Matchings", "MatchingsTarget", "MatchingsBids", "Escrow", "Datasets"];
deployFunction.tags = ["Storages"];
