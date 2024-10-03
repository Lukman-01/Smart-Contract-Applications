# MedicalHistory Smart Contract

## Overview

The **MedicalHistory** smart contract is a decentralized application deployed on the Ethereum blockchain for managing patient medical histories. It allows authorized doctors to add, update, and retrieve patient information securely while ensuring patient privacy.

## Features

- **Doctor Authorization**: The contract owner can authorize doctors to access and manage patient records.
- **Patient Management**: Doctors can add new patients and update their medical histories, including conditions, allergies, medications, and procedures.
- **Secure Data Access**: Only authorized doctors can modify or retrieve patient records, ensuring confidentiality.
- **Events**: The contract emits events when a doctor is added or patient information is modified.

## Technologies

- **Solidity Version**: 0.8.26
- **Network**: Ethereum-compatible network (can be deployed on Lisk Sepolia or other compatible networks)
- **Tools**:
  - [Hardhat](https://hardhat.org/)
  - Any Ethereum-compatible block explorer (e.g., Etherscan)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/Smart-Contract-Applications.git
   cd Medical-Industry
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

MedicalHistoryModule#MedicalHistory - 0xB0CfEDc9518A7ce2D593008Ba16503c9e09D1E1F

Verifying deployed contracts

Verifying contract "contracts/Medical-History.sol:MedicalHistory" for network lisk-sepolia...
Successfully verified contract "contracts/Medical-History.sol:MedicalHistory" for network lisk-sepolia:
  - https://sepolia-blockscout.lisk.com/address/0xB0CfEDc9518A7ce2D593008Ba16503c9e09D1E1F#code