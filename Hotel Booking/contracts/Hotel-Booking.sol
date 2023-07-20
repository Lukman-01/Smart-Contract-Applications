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

}