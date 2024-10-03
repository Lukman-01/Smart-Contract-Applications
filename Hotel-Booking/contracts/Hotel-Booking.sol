// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Hotel
 * @dev A smart contract to manage hotel rooms, agreements, and rent payments.
 */
contract Hotel {
    address public contractOwner; // Address of the contract owner

    uint private roomCounter; // Counter for room IDs
    uint private agreementCounter; // Counter for agreement IDs
    uint private rentCounter; // Counter for rent IDs

    // Struct to represent a room
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

    // Mapping to store rooms using their room_id
    mapping(uint => Room) public Rooms;

    // Struct to represent an agreement for a room
    struct RoomAgreement {
        uint room_id;
        uint agreement_id;
        string room_name;
        string room_address;
        uint rent_per_month;
        uint security_deposit;
        uint timestamp;
        address payable landlord_address;
        address payable tenant_address;
    }

    // Mapping to store room agreements using their agreement_id
    mapping(uint => RoomAgreement) public Agreements;

    // Struct to represent rent payment
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

    // Mapping to store rent payments using their rent_id
    mapping(uint => Rent) public Rents;

    /**
     * @dev Modifier to check if the caller is the contract owner.
     */
    modifier OnlyOwner() {
        require(msg.sender == contractOwner, "Only the contract owner can call this function");
        _;
    }

    /**
     * @dev Modifier to check if the caller is the landlord of a specific room.
     * @param _id The ID of the room to check.
     */
    modifier OnlyLandlord(uint _id) {
        require(msg.sender == Rooms[_id].landlord, "Only landlord can call this function");
        _;
    }

    /**
     * @dev Modifier to check if the caller is the current tenant of a specific room.
     * @param _id The ID of the room to check.
     */
    modifier OnlyTenant(uint _id) {
        require(msg.sender == Rooms[_id].current_tenant, "Only tenants can call this function");
        _;
    }

    /**
     * @dev Modifier to check if a room is not occupied (vacant).
     * @param _id The ID of the room to check.
     */
    modifier notOccupied(uint _id) {
        require(Rooms[_id].vacant, "This room is occupied");
        _;
    }

    /**
     * @dev Modifier to check if the sent amount is sufficient for the rent payment.
     * @param _id The ID of the room to check.
     */
    modifier CheckAmount(uint _id) {
        require(msg.value >= Rooms[_id].rent_per_month * 1 ether, "You have insufficient amount for the rent");
        _;
    }

    /**
     * @dev Modifier to check if the sent amount is enough for an agreement.
     * @param _id The ID of the room to check.
     */
    modifier enoughAgreement(uint _id) {
        uint totalAmount = (Rooms[_id].rent_per_month + Rooms[_id].security_deposit) * 1 ether;
        require(msg.value >= totalAmount, "Not enough Agreement fee");
        _;
    }

    /**
     * @dev Modifier to check if the caller is the same tenant as the previous agreement.
     * @param _id The ID of the room to check.
     */
    modifier sameTenant(uint _id) {
        require(msg.sender == Rooms[_id].current_tenant, "No previous agreement");
        _;
    }

    /**
     * @dev Modifier to check if the agreement for a room is still valid (time left).
     * @param _id The ID of the room to check.
     */
    modifier AgreementTimeLeft(uint _id) {
        require(Agreements[Rooms[_id].agreement_id].timestamp > 0, "Agreement ended");
        _;
    }

    /**
     * @dev Modifier to check if the rent payment is overdue (30 days after the last payment).
     * @param _id The ID of the room to check.
     */
    modifier RentTimesUp(uint _id) {
        uint time = Rooms[_id].timestamp + 30 days;
        require(block.timestamp >= time, "Times Up");
        _;
    }

    /**
     * @dev Event to emit when a new room is added.
     */
    event RoomAdded(
        uint indexed roomId,
        string room_name,
        string room_address,
        uint rent_per_month,
        uint security_deposit,
        address landlord
    );

    /**
     * @dev Event to emit when an agreement is signed for a room.
     */
    event AgreementSigned(
        uint indexed agreementId,
        uint roomId,
        string room_name,
        string room_address,
        uint rent_per_month,
        uint security_deposit,
        address landlord,
        address tenant
    );

    /**
     * @dev Event to emit when a rent payment is made.
     */
    event RentPaid(
        uint rentId,
        uint indexed roomId,
        string room_name,
        string room_address,
        uint rent_per_month,
        address indexed landlord,
        address indexed tenant
    );

    /**
     * @dev Event to emit when an agreement is completed.
     */
    event AgreementCompleted(
        uint indexed roomId,
        string room_name,
        string room_address,
        uint rent_per_month,
        address indexed landlord
    );

    /**
     * @dev Event to emit when an agreement is terminated.
     */
    event AgreementTerminated(
        uint indexed roomId,
        string room_name,
        string room_address,
        uint rent_per_month,
        address indexed landlord
    );

    /**
     * @dev Contract constructor.
     * Initializes the contract owner.
     */
    constructor() {
        contractOwner = msg.sender;
    }

    /**
     * @dev Function to add a new room to the contract.
     * Only the contract owner can call this function.
     */
    function addRoom(
        string memory _roomName,
        string memory _roomAddress,
        uint _rentPerMonth,
        uint _securityDeposit
    ) external OnlyOwner {
        roomCounter++;
        uint roomId = roomCounter;

        Room memory newRoom = Room({
            room_id: roomId,
            agreement_id: 0,
            room_name: _roomName,
            room_address: _roomAddress,
            rent_per_month: _rentPerMonth,
            security_deposit: _securityDeposit,
            timestamp: block.timestamp,
            vacant: true,
            landlord: payable(msg.sender),
            current_tenant: payable(address(0)),
            securityDepositWithdrawn: false
        });

        Rooms[roomId] = newRoom;

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
     * @dev Function for a tenant to sign an agreement and rent a room.
     */
    function signAgreement(uint _roomId) external payable
        notOccupied(_roomId)
        CheckAmount(_roomId)
        enoughAgreement(_roomId)
        AgreementTimeLeft(_roomId)
    {
        agreementCounter++;
        uint agreementId = agreementCounter;

        Room storage room = Rooms[_roomId];

        RoomAgreement memory newAgreement = RoomAgreement({
            room_id: _roomId,
            agreement_id: agreementId,
            room_name: room.room_name,
            room_address: room.room_address,
            rent_per_month: room.rent_per_month,
            security_deposit: room.security_deposit,
            timestamp: block.timestamp,
            landlord_address: room.landlord,
            tenant_address: payable(msg.sender)
        });

        Agreements[agreementId] = newAgreement;

        room.agreement_id = agreementId;
        room.current_tenant = payable(msg.sender);
        room.vacant = false;
        room.timestamp = block.timestamp;

        emit AgreementSigned(
            agreementId,
            _roomId,
            room.room_name,
            room.room_address,
            room.rent_per_month,
            room.security_deposit,
            room.landlord,
            msg.sender
        );
    }

    /**
     * @dev Function for a tenant to pay rent for a room.
     */
    function payRent(uint _roomId) external payable
        OnlyTenant(_roomId)
        RentTimesUp(_roomId)
        CheckAmount(_roomId)
    {
        Room storage room = Rooms[_roomId];
        uint agreementId = room.agreement_id;

        rentCounter++;
        uint rentId = rentCounter;

        Rent memory newRent = Rent({
            rent_id: rentId,
            room_id: _roomId,
            agreement_id: agreementId,
            room_name: room.room_name,
            room_address: room.room_address,
            rent_per_month: room.rent_per_month,
            timestamp: block.timestamp,
            landlord_address: room.landlord,
            tenant_address: room.current_tenant
        });

        Rents[rentId] = newRent;

        (bool success, ) = room.landlord.call{value: room.rent_per_month * 1 ether}("");
        require(success, "Rent payment failed");

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
     * @dev Function for a landlord to mark the completion of an agreement.
     */
    function agreementCompleted(uint _roomId) external
        OnlyLandlord(_roomId)
    {
        Room storage room = Rooms[_roomId];

        room.vacant = true;
        room.agreement_id = 0;
        room.current_tenant = payable(address(0));

        emit AgreementCompleted(
            _roomId,
            room.room_name,
            room.room_address,
            room.rent_per_month,
            room.landlord
        );
    }

    /**
     * @dev Function for a landlord to terminate an agreement.
     */
    function agreementTerminated(uint _roomId) external
        OnlyLandlord(_roomId)
    {
        Room storage room = Rooms[_roomId];

        uint terminationPenalty = (room.security_deposit * 10) / 100;
        (bool success, ) = room.landlord.call{value: terminationPenalty}("");
        require(success, "Termination penalty transfer failed");

        room.vacant = true;
        room.agreement_id = 0;
        room.current_tenant = payable(address(0));

        emit AgreementTerminated(
            _roomId,
            room.room_name,
            room.room_address,
            room.rent_per_month,
            room.landlord
        );
    }

    /**
     * @dev Function for a tenant to withdraw their security deposit after the agreement ends.
     */
    function withdrawSecurityDeposit(uint _roomId) external OnlyTenant(_roomId) {
        Room storage room = Rooms[_roomId];
        require(!room.securityDepositWithdrawn, "Security deposit already withdrawn");

        (bool success, ) = room.current_tenant.call{value: room.security_deposit}("");
        require(success, "Security deposit withdrawal failed");

        room.securityDepositWithdrawn = true;
    }

    /**
     * @dev Function to get the number of vacant rooms in the hotel contract.
     */
    function getNumberOfRoomsAvailable() external view returns (uint) {
        uint numberOfVacantRooms = 0;
        for (uint i = 1; i <= roomCounter; i++) {
            if (Rooms[i].vacant) {
                numberOfVacantRooms++;
            }
        }
        return numberOfVacantRooms;
    }

    /**
     * @dev Function to get the total number of rooms in the hotel contract.
     */
    function getTotalNumberOfRooms() external view returns (uint) {
        return roomCounter;
    }

    /**
     * @dev Function to get the total number of rooms that are currently rented in the hotel contract.
     */
    function getTotalNumberOfRoomsRented() external view returns (uint) {
        uint numberOfRentedRooms = 0;
        for (uint i = 1; i <= roomCounter; i++) {
            if (!Rooms[i].vacant) {
                numberOfRentedRooms++;
            }
        }
        return numberOfRentedRooms;
    }
}
