import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    goerli: {
      url: 'https://eth-goerli.g.alchemy.com/v2/PtOW84EIMyfAaX93sYECGs_QLonqicN8',
      accounts: ['8431b27ab2ba78ecc97181e3baf0defe507b490a78ecbb7b25f0e4621278d66f'],
    },
  },
};

export default config;
