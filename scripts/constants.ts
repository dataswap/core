import { ethers } from "hardhat";
/// @notice constants paramter for deploy
export const governanceAddress = async (): Promise<string> => {
    const accounts = await ethers.getSigners();
    return accounts[0].getAddress()
}