import { ethers } from 'hardhat';
import { Contract, Signer } from 'ethers';
import { expect } from 'chai';
import { waffle } from 'hardhat';

const { deployContract } = waffle;

describe('Hotel', function () {
  let contract: Contract;
  let owner: Signer;
  let tenant1: Signer;
  let tenant2: Signer;

  beforeEach(async () => {
    // Deploy the Hotel contract
    [owner, tenant1, tenant2] = await ethers.getSigners();
    contract = await deployContract(owner, artifacts.readArtifactSync('Hotel'));
  });

  // Test case for adding a new room
  it('should add a new room', async function () {
    // Arrange
    const roomName = 'Room 101';
    const roomAddress = '123 Main St';
    const rentPerMonth = 1000;
    const securityDeposit = 2000;

    // Act
    const addRoomTx = await contract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);

    // Assert
    expect(addRoomTx)
      .to.emit(contract, 'RoomAdded')
      .withArgs(1, roomName, roomAddress, rentPerMonth, securityDeposit, await owner.getAddress());

    // Check if the room details are stored correctly
    const roomDetails = await contract.Rooms(1);
    expect(roomDetails.room_id).to.equal(1);
    expect(roomDetails.room_name).to.equal(roomName);
    expect(roomDetails.room_address).to.equal(roomAddress);
    expect(roomDetails.rent_per_month).to.equal(rentPerMonth);
    expect(roomDetails.security_deposit).to.equal(securityDeposit);
    expect(roomDetails.vacant).to.be.true;
    expect(roomDetails.landlord).to.equal(await owner.getAddress());
    expect(roomDetails.current_tenant).to.equal('0x0000000000000000000000000000000000000000');
  });

  // Test case for a tenant signing an agreement and renting a room
  it('should allow a tenant to sign an agreement and rent a room', async function () {
    // Arrange
    const roomName = 'Room 101';
    const roomAddress = '123 Main St';
    const rentPerMonth = 1000;
    const securityDeposit = 2000;
    await contract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);

    // Act
    const signAgreementTx = await contract.connect(tenant1).signAgreement(1, { value: rentPerMonth + securityDeposit });

    // Assert
    expect(signAgreementTx)
      .to.emit(contract, 'AgreementSigned')
      .withArgs(1, 1, roomName, roomAddress, rentPerMonth, securityDeposit, await owner.getAddress(), await tenant1.getAddress());

    // Check if the room details are updated correctly
    const roomDetails = await contract.Rooms(1);
    expect(roomDetails.agreement_id).to.equal(1);
    expect(roomDetails.current_tenant).to.equal(await tenant1.getAddress());
    expect(roomDetails.vacant).to.be.false;
    expect(roomDetails.timestamp).to.be.closeTo(Math.floor(Date.now() / 1000), 2);
  });

  // Test case for a tenant paying rent
  it('should allow a tenant to pay rent', async function () {
    // Arrange
    const roomName = 'Room 101';
    const roomAddress = '123 Main St';
    const rentPerMonth = 1000;
    const securityDeposit = 2000;
    await contract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);
    await contract.connect(tenant1).signAgreement(1, { value: rentPerMonth + securityDeposit });

    // Act
    const payRentTx = await contract.connect(tenant1).payRent(1, { value: rentPerMonth });

    // Assert
    expect(payRentTx)
      .to.emit(contract, 'RentPaid')
      .withArgs(1, 1, roomName, roomAddress, rentPerMonth, await owner.getAddress(), await tenant1.getAddress());
  });

  // Test case for a landlord marking the completion of an agreement
  it('should allow a landlord to mark the completion of an agreement', async function () {
    // Arrange
    const roomName = 'Room 101';
    const roomAddress = '123 Main St';
    const rentPerMonth = 1000;
    const securityDeposit = 2000;
    await contract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);
    await contract.connect(tenant1).signAgreement(1, { value: rentPerMonth + securityDeposit });

    // Act
    const agreementCompletedTx = await contract.connect(owner).agreementCompleted(1);

    // Assert
    expect(agreementCompletedTx)
      .to.emit(contract, 'AgreementCompleted')
      .withArgs(1, roomName, roomAddress, rentPerMonth, await owner.getAddress());

    // Check if the room details are updated correctly
    const roomDetails = await contract.Rooms(1);
    expect(roomDetails.agreement_id).to.equal(0);
    expect(roomDetails.current_tenant).to.equal('0x0000000000000000000000000000000000000000');
    expect(roomDetails.vacant).to.be.true;
  });

  // Test case for a landlord terminating an agreement
  it('should allow a landlord to terminate an agreement', async function () {
    // Arrange
    const roomName = 'Room 101';
    const roomAddress = '123 Main St';
    const rentPerMonth = 1000;
    const securityDeposit = 2000;
    await contract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);
    await contract.connect(tenant1).signAgreement(1, { value: rentPerMonth + securityDeposit });

    // Act
    const agreementTerminatedTx = await contract.connect(owner).agreementTerminated(1);

    // Assert
    expect(agreementTerminatedTx)
      .to.emit(contract, 'AgreementTerminated')
      .withArgs(1, roomName, roomAddress, rentPerMonth, await owner.getAddress());

    // Check if the room details are updated correctly
    const roomDetails = await contract.Rooms(1);
    expect(roomDetails.agreement_id).to.equal(0);
    expect(roomDetails.current_tenant).to.equal('0x0000000000000000000000000000000000000000');
    expect(roomDetails.vacant).to.be.true;
  });

  // Test case for a tenant withdrawing their security deposit
  it('should allow a tenant to withdraw their security deposit', async function () {
    // Arrange
    const roomName = 'Room 101';
    const roomAddress = '123 Main St';
    const rentPerMonth = 1000;
    const securityDeposit = 2000;
    await contract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);
    await contract.connect(tenant1).signAgreement(1, { value: rentPerMonth + securityDeposit });

    // Act
    await contract.connect(tenant1).withdrawSecurityDeposit(1);

    // Check if the security deposit is withdrawn correctly
    const roomDetails = await contract.Rooms(1);
    expect(roomDetails.securityDepositWithdrawn).to.be.true;
  });

  // Test case for getting the number of vacant rooms
  it('should get the number of vacant rooms', async function () {
    // Arrange
    const roomName1 = 'Room 101';
    const roomAddress1 = '123 Main St';
    const rentPerMonth1 = 1000;
    const securityDeposit1 = 2000;
    const roomName2 = 'Room 102';
    const roomAddress2 = '456 Park Ave';
    const rentPerMonth2 = 1200;
    const securityDeposit2 = 2500;
    await contract.addRoom(roomName1, roomAddress1, rentPerMonth1, securityDeposit1);
    await contract.addRoom(roomName2, roomAddress2, rentPerMonth2, securityDeposit2);

    // Act
    const vacantRooms = await contract.getNumberOfRoomsAvailable();

    // Assert
    expect(vacantRooms).to.equal(2);
  });

  // Test case for getting the total number of rooms
  it('should get the total number of rooms', async function () {
    // Arrange
    const roomName1 = 'Room 101';
    const roomAddress1 = '123 Main St';
    const rentPerMonth1 = 1000;
    const securityDeposit1 = 2000;
    const roomName2 = 'Room 102';
    const roomAddress2 = '456 Park Ave';
    const rentPerMonth2 = 1200;
    const securityDeposit2 = 2500;
    await contract.addRoom(roomName1, roomAddress1, rentPerMonth1, securityDeposit1);
    await contract.addRoom(roomName2, roomAddress2, rentPerMonth2, securityDeposit2);

    // Act
    const totalRooms = await contract.getTotalNumberOfRooms();

    // Assert
    expect(totalRooms).to.equal(2);
  });

  // Test case for getting the total number of rented rooms
  it('should get the total number of rented rooms', async function () {
    // Arrange
    const roomName1 = 'Room 101';
    const roomAddress1 = '123 Main St';
    const rentPerMonth1 = 1000;
    const securityDeposit1 = 2000;
    const roomName2 = 'Room 102';
    const roomAddress2 = '456 Park Ave';
    const rentPerMonth2 = 1200;
    const securityDeposit2 = 2500;
    await contract.addRoom(roomName1, roomAddress1, rentPerMonth1, securityDeposit1);
    await contract.addRoom(roomName2, roomAddress2, rentPerMonth2, securityDeposit2);
    await contract.connect(tenant1).signAgreement(1, { value: rentPerMonth1 + securityDeposit1 });

    // Act
    const rentedRooms = await contract.getTotalNumberOfRoomsRented();

    // Assert
    expect(rentedRooms).to.equal(1);
  });
});
