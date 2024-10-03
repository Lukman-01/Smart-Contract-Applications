# Lottery Smart Contract

## Overview

The **Lottery** smart contract is a decentralized lottery system deployed on the Ethereum blockchain. Participants can join the lottery by paying exactly 1 ether, and the contract manager can randomly select a winner to receive the entire balance of the contract.

## Features

- **Participation**: Anyone can join the lottery by paying exactly 1 ether.
- **Random Winner Selection**: The contract manager can pick a winner randomly once at least 3 players have participated.
- **Security**: The contract includes a reentrancy guard to protect against reentrancy attacks.
- **Events**: The contract emits events when players join the lottery and when a winner is picked.

## Technologies

- **Solidity Version**: 0.8.26
- **Network**: Ethereum-compatible network (can be deployed on Ethereum testnets/mainnet)
- **Tools**:
  - [Hardhat](https://hardhat.org/)
  - Any Ethereum-compatible block explorer (e.g., Etherscan)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Lukman-01/Smart-Contract-Applications.git
   cd Lottery-Contract
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up your environment variables in a `.env` file (if needed):
   ```
   ETH_RPC_URL=your-ethereum-rpc-url
   PRIVATE_KEY=your-private-key
   ```

4. Compile the smart contract:
   ```bash
   npx hardhat compile
   ```

5. Deploy the contract:
   ```bash
   npx hardhat ignition deploy ./ignition/modules/deploy.ts --network lisk-sepolia --verify
   ```

Deployed Addresses

LotteryModule#Lottery - 0x88206940e27BEA394DbC851a34ac44b78B6ff553

Verifying deployed contracts

Verifying contract "contracts/Lottery.sol:Lottery" for network lisk-sepolia...
Successfully verified contract "contracts/Lottery.sol:Lottery" for network lisk-sepolia:
  - https://sepolia-blockscout.lisk.com//address/0x88206940e27BEA394DbC851a34ac44b78B6ff553#
  
### Authors

Abdulyekeen Lukman(Ibukun)