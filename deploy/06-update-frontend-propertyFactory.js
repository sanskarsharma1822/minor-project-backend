const { ethers, network } = require("hardhat")
const fs = require("fs")

const PROPERTYFACTORY_CONTRACT_ADDRESS_FILE =
    "../property-rental-frontend/src/constants/PropertyFactory/propertyFactoryContractAddress.json"
const PROPERTYFACTORY_ABI_FILE =
    "../property-rental-frontend/src/constants/PropertyFactory/propertyFactoryABI.json"

module.exports = async function () {
    console.log("Updating propertyFactory address & abi ...")
    await updateContractAddresses()
    await updateAbi()
}

const updateAbi = async function () {
    const lottery = await ethers.getContract("PropertyFactory")
    fs.writeFileSync(
        PROPERTYFACTORY_ABI_FILE,
        lottery.interface.format(ethers.utils.FormatTypes.json)
    )
}
const updateContractAddresses = async function () {
    const admin = await ethers.getContract("PropertyFactory")
    const chainId = network.config.chainId.toString()
    const currentAddresses = JSON.parse(
        fs.readFileSync(PROPERTYFACTORY_CONTRACT_ADDRESS_FILE, "utf8")
    )
    if (chainId in currentAddresses) {
        if (!currentAddresses[chainId].includes(admin.address)) {
            currentAddresses[chainId].push(admin.address)
        }
    } else {
        currentAddresses[chainId] = [admin.address]
    }
    fs.writeFileSync(PROPERTYFACTORY_CONTRACT_ADDRESS_FILE, JSON.stringify(currentAddresses))
    console.log("----------------------------------------------------")
}
