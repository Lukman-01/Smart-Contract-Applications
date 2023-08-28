// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract SocioMedia {
    struct  User {
    string name;
    string bio;
    address[] friends;
    Message[] messages;
    }

    mapping ((address) => User) public users;
    struct Message{
        address sender;
        address recipient;
        string content;
        uint timestamp;
    }

    Message[] public messages;

    
}
