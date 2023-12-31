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
    const matchings = await deployments.get("Matchings");
    const matchingsTarget = await deployments.get("MatchingsTarget");
    const matchingsBids = await deployments.get("MatchingsBids");
    const storages = await deployments.get("Storages");
    const escrow = await deployments.get("Escrow");
    await deployAndSaveContract("Datacaps", [governanceAddress, roles.address, filplus.address, filecoin.address, carstore.address, datasets.address, matchings.address,
        matchingsTarget.address, matchingsBids.address, storages.address, escrow.address], hre);
};

export default deployFunction;

deployFunction.dependencies = ["Roles", "Filecoin", "Filplus", "Carstore", "Datasets", "Matchings", "MatchingsTarget", "MatchingsBids", "Storages", "Escrow"];
deployFunction.tags = ["Datacaps"];
