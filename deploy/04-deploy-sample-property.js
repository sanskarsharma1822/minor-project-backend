const { getNamedAccounts, deployments, network, run, ethers } = require("hardhat")
const { networkConfig, developmentChains, sampleProperty } = require("../helper-hardhat-config")
// const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    const arguments = [
        sampleProperty["propertyData"],
        sampleProperty["propertyRent"],
        sampleProperty["propertySecurity"],
        deployer,
    ]

    console.log("Deploying Sample Property Contract")
    const propertyFactory = await deploy("Property", {
        from: deployer,
        args: arguments,
        log: true,
    })
    console.log("----------------------------------------------------")
}

// Verify the deployment
// if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
//     log("Verifying...")
//     await verify(admin.address, arguments)
// }

module.exports.tags = ["all", "property"]
