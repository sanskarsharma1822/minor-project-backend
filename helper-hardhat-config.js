const networkConfig = {
    default: {
        name: "hardhat",
        keepersUpdateInterval: "86400",
    },
    31337: {
        name: "localhost",
        keepersUpdateInterval: "86400",
    },
    4: {
        name: "rinkeby",
        keepersUpdateInterval: "60",
    },
    80001: {
        name: "polygon",
        keepersUpdateInterval: "60",
    },
}

const INITIAL_ENTRY_TOKEN_URI =
    "https://ipfs.io/ipfs/QmZ7qzYAQh342RfvX2FbU68HoxjSvUGtC3mw1ucM4FwY6P?filename=testEntryURI.json" //reputation = 0 ; properties owned = 0 ; dealtokens = 0 ; warnings = 0;
const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    developmentChains,
    INITIAL_ENTRY_TOKEN_URI,
}

//Property - 3286636
//Admin - 2693777
//Property Factory - 3819541
