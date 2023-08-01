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
  
    // Test for adding a new room
    it("Should add a new room", async function () {
        // Add a new room using the 'addRoom' function
        const roomTx = await hotelContract.addRoom("Room 101", "Address 123", 100, 200);
        // Wait for the transaction to be mined
        await roomTx.wait();
    
        // Get the room details by calling the 'Rooms' mapping
        const room = await hotelContract.Rooms(1);
    
        // Check if the room details are correct
        expect(room.room_name).to.equal("Room 101");
        expect(room.room_address).to.equal("Address 123");
        expect(room.rent_per_month).to.equal(100);
        expect(room.security_deposit).to.equal(200);
        expect(room.landlord).to.equal(owner.address);
    });
  
  });
  