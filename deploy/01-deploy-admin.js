const { getNamedAccounts, deployments, network, run, ethers } = require("hardhat")
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const imageToBase64 = require("image-to-base64")

const {
    storeImages,
    storeTokenUriMetadata,
    convertImgToBase64,
} = require("../utils/uploadToPinata")
const imagesLocation = "./images/entryToken/"
// const { verify } = require("../utils/verify")

const metadataTemplate = {
    name: "",
    description: "",
    image: "",
    attributes: [
        {
            reputation: 100,
            dealTokens: [],
            propertiesOwned: [],
            currentlyTenant: false,
        },
    ],
}

// array of property addresses owned

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    let initialTokenURI
    if (true) {
        initialTokenURI = await handleTokenUris()
    }
    console.log("Deploying Admin Contract")
    const arguments = initialTokenURI
    const admin = await deploy("Admin", {
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

async function handleTokenUris() {
    tokenUris = []
    const { responses: imageUploadResponses, files } = await storeImages(imagesLocation)
    for (imageUploadResponseIndex in imageUploadResponses) {
        let tokenUriMetadata = { ...metadataTemplate }
        tokenUriMetadata.name = files[imageUploadResponseIndex].replace(".png", "")
        tokenUriMetadata.description =
            "This token verifies that the individual is a user of the Rent Website."
        tokenUriMetadata.image = `https://ipfs.io/ipfs/${imageUploadResponses[imageUploadResponseIndex].IpfsHash}`
        console.log(`Uploading ${tokenUriMetadata.name}...`)
        const metadataUploadResponse = await storeTokenUriMetadata(tokenUriMetadata)
        tokenUris.push(`https://ipfs.io/ipfs/${metadataUploadResponse.IpfsHash}`)
    }
    console.log("Token URI uploaded! It is :")
    console.log(tokenUris)
    return tokenUris
}

module.exports.tags = ["all", "admin"]
