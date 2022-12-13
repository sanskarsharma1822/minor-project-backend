const { getNamedAccounts, deployments, network, run, ethers } = require("hardhat")
const {
    networkConfig,
    developmentChains,
    INITIAL_ENTRY_TOKEN_URI,
} = require("../helper-hardhat-config")

const { storeImages, storeTokenUriMetadata } = require("../utils/uploadToPinata")
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
            currentlyOnRent: false,
        },
    ],
}

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
        tokenUriMetadata.description = `An adorable ${tokenUriMetadata.name} pup!`
        tokenUriMetadata.image = `ipfs://${imageUploadResponses[imageUploadResponseIndex].IpfsHash}`
        console.log(`Uploading ${tokenUriMetadata.name}...`)
        const metadataUploadResponse = await storeTokenUriMetadata(tokenUriMetadata)
        tokenUris.push(`ipfs://${metadataUploadResponse.IpfsHash}`)
    }
    console.log("Token URIs uploaded! They are:")
    console.log(tokenUris)
    return tokenUris
}

module.exports.tags = ["all", "admin"]
