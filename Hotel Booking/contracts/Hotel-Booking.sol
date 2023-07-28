// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title Hotel
 * @dev A simple smart contract for managing hotel rooms and agreements between landlords and tenants.
 * It allows landlords to add rooms, tenants to sign agreements, pay rent, and mark agreements as completed or terminated.
 * The contract uses various modifiers to control access and enforce conditions for specific functions.
 */
contract Hotel {
    using Address for address payable;
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using BlockTimestamp for IBlockTimestamp;

    // State variables
    address public contractOwner;
    Counters.Counter private roomCounter;
    Counters.Counter private agreementCounter;
    Counters.Counter private rentCounter;

    // Room struct to store room details
    struct Room {
        uint room_id;
        uint agreement_id;
        string room_name;
        string room_address;
        uint rent_per_month;
        uint security_deposit;
        uint timestamp;
        bool vacant;
        address payable landlord;
        address payable current_tenant;
        bool securityDepositWithdrawn;
    }

    // Mapping to store Room objects by their IDs
    mapping(uint => Room) public Rooms;

    // RoomAgreement struct to store agreement details
    struct RoomAgreement {
        uint room_id;
        uint agreement_id;
        string room_name;
        string room_address;
        uint rent_per_month;
        uint security_deposit;
        uint lockperiod;
        uint timestamp;
        address payable landlord_address;
        address payable tenant_address;
    }

    // Mapping to store RoomAgreement objects by their IDs
    mapping(uint => RoomAgreement) public Agreements;

    // Rent struct to store rent payment details
    struct Rent {
        uint rent_id;
        uint room_id;
        uint agreement_id;
        string room_name;
        string room_address;
        uint rent_per_month;
        uint timestamp;
        address payable landlord_address;
        address payable tenant_address;
    }

    // Mapping to store Rent objects by their IDs
    mapping(uint => Rent) public Rents;

    // Modifiers to control access and enforce conditions
    modifier OnlyOwner() {
        require(msg.sender == contractOwner, "Only the contract owner can call this function");
        _;
    }

    modifier OnlyLandlord(uint _id) {
        require(msg.sender == Rooms[_id].landlord, "Only landlord can call this function");
        _;
    }

    modifier OnlyTenant(uint _id) {
        require(msg.sender == Rooms[_id].current_tenant, "Only tenants can call this function");
        _;
    }

    modifier notOccupied(uint _id) {
        require(Rooms[_id].vacant, "This room is occupied");
        _;
    }

    modifier CheckAmount(uint _id) {
        require(msg.value >= Rooms[_id].rent_per_month.mul(1 ether), "You have insufficient amount for the rent");
        _;
    }

    modifier enoughAgreement(uint _id) {
        uint totalAmount = Rooms[_id].rent_per_month.add(Rooms[_id].security_deposit).mul(1 ether);
        require(msg.value >= totalAmount, "Not enough Agreement fee");
        _;
    }

    modifier sameTenant(uint _id) {
        require(msg.sender == Rooms[_id].current_tenant, "No previous agreement");
        _;
    }

    modifier AgreementTimeLeft(uint _id) {
        uint agrId = Rooms[_id].agreement_id;
        uint time = Agreements[agrId].timestamp.add(Agreements[agrId].lockperiod);
        require(block.timestamp < time, "Agreement ended");
        _;
    }

    modifier AgreementTimesUp(uint _id) {
        uint agrId = Rooms[_id].agreement_id;
        uint time = Agreements[agrId].timestamp.add(Agreements[agrId].lockperiod);
        require(block.timestamp > time, "There is still some time left");
        _;
    }

    modifier RentTimesUp(uint _id) {
        uint time = Rooms[_id].timestamp.add(30 days);
        require(block.timestamp >= time, "Times Up");
        _;
    }

    // Events for notifying external systems
    event RoomAdded(
        uint indexed roomId,
        string room_name,
        string room_address,
        uint rent_per_month,
        uint security_deposit,
        address landlord
    );

    event AgreementSigned(
        uint indexed agreementId,
        uint roomId,
        string room_name,
        string room_address,
        uint rent_per_month,
        uint security_deposit,
        uint lockperiod,
        address landlord,
        address tenant
    );

    event RentPaid(
        uint rentId,
        uint indexed roomId,
        string room_name,
        string room_address,
        uint rent_per_month,
        address indexed landlord,
        address indexed tenant
    );

    event AgreementCompleted(
        uint indexed roomId,
        string room_name,
        string room_address,
        uint rent_per_month,
        address indexed landlord
    );

    event AgreementTerminated(
        uint indexed roomId,
        string room_name,
        string room_address,
        uint rent_per_month,
        address indexed landlord
    );

    /**
     * @dev Constructor sets the contract owner as the deployer.
     */
    constructor() {
        contractOwner = msg.sender;
    }

    /**
     * @dev Function for adding a new room
     * @param _roomName The name of the room.
     * @param _roomAddress The address of the room.
     * @param _rentPerMonth The monthly rent amount for the room.
     * @param _securityDeposit The security deposit amount for the room.
     */
    function addRoom(
        string memory _roomName,
        string memory _roomAddress,
        uint _rentPerMonth,
        uint _securityDeposit
    ) external OnlyOwner {
        // Increment the total number of rooms
        roomCounter.increment();
        uint roomId = roomCounter.current();

        // Create a new Room struct instance and initialize its values
        Room memory newRoom = Room({
            room_id: roomId,
            agreement_id: 0, // Initialize agreement_id to 0 since it's a new room and has no agreement yet
            room_name: _roomName,
            room_address: _roomAddress,
            rent_per_month: _rentPerMonth,
            security_deposit: _securityDeposit,
            timestamp: block.timestamp, // Set the current timestamp as the room's creation timestamp
            vacant: true, // Set vacant to true since the room is initially available for rent
            landlord: payable(msg.sender), // Set the landlord as the one who adds the room
            current_tenant: payable(address(0)), // Set the current_tenant to address(0) since there's no tenant initially
            securityDepositWithdrawn: false // Set securityDepositWithdrawn to false since the security deposit is not withdrawn yet
        });

        // Store the new room in the mapping using its ID as the key
        Rooms[roomId] = newRoom;

        // Emit an event to notify the addition of a new room
        emit RoomAdded(
            roomId,
            _roomName,
            _roomAddress,
            _rentPerMonth,
            _securityDeposit,
            msg.sender
        );
    }

    /**
     * @dev Function for tenants to sign an agreement for a room
     * @param _roomId The ID of the room to sign the agreement for.
     * @param _lockperiod The duration of the agreement lock period in seconds.
     */
    function signAgreement(
        uint _roomId,
        uint _lockperiod
    ) external payable
        OnlyTenant(_roomId)
        notOccupied(_roomId)
        CheckAmount(_roomId)
        enoughAgreement(_roomId)
        AgreementTimesUp(_roomId)
    {
        // Increment the total number of agreements
        agreementCounter.increment();
        uint agreementId = agreementCounter.current();

        // Get the room details
        Room storage room = Rooms[_roomId];

        // Create a new RoomAgreement struct instance and initialize its values
        RoomAgreement memory newAgreement = RoomAgreement(
            _roomId,
            agreementId,
            room.room_name,
            room.room_address,
            room.rent_per_month,
            room.security_deposit,
            _lockperiod,
            block.timestamp, // Set the current timestamp as the agreement's creation timestamp
            room.landlord,
            payable(msg.sender) // Set the tenant as the one who signs the agreement
        );

        // Store the new agreement in the Agreements mapping using its ID as the key
        Agreements[agreementId] = newAgreement;

        // Update the room's agreement_id and current_tenant fields
        room.agreement_id = agreementId;
        room.current_tenant = payable(msg.sender);
        room.vacant = false; // Set the room as occupied
        room.timestamp = block.timestamp;

        // Emit an event to notify the signing of the agreement
        emit AgreementSigned(
            agreementId,
            _roomId,
            room.room_name,
            room.room_address,
            room.rent_per_month,
            room.security_deposit,
            _lockperiod,
            room.landlord,
            msg.sender
        );
    }

    /**
     * @dev Function for tenants to pay rent for a room
     * @param _roomId The ID of the room to pay rent for.
     */
    function payRent(uint _roomId) external payable
        OnlyTenant(_roomId)
        AgreementTimeLeft(_roomId)
        RentTimesUp(_roomId)
        CheckAmount(_roomId)
    {
        // Get the room details
        Room storage room = Rooms[_roomId];
        uint agreementId = room.agreement_id;

        // Increment the rent counter
        rentCounter.increment();
        uint rentId = rentCounter.current();

        // Create a new Rent struct instance and initialize its values
        Rent memory newRent = Rent(
            rentId,
            _roomId,
            agreementId,
            room.room_name,
            room.room_address,
            room.rent_per_month,
            block.timestamp, // Set the current timestamp as the rent payment timestamp
            room.landlord,
            room.current_tenant
        );

        // Store the new rent payment in the Rents mapping using its ID as the key
        Rents[rentId] = newRent;

        // Transfer the rent amount to the landlord
        (bool success, ) = room.landlord.call{value: room.rent_per_month.mul(1 ether)}("");
        require(success, "Rent payment failed");

        // Emit an event to notify the rent payment
        emit RentPaid(
            rentId,
            _roomId,
            room.room_name,
            room.room_address,
            room.rent_per_month,
            room.landlord,
            room.current_tenant
        );
    }

    /**
     * @dev Function for landlords to mark an agreement as completed for a room
     * @param _roomId The ID of the room to mark the agreement as completed for.
     */
    function agreementCompleted(uint _roomId) external
        OnlyLandlord(_roomId)
        AgreementTimeLeft(_roomId)
    {
        // Get the room details
        Room storage room = Rooms[_roomId];

        // Set the room as vacant and clear the agreement details
        room.vacant = true;
        room.agreement_id = 0;
        room.current_tenant = payable(address(0));

        // Emit an event to notify the completion of the agreement
        emit AgreementCompleted(
            _roomId,
            room.room_name,
            room.room_address,
            room.rent_per_month,
            room.landlord
        );
    }

    /**
     * @dev Function for landlords to terminate an agreement for a room
     * @param _roomId The ID of the room to terminate the agreement for.
     */
    function agreementTerminated(uint _roomId) external
        OnlyLandlord(_roomId)
    {
        // Get the room details
        Room storage room = Rooms[_roomId];

        // Calculate the termination penalty based on the security deposit
        uint terminationPenalty = room.security_deposit.mul(10).div(100); // Assuming 10% penalty

        // Transfer the termination penalty to the landlord
        (bool success, ) = room.landlord.call{value: terminationPenalty}("");
        require(success, "Termination penalty transfer failed");

        // Set the room as vacant and clear the agreement details
        room.vacant = true;
        room.agreement_id = 0;
        room.current_tenant = payable(address(0));

        // Emit an event to notify the termination of the agreement
        emit AgreementTerminated(
            _roomId,
            room.room_name,
            room.room_address,
            room.rent_per_month,
            room.landlord
        );
    }

    /**
     * @dev Function for the tenant to withdraw their security deposit after the agreement ends successfully.
     * @param _roomId The ID of the room from which the tenant wants to withdraw their security deposit.
     */
    function withdrawSecurityDeposit(uint _roomId) external OnlyTenant(_roomId) {
        Room storage room = Rooms[_roomId];
        require(!room.securityDepositWithdrawn, "Security deposit already withdrawn");

        // Transfer the security deposit to the tenant
        (bool success, ) = room.current_tenant.call{value: room.security_deposit}("");
        require(success, "Security deposit withdrawal failed");

        // Mark the security deposit as withdrawn to prevent multiple withdrawals
        room.securityDepositWithdrawn = true;
    }
}