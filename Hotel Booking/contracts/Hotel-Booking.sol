// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Hotel{
    address payable landlord;
    address payable tenant;

    uint no_of_rooms = 0;
    uint no_of_rent = 0;
    uint no_of_agreement = 0;

    struct Room{
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
    }

    mapping(uint => Room) public Rooms;

    struct RoomAgreement{
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

    mapping(uint => RoomAgreement) public Agreements;

    struct Rent{
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

    mapping(uint => Rent) public Rents;

    modifier OnlyLandlord(uint _id){
        require(msg.sender == Rooms[_id].landlord, "Only landlord can call this function");
        _;
    }

    modifier OnlyTenant(uint _id){
        require(msg.sender == Rooms[_id].current_tenant, "Only tenants can call this function");
        _;
    }

    modifier Occupied(uint _id){
        require(Rooms[_id].vacant == true, "This room is occupied");
        _;
    }

    modifier CheckAmount(uint _id){
        require(msg.value >= uint(Rooms[_id].rent_per_month * 1 ether), "You have insufficient amount for the rent");
        _;
    }

    modifier enoughAgreement(uint _id){
        require(msg.value >= uint(uint(Rooms[_id].rent_per_month) + uint(Rooms[_id].security_deposit)), "Not enough Agreement fee");
        _;
    }

    modifier sameTenant(uint _id){
        require(msg.sender == Rooms[_id].current_tenant, "No previous agreement");
        _;
    }

    modifier AgreementTimeLeft(uint _id){
        uint agrId = Rooms[_id].agreement_id;
        uint time = Agreements[agrId].timestamp + Agreements[agrId].lockperiod;
        require(block.timestamp < time, "Agreement ended");
        _;
    }

    modifier AgreementTimesUp(uint _id){
        uint agrId = Rooms[_id].agreement_id;
        uint time = Agreements[agrId].timestamp + Agreements[agrId].lockperiod;
        require(block.timestamp > time, "There is still some time left");
        _;
    }

    modifier RentTimesUp(uint _id){
        uint time = Rooms[_id].timestamp + 30 days;
        require(block.timestamp >= time, "Times Up");
        _;
    }

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

    
}