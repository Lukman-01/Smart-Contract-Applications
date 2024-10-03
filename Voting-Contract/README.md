# Voting Smart Contract

## Overview

The **Voting** smart contract is a decentralized application deployed on the **Lisk** blockchain, designed to manage candidates and voters in an election. The contract ensures a secure and transparent voting process by allowing only the contract owner to register candidates and voters.

## Features

- **Candidate Registration**: Only the contract owner can register candidates, who are assigned unique IDs along with their details.
- **Voter Registration**: The contract owner can register voters, ensuring only authorized individuals can participate in voting.
- **Voting Mechanism**: Registered voters can cast their votes for candidates, automatically updating the vote counts.
- **Data Retrieval**: Users can retrieve information about registered candidates and voters.

## Technologies

- **Solidity Version**: 0.8.9
- **Network**: Lisk blockchain
- **Tools**:
  - [Hardhat](https://hardhat.org/)
  - Lisk-compatible deployment tools

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Lukman-01/Smart-Contract-Applications.git
   cd Voting-Contract
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up your environment variables in a `.env` file (if needed):
   ```
   LISK_RPC_URL=your-lisk-rpc-url
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

VotingModule#Voting - 0xcCA22e0d4912AAeE61365816942058EE126D42A8

Verifying deployed contracts

Verifying contract "contracts/Voting.sol:Voting" for network lisk-sepolia...
Successfully verified contract "contracts/Voting.sol:Voting" for network lisk-sepolia:
  - https://sepolia-blockscout.lisk.com/address/0xcCA22e0d4912AAeE61365816942058EE126D42A8#code


### Authors

Abdulyekeen Lukman(Ibukun)