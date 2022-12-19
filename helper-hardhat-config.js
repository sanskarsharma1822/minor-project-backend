const networkConfig = {
    default: {
        name: "hardhat",
    },
    31337: {
        name: "localhost",
    },
    4: {
        name: "rinkeby",
    },
    80001: {
        name: "polygon",
    },
    5: {
        name: "goerli",
    },
}

// const INITIAL_ENTRY_TOKEN_URI =
//      //reputation = 0 ; properties owned = 0 ; dealtokens = 0 ; warnings = 0;

const developmentChains = ["hardhat", "localhost"]

const sampleProperty = {
    propertyData:
        "https://ipfs.io/ipfs/QmZ7qzYAQh342RfvX2FbU68HoxjSvUGtC3mw1ucM4FwY6P?filename=testEntryURI.json",
    propertyRent: 25,
    propertySecurity: 50,
}

module.exports = {
    networkConfig,
    developmentChains,
    sampleProperty,
}

//Property - 3286636
//Admin - 2693777
//Property Factory - 3819541
