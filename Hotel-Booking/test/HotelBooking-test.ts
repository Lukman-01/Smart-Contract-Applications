import { ethers } from 'hardhat';
import { Contract, Signer } from 'ethers';
import { expect } from 'chai';
import { parseEther } from 'ethers/lib/utils';

describe('Hotel', function () {
  let contract: Contract;
  let owner: Signer;
  let tenant1: Signer;
  let tenant2: Signer;

  beforeEach(async () => {
    // Deploy the Hotel contract
    [owner, tenant1, tenant2] = await ethers.getSigners();
    const hotelContractFactory = await ethers.getContractFactory('Hotel');
    contract = await hotelContractFactory.deploy();
    await contract.deployed();
  });

  it('should add a new room', async function () {
    // Arrange
    const roomName = 'Room 101';
    const roomAddress = '123 Main St';
    const rentPerMonth = parseEther('1'); // 1 ether for simplicity
    const securityDeposit = parseEther('2'); // 2 ethers for simplicity

    // Act
    const addRoomTx = await contract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);

    // Assert
    const [event] = await contract.queryFilter(contract.filters.RoomAdded());
    expect(event.args?.roomId).to.equal(1);
    expect(event.args?.room_name).to.equal(roomName);
    expect(event.args?.room_address).to.equal(roomAddress);
    expect(event.args?.rent_per_month).to.equal(rentPerMonth);
    expect(event.args?.security_deposit).to.equal(securityDeposit);
    expect(event.args?.landlord).to.equal(await owner.getAddress());

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

  it('should allow a tenant to sign an agreement and rent a room', async function () {
    // Arrange
    const roomName = 'Room 101';
    const roomAddress = '123 Main St';
    const rentPerMonth = parseEther('1'); // 1 ether for simplicity
    const securityDeposit = parseEther('2'); // 2 ethers for simplicity
    await contract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);

    // Act
    const signAgreementTx = await contract.connect(tenant1).signAgreement(1, { value: rentPerMonth.add(securityDeposit) });

    // Assert
    const [event] = await contract.queryFilter(contract.filters.AgreementSigned());
    expect(event.args?.agreementId).to.equal(1);
    expect(event.args?.roomId).to.equal(1);
    expect(event.args?.room_name).to.equal(roomName);
    expect(event.args?.room_address).to.equal(roomAddress);
    expect(event.args?.rent_per_month).to.equal(rentPerMonth);
    expect(event.args?.security_deposit).to.equal(securityDeposit);
    expect(event.args?.landlord).to.equal(await owner.getAddress());
    expect(event.args?.tenant).to.equal(await tenant1.getAddress());

    const roomDetails = await contract.Rooms(1);
    expect(roomDetails.agreement_id).to.equal(1);
    expect(roomDetails.current_tenant).to.equal(await tenant1.getAddress());
    expect(roomDetails.vacant).to.be.false;
    expect(roomDetails.timestamp).to.be.closeTo(Math.floor(Date.now() / 1000), 2);
  });

  it('should allow a tenant to pay rent', async function () {
    // Arrange
    const roomName = 'Room 101';
    const roomAddress = '123 Main St';
    const rentPerMonth = parseEther('1'); // 1 ether for simplicity
    const securityDeposit = parseEther('2'); // 2 ethers for simplicity
    await contract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);
    await contract.connect(tenant1).signAgreement(1, { value: rentPerMonth.add(securityDeposit) });

    // Act
    const payRentTx = await contract.connect(tenant1).payRent(1, { value: rentPerMonth });

    // Assert
    const [event] = await contract.queryFilter(contract.filters.RentPaid());
    expect(event.args?.rentId).to.equal(1);
    expect(event.args?.roomId).to.equal(1);
    expect(event.args?.room_name).to.equal(roomName);
    expect(event.args?.room_address).to.equal(roomAddress);
    expect(event.args?.rent_per_month).to.equal(rentPerMonth);
    expect(event.args?.landlord).to.equal(await owner.getAddress());
    expect(event.args?.tenant).to.equal(await tenant1.getAddress());
  });

  it('should allow a landlord to mark the completion of an agreement', async function () {
    // Arrange
    const roomName = 'Room 101';
    const roomAddress = '123 Main St';
    const rentPerMonth = parseEther('1'); // 1 ether for simplicity
    const securityDeposit = parseEther('2'); // 2 ethers for simplicity
    await contract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);
    await contract.connect(tenant1).signAgreement(1, { value: rentPerMonth.add(securityDeposit) });

    // Act
    const agreementCompletedTx = await contract.connect(owner).agreementCompleted(1);

    // Assert
    const [event] = await contract.queryFilter(contract.filters.AgreementCompleted());
    expect(event.args?.roomId).to.equal(1);
    expect(event.args?.room_name).to.equal(roomName);
    expect(event.args?.room_address).to.equal(roomAddress);
    expect(event.args?.rent_per_month).to.equal(rentPerMonth);
    expect(event.args?.landlord).to.equal(await owner.getAddress());

    const roomDetails = await contract.Rooms(1);
    expect(roomDetails.agreement_id).to.equal(0);
    expect(roomDetails.current_tenant).to.equal('0x0000000000000000000000000000000000000000');
    expect(roomDetails.vacant).to.be.true;
  });

  it('should allow a landlord to terminate an agreement', async function () {
    // Arrange
    const roomName = 'Room 101';
    const roomAddress = '123 Main St';
    const rentPerMonth = parseEther('1'); // 1 ether for simplicity
    const securityDeposit = parseEther('2'); // 2 ethers for simplicity
    await contract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);
    await contract.connect(tenant1).signAgreement(1, { value: rentPerMonth.add(securityDeposit) });

    // Act
    const agreementTerminatedTx = await contract.connect(owner).agreementTerminated(1);
    // Assert
    const [event] = await contract.queryFilter(contract.filters.AgreementTerminated());
    expect(event.args?.roomId).to.equal(1);
    expect(event.args?.room_name).to.equal(roomName);
    expect(event.args?.room_address).to.equal(roomAddress);
    expect(event.args?.rent_per_month).to.equal(rentPerMonth);
    expect(event.args?.landlord).to.equal(await owner.getAddress());

    const roomDetails = await contract.Rooms(1);
    expect(roomDetails.agreement_id).to.equal(0);
    expect(roomDetails.current_tenant).to.equal('0x0000000000000000000000000000000000000000');
    expect(roomDetails.vacant).to.be.true;
  });

  it('should allow a tenant to withdraw their security deposit', async function () {
    // Arrange
    const roomName = 'Room 101';
    const roomAddress = '123 Main St';
    const rentPerMonth = parseEther('1'); // 1 ether for simplicity
    const securityDeposit = parseEther('2'); // 2 ethers for simplicity
    await contract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);
    await contract.connect(tenant1).signAgreement(1, { value: rentPerMonth.add(securityDeposit) });

    // Act
    await contract.connect(tenant1).withdrawSecurityDeposit(1);

    // Assert
    const roomDetails = await contract.Rooms(1);
    expect(roomDetails.securityDepositWithdrawn).to.be.true;
  });

  it('should get the number of vacant rooms', async function () {
    // Arrange
    const roomName1 = 'Room 101';
    const roomAddress1 = '123 Main St';
    const rentPerMonth1 = parseEther('1'); // 1 ether for simplicity
    const securityDeposit1 = parseEther('2'); // 2 ethers for simplicity
    const roomName2 = 'Room 102';
    const roomAddress2 = '456 Park Ave';
    const rentPerMonth2 = parseEther('1.2'); // 1.2 ethers for simplicity
    const securityDeposit2 = parseEther('2.5'); // 2.5 ethers for simplicity
    await contract.addRoom(roomName1, roomAddress1, rentPerMonth1, securityDeposit1);
    await contract.addRoom(roomName2, roomAddress2, rentPerMonth2, securityDeposit2);

    // Act
    const vacantRooms = await contract.getNumberOfRoomsAvailable();

    // Assert
    expect(vacantRooms).to.equal(2);
  });

  it('should get the total number of rooms', async function () {
    // Arrange
    const roomName1 = 'Room 101';
    const roomAddress1 = '123 Main St';
    const rentPerMonth1 = parseEther('1'); // 1 ether for simplicity
    const securityDeposit1 = parseEther('2'); // 2 ethers for simplicity
    const roomName2 = 'Room 102';
    const roomAddress2 = '456 Park Ave';
    const rentPerMonth2 = parseEther('1.2'); // 1.2 ethers for simplicity
    const securityDeposit2 = parseEther('2.5'); // 2.5 ethers for simplicity
    await contract.addRoom(roomName1, roomAddress1, rentPerMonth1, securityDeposit1);
    await contract.addRoom(roomName2, roomAddress2, rentPerMonth2, securityDeposit2);

    // Act
    const totalRooms = await contract.getTotalNumberOfRooms();

    // Assert
    expect(totalRooms).to.equal(2);
  });

  it('should get the total number of rented rooms', async function () {
    // Arrange
    const roomName1 = 'Room 101';
    const roomAddress1 = '123 Main St';
    const rentPerMonth1 = parseEther('1'); // 1 ether for simplicity
    const securityDeposit1 = parseEther('2'); // 2 ethers for simplicity
    const roomName2 = 'Room 102';
    const roomAddress2 = '456 Park Ave';
    const rentPerMonth2 = parseEther('1.2'); // 1.2 ethers for simplicity
    const securityDeposit2 = parseEther('2.5'); // 2.5 ethers for simplicity
    await contract.addRoom(roomName1, roomAddress1, rentPerMonth1, securityDeposit1);
    await contract.addRoom(roomName2, roomAddress2, rentPerMonth2, securityDeposit2);
    await contract.connect(tenant1).signAgreement(1, { value: rentPerMonth1.add(securityDeposit1) });

    // Act
    const rentedRooms = await contract.getTotalNumberOfRoomsRented();

    // Assert
    expect(rentedRooms).to.equal(1);
  });

});
