# Hotel Management Smart Contract

## Description

This project is a **decentralized hotel management system** built on the Ethereum blockchain using Solidity. The contract allows landlords to manage their properties by adding rooms, signing rental agreements, and collecting rent, while tenants can rent rooms and make payments seamlessly. All operations are performed transparently and securely on-chain, ensuring trust between landlords and tenants without intermediaries.

## Features

- **Room Management**: Landlords can add new rooms, specifying details like rent and security deposits.
- **Rental Agreements**: Tenants can sign agreements to rent rooms, which are tracked by the contract.
- **Rent Payments**: Tenants can pay their rent securely through the contract, with payments being forwarded to landlords.
- **Vacancy Tracking**: The contract tracks whether rooms are vacant or occupied.
- **Security Deposit Handling**: Landlords manage security deposits, with provisions for withdrawing them at the end of agreements.
- **Agreement Termination**: Landlords can terminate rental agreements, and penalties are applied for early termination.

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Lukman-01/Smart-Contract-Applications.git
   cd Hotel Booking
   ```

2. **Install Dependencies**:
   Make sure you have Node.js installed. Install Hardhat and other dependencies:
   ```bash
   npm install
   ```

3. **Set up Environment Variables**:
   Create a `.env` file and configure the following variables:
   ```bash
   LISK_RPC_URL=<your_lisk_rpc_url>
   PRIVATE_KEY=<your_private_key>
   ```

4. **Compile the Contract**:
   Compile the Solidity contract:
   ```bash
   npx hardhat compile
   ```

5. **Deploy the Contract**:
   Deploy to the desired network:
   ```bash
   npx hardhat ignition deploy ./ignition/modules/deploy.ts --network lisk-sepolia --verify
   ```

   Deployed Addresses

   HotelModule#Hotel - 0xBFFdB9F0f2D3134A4490134B45D99A17F7588D76

   Verifying deployed contracts
   Successfully verified contract Hotel on the block explorer.
   https://sepolia-blockscout.lisk.com/address/0xBFFdB9F0f2D3134A4490134B45D99A17F7588D76#code