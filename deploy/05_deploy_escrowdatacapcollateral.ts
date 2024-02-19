import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import "@nomiclabs/hardhat-ethers";
import { deployAndSaveContract } from "../scripts/utils";

const deployFunction: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments } = hre;
  const roles = await deployments.get("Roles");
  await deployAndSaveContract("EscrowDatacapCollateral", [roles.address], hre);
};

export default deployFunction;

deployFunction.dependencies = ["Roles"];
deployFunction.tags = ["EscrowDatacapCollateral"];
