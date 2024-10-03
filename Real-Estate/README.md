# RealEstate Smart Contract

## Overview
The **RealEstate** smart contract is a decentralized solution for managing real estate properties on the Ethereum blockchain. It allows users to list properties for sale, purchase properties, and withdraw listings from sale. The contract is built using Solidity and is deployed on the **Lisk Sepolia** testnet.

## Features
- **List Property for Sale**: Users can list their properties with details such as price, name, description, and location.
- **Purchase Property**: Buyers can purchase properties by sending Ether, and ownership is transferred automatically.
- **Withdraw Property**: Owners can remove their properties from sale.
- **Events**: The contract emits events for property listing, purchase, and withdrawal.

## Technologies
- **Solidity Version**: 0.8.26
- **Network**: Lisk Sepolia testnet
- **Tools**:
  - [Hardhat](https://hardhat.org/)
  - [Blockscout](https://sepolia-blockscout.lisk.com/)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Lukman-01/Smart-Contract-Applications.git
   cd Real-Estate
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up your environment variables in a `.env` file:
   ```
   LISK_RPC_URL=your-lisk-sepolia-rpc-url
   PRIVATE_KEY=your-private-key
   ```

4. Compile the smart contracts:
   ```bash
   npx hardhat compile
   ```

5. Deploy the contract:
   ```bash
   npx hardhat ignition deploy ./ignition/modules/deploy.ts --network lisk-sepolia --verify
   ```

Deployed Addresses

RealEstateModule#RealEstate - 0x357BDC4DF7460135FA6B370484780EB860EF07cA

Verifying deployed contracts

Verifying contract "contracts/Real-Estate-Contract.sol:RealEstate" for network lisk-sepolia...
Successfully verified contract "contracts/Real-Estate-Contract.sol:RealEstate" for network lisk-sepolia:
  - https://sepolia-blockscout.lisk.com//address/0x357BDC4DF7460135FA6B370484780EB860EF07cA#code