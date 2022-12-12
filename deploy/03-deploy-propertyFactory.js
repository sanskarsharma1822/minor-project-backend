const { getNamedAccounts, deployments, network, run, ethers } = require("hardhat")
const {
    networkConfig,
    developmentChains,
    INITIAL_ENTRY_TOKEN_URI,
} = require("../helper-hardhat-config")
// const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    console.log("Deploying Property Factory Contract")
    const propertyFactory = await deploy("PropertyFactory", {
        from: deployer,
        args: [],
        log: true,
    })
    console.log("----------------------------------------------------")
}

// Verify the deployment
// if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
//     log("Verifying...")
//     await verify(admin.address, arguments)
// }

module.exports.tags = ["all", "propertyFactory"]
