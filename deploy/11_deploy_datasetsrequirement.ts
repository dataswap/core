import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import "@nomiclabs/hardhat-ethers";
import { deployAndSaveContract } from "../scripts/utils";
import { governanceAddress } from "../scripts/constants";

const deployFunction: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments } = hre;
  const roles = await deployments.get("Roles");
  const filplus = await deployments.get("Filplus");
  const datasets = await deployments.get("Datasets");
  const finance = await deployments.get("Finance");
  await deployAndSaveContract(
    "DatasetsRequirement",
    [
      governanceAddress,
      roles.address,
      filplus.address,
      datasets.address,
      finance.address,
    ],
    hre
  );
};

export default deployFunction;

deployFunction.dependencies = ["Roles", "Filplus", "Datasets", "Finance"];
deployFunction.tags = ["DatasetsRequirement"];
