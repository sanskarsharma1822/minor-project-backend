require("@nomicfoundation/hardhat-toolbox")
require("hardhat-deploy")
require("dotenv").config()

const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL
const POLYGON_RPC_URL = process.env.POLYGON_RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        compilers: [
            {
                version: "0.8.7",
            },
        ],
    },
    networks: {
        localhost: {
            chainId: 31337,
        },
        goerli: {
            url: GOERLI_RPC_URL,
            accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
            chainId: 5,
        },
        polygon: {
            url: POLYGON_RPC_URL,
            accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
            chainId: 80001,
        },
    },
    defaultNetwork: "hardhat",
    namedAccounts: {
        deployer: {
            default: 0,
        },
        player: {
            default: 1,
        },
    },
    // etherscan: {
    //     // yarn hardhat verify --network <NETWORK> <CONTRACT_ADDRESS> <CONSTRUCTOR_PARAMETERS>
    //     apiKey: {
    //         polygon: POLYGONSCAN_API_KEY,
    //         goerli: ETHERSCAN_API_KEY,
    //     },
    // },
    // gasReporter: {
    //     enabled: REPORT_GAS,
    //     currency: "USD",
    //     outputFile: "gas-report.txt",
    //     noColors: true,
    //     // coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    // },
    // contractSizer: {
    //     runOnCompile: false,
    //     only: [
    //         "APIConsumer",
    //         "AutomationCounter",
    //         "NFTFloorPriceConsumerV3",
    //         "PriceConsumerV3",
    //         "RandomNumberConsumerV2",
    //     ],
    // },
    // paths: {
    //     sources: "./contracts",
    //     tests: "./test",
    //     cache: "./build/cache",
    //     artifacts: "./build/artifacts",
    // },
    mocha: {
        timeout: 200000, // 200 seconds max for running tests
    },
}
