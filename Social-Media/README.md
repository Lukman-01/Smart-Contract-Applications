# ModernSocialMedia Smart Contract

## Overview
The **ModernSocialMedia** smart contract is a decentralized social media platform built on the Ethereum blockchain. It allows users to create profiles, post content, comment on posts, follow/unfollow other users, and send messages. This contract is deployed on the **Lisk Sepolia** testnet, offering a seamless experience for social interaction in a trustless environment.

## Features
- **User Profiles**: Users can create and update their profiles with a name, bio, and profile picture.
- **Posts**: Users can create posts containing their thoughts and ideas, as well as like posts from other users.
- **Comments**: Users can add comments to posts, allowing for discussions and interactions.
- **Follow/Unfollow**: Users can follow and unfollow others to curate their social feed.
- **Messaging**: Users can send private messages to each other for direct communication.

## Technologies
- **Solidity Version**: 0.8.26
- **Network**: Lisk Sepolia testnet
- **Tools**:
  - [Hardhat](https://hardhat.org/)
  - [Blockscout](https://sepolia-blockscout.lisk.com/)

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Lukman-01/Smart-Contract-Applications.git
   cd Social-Media
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Set up your environment variables** in a `.env` file:
   ```
   LISK_RPC_URL=your-lisk-sepolia-rpc-url
   PRIVATE_KEY=your-private-key
   ```

4. **Compile the smart contracts**:
   ```bash
   npx hardhat compile
   ```

5. **Deploy the contract**:
   ```bash
   npx hardhat ignition deploy ./ignition/modules/deploy.ts --network lisk-sepolia --verify
   ```
Deployed Addresses

ModernSocialMediaModule#ModernSocialMedia - 0x43dc52c81ef4236D1dF4490C98883cfF69AD482D

### Verifying deployed contracts

Verifying contract "contracts/SocialMedia.sol:ModernSocialMedia" for network lisk-sepolia...
Successfully verified contract "contracts/SocialMedia.sol:ModernSocialMedia" for network lisk-sepolia:
  - https://sepolia-blockscout.lisk.com/address/0x43dc52c81ef4236D1dF4490C98883cfF69AD482D#code