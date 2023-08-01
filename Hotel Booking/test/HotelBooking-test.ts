// Import the necessary libraries and dependencies
const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const { deployContract } = waffle;

// Describe the test suite for the Hotel contract
describe("Hotel Contract", function () {
    // Define variables to hold contract instances and addresses
    let hotelContract;
    let owner, landlord, tenant;
    let RoomAddedEvent, AgreementSignedEvent, RentPaidEvent, AgreementCompletedEvent, AgreementTerminatedEvent;
  
    // Deploy the contract before running tests
    beforeEach(async function () {
      // Get accounts from ethers provider
      [owner, landlord, tenant] = await ethers.getSigners();
  
      // Compile and deploy the contract
      const Hotel = await ethers.getContractFactory("Hotel");
      hotelContract = await deployContract(owner, Hotel);
    });
  
    // Write your tests here...
  });
  