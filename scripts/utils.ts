import { Contract, ContractFactory } from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";

enum Network {
	Mainnet,
	Localnet,
	CalibrationTestnet
}

export const getFilecoinNetwork = async (chainId: number): Promise<Network> => {
	if (chainId == 31415926) {
		return Network.Localnet;
	} else if (chainId == 314159) {
		return Network.CalibrationTestnet;
	} else {
		return Network.Mainnet;
	}
};

export const deployAndSaveContract = async (name: string, args: unknown[], hre: HardhatRuntimeEnvironment): Promise<void> => {
	const { ethers, deployments, upgrades } = hre;
	const { save } = deployments;

	let Factory: ContractFactory = await ethers.getContractFactory(name);

	let contract: Contract = await upgrades.deployProxy(Factory, args, {
		initializer: "initialize",
		unsafeAllow: ["delegatecall"],
		kind: "uups",
		timeout: 1000000,
	});
	await contract.deployed();

	console.log(name + " Address---> " + contract.address);

	const implAddr = await contract.getImplementation();
	console.log("Implementation address for " + name + " is " + implAddr);

	const artifact = await deployments.getExtendedArtifact(name);
	let proxyDeployments = {
		address: contract.address,
		...artifact,
	};

	await save(name, proxyDeployments);
};
