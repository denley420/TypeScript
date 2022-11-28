import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomicfoundation/hardhat-chai-matchers';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';
import 'hardhat-gas-reporter';

import dotenv from 'dotenv';
dotenv.config();

// default values are there to avoid failures when running tests
const TESTNET_RPC = process.env.MUMBAI_RPC || '1'.repeat(32);
const MAINNET_RPC = process.env.MAINNET_RPC || '1'.repeat(32);
const PRIVATE_KEY = process.env.PRIVATE_KEY || '1'.repeat(64);

const config: HardhatUserConfig = {
    solidity: {
        version: '0.8.14',
        settings: {
            optimizer: {
                enabled: true,
                runs: 10000,
            },
        },
    },
    networks: {
        testnet: {
            url: TESTNET_RPC,
            accounts: [PRIVATE_KEY],
        },
        mainnet: {
            url: MAINNET_RPC,
            accounts: [PRIVATE_KEY],
        },
    },
    etherscan: {
        apiKey: process.env.POLYGONSCAN_API_KEY ?? '',
    },
    gasReporter: {
        enabled: true,
        currency: 'USD',
    },
    // contractSizer: {
    //     alphaSort: true,
    //     disambiguatePaths: false,
    //     runOnCompile: true,
    //     strict: true,
    //     // only: [':ERC20$'],
    // },
};

export default config;
