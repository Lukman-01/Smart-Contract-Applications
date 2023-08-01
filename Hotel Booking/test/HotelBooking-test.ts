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

    // Test for signing an agreement
    it("Should sign an agreement", async function () {
        // Sign an agreement using the 'signAgreement' function
        const agreementTx = await hotelContract.signAgreement(1, 86400); // 86400 seconds (1 day) lock period
        // Wait for the transaction to be mined
        await agreementTx.wait();
    
        // Get the agreement details by calling the 'Agreements' mapping
        const agreement = await hotelContract.Agreements(1);
    
        // Check if the agreement details are correct
        expect(agreement.room_id).to.equal(1);
        expect(agreement.room_name).to.equal("Room 101");
        expect(agreement.room_address).to.equal("Address 123");
        expect(agreement.rent_per_month).to.equal(100);
        expect(agreement.security_deposit).to.equal(200);
        expect(agreement.lockperiod).to.equal(86400);
        expect(agreement.landlord_address).to.equal(owner.address);
        expect(agreement.tenant_address).to.equal(tenant.address);
    });
    
    // Test for paying the rent
    it("Should pay the rent", async function () {
        // Pay the rent using the 'payRent' function
        const rentTx = await hotelContract.payRent(1, { value: ethers.utils.parseEther("100") });
        // Wait for the transaction to be mined
        await rentTx.wait();
    
        // Get the rent details by calling the 'Rents' mapping
        const rent = await hotelContract.Rents(1);
    
        // Check if the rent details are correct
        expect(rent.room_id).to.equal(1);
        expect(rent.room_name).to.equal("Room 101");
        expect(rent.room_address).to.equal("Address 123");
        expect(rent.rent_per_month).to.equal(100);
        expect(rent.landlord_address).to.equal(owner.address);
        expect(rent.tenant_address).to.equal(tenant.address);
    });
  
    // Test for completing an agreement
    it("Should complete an agreement", async function () {
        // Complete the agreement using the 'agreementCompleted' function
        const agreementCompleteTx = await hotelContract.agreementCompleted(1);
        // Wait for the transaction to be mined
        await agreementCompleteTx.wait();
    
        // Get the room details by calling the 'Rooms' mapping after the agreement is completed
        const room = await hotelContract.Rooms(1);
    
        // Check if the room is now vacant and has no active agreement
        expect(room.vacant).to.be.true;
        expect(room.agreement_id).to.equal(0);
        expect(room.current_tenant).to.equal(ethers.constants.AddressZero);
    });
    
    // Test for terminating an agreement
    it("Should terminate an agreement", async function () {
        // Terminate the agreement using the 'agreementTerminated' function
        const agreementTerminateTx = await hotelContract.agreementTerminated(1);
        // Wait for the transaction to be mined
        await agreementTerminateTx.wait();
    
        // Get the room details by calling the 'Rooms' mapping after the agreement is terminated
        const room = await hotelContract.Rooms(1);
    
        // Check if the room is now vacant and has no active agreement
        expect(room.vacant).to.be.true;
        expect(room.agreement_id).to.equal(0);
        expect(room.current_tenant).to.equal(ethers.constants.AddressZero);
    });
    
    // Test for withdrawing the security deposit
    it("Should withdraw the security deposit", async function () {
        // Withdraw the security deposit using the 'withdrawSecurityDeposit' function
        const withdrawDepositTx = await hotelContract.withdrawSecurityDeposit(1);
        // Wait for the transaction to be mined
        await withdrawDepositTx.wait();
    
        // Get the room details by calling the 'Rooms' mapping after the security deposit is withdrawn
        const room = await hotelContract.Rooms(1);
    
        // Check if the security deposit is withdrawn
        expect(room.securityDepositWithdrawn).to.be.true;
    });
  
  });
  