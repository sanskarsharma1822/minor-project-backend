const { ethers, network } = require("hardhat")
const fs = require("fs")

const PROPERTY_ABI_FILE = "../property-rental-frontend/src/constants/Property/propertyABI.json"

module.exports = async function () {
    console.log("Updating property abi ...")
    await updateAbi()
    console.log("----------------------------------------------------")
}

const updateAbi = async function () {
    const lottery = await ethers.getContract("Property")
    fs.writeFileSync(PROPERTY_ABI_FILE, lottery.interface.format(ethers.utils.FormatTypes.json))
}
