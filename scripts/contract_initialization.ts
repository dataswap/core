import { network } from "hardhat"

async function main(): Promise<void> {

    console.log("Starting initialization contract...")

    const hre = require("hardhat")
    const { deployments, getNamedAccounts } = hre
    const { read, execute } = deployments
    const { deployer } = await getNamedAccounts()
    const contracts = [
        // consistent with ContractType order! https://github.com/dataswap/core/blob/main/src/v0.8/types/RolesType.sol
        "Filplus",
        "Finance",
        "Filecoin",
        "Carstore",
        "Storages",
        "MerkleUtils",
        "Datasets",
        "DatasetsProof",
        "DatasetsChallenge",
        "DatasetsRequirement",
        "Matchings",
        "MatchingsBids",
        "MatchingsTarget",
        "EscrowDataTradingFee",
        "EscrowDatacapChunkLandCollateral",
        "EscrowDatacapCollateral",
        "EscrowChallengeCommission",
    ]

    for (let i = 0; i < contracts.length; i++) {
        const dynamicJson = await import(
            "../deployments" + "/" + network.name + "/" + contracts[i] + ".json"
        )
        console.log(
            "Contract: ",
            contracts[i],
            "Address: ",
            dynamicJson.default.address
        )

        await execute(
            "Roles",
            { from: deployer },
            "registerContract",
            i,
            dynamicJson.default.address
        )

        const value = await read(
            "Roles",
            contracts[i].charAt(0).toLowerCase() + contracts[i].slice(1)
        )
        console.log("registerContract: ", contracts[i], ": ", value.toString())
    }

    console.log("End initialization contract...")
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
