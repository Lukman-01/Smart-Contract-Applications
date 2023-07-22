import { expect } from "chai";
import { ethers, waffle } from "hardhat";
import { Hotel } from "../contracts/Hotel-Booking.sol";

const { deployContract } = waffle;

describe("Hotel", function () {
  let hotelContract: Hotel;
  let owner: any;
  let tenant: any;

  beforeEach(async () => {
    [owner, tenant] = await ethers.getSigners();

    const HotelContract = await ethers.getContractFactory("Hotel");
    hotelContract = (await deployContract(owner, HotelContract)) as Hotel;
  });

  it("Should add a new room", async function () {
    const roomName = "Room 101";
    const roomAddress = "Address of Room 101";
    const rentPerMonth = ethers.utils.parseEther("2"); // 2 ether
    const securityDeposit = ethers.utils.parseEther("1"); // 1 ether

    // Add a new room
    await hotelContract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);
    const room = await hotelContract.Rooms(1);

    expect(room.room_id).to.equal(1);
    expect(room.room_name).to.equal(roomName);
    expect(room.room_address).to.equal(roomAddress);
    expect(room.rent_per_month).to.equal(rentPerMonth);
    expect(room.security_deposit).to.equal(securityDeposit);
    expect(room.landlord).to.equal(owner.address);
    expect(room.vacant).to.equal(true);
  });

  it("Should sign an agreement and pay rent", async function () {
    const roomName = "Room 101";
    const roomAddress = "Address of Room 101";
    const rentPerMonth = ethers.utils.parseEther("2"); // 2 ether
    const securityDeposit = ethers.utils.parseEther("1"); // 1 ether
    const lockperiod = 30 * 24 * 60 * 60; // 30 days in seconds

    // Add a new room
    await hotelContract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);

    // Tenant signs an agreement and pays the security deposit
    await hotelContract.connect(tenant).signAgreement(1, lockperiod, {
      value: securityDeposit,
    });

    const room = await hotelContract.Rooms(1);

    expect(room.agreement_id).to.equal(1);
    expect(room.current_tenant).to.equal(tenant.address);
    expect(room.vacant).to.equal(false);

    // Tenant pays the rent for the room
    await hotelContract.connect(tenant).payRent(1, {
      value: rentPerMonth,
    });

    // Check the rent payment details
    const rent = await hotelContract.Rents(1);

    expect(rent.rent_id).to.equal(1);
    expect(rent.room_id).to.equal(1);
    expect(rent.rent_per_month).to.equal(rentPerMonth);
    expect(rent.tenant_address).to.equal(tenant.address);
  });

  it("Should complete the agreement and terminate the agreement", async function () {
    const roomName = "Room 101";
    const roomAddress = "Address of Room 101";
    const rentPerMonth = ethers.utils.parseEther("2"); // 2 ether
    const securityDeposit = ethers.utils.parseEther("1"); // 1 ether
    const lockperiod = 30 * 24 * 60 * 60; // 30 days in seconds

    // Add a new room
    await hotelContract.addRoom(roomName, roomAddress, rentPerMonth, securityDeposit);

    // Tenant signs an agreement and pays the security deposit
    await hotelContract.connect(tenant).signAgreement(1, lockperiod, {
      value: securityDeposit,
    });

    // Complete the agreement by the landlord
    await hotelContract.agreementCompleted(1);

    const room = await hotelContract.Rooms(1);

    expect(room.agreement_id).to.equal(0);
    expect(room.current_tenant).to.equal(ethers.constants.AddressZero);
    expect(room.vacant).to.equal(true);

    // Tenant terminates the agreement
    await hotelContract.connect(tenant).agreementTerminated(1);

    const roomAfterTermination = await hotelContract.Rooms(1);

    expect(roomAfterTermination.agreement_id).to.equal(0);
    expect(roomAfterTermination.current_tenant).to.equal(ethers.constants.AddressZero);
    expect(roomAfterTermination.vacant).to.equal(true);
  });
});
