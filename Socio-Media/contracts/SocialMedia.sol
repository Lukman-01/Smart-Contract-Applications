// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract SocioMedia {
    struct  User {
    string name;
    string bio;
    address[] friends;
    Message[] messages;
    }

    mapping (address => User) public users;
    struct Message{
        address sender;
        address recipient;
        string content;
        uint timestamp;
    }

    Message[] public messages;

    function createUser(string memory _name, string memory _bio) public{
        User memory newUser = User(_name, _bio, new address[](0), new Message[](0));
        users[msg.sender] = newUser;
    }

    function makeFriend(address _friend) public{
        require (users[_friend].name != "", "User does not exist");
        require (!isFriend[_friend], "Friend already exist");

        users[msg.sender].friends.push(_friend);
        users[_friend].friends.push(msg.sender);
    }

    function deleteAcount() public{
        delete users[msg.sender];
    }

    function updateAccount(string memory _name, string memory _bio) public{
        users[msg.sender].name = _name;
        users[msg.sender].bio = _bio;  
    }

    function sendmessage(address _recipient, string memory _content) public{
        require(users[_recipient].name != "", "Recipient doesnot exist");

        Message memory newMessage = Message(msg.sender, _recipient, _content, block.timestamp);
        users[msg.sender].messages.push(newMessage);
        users[_recipient].messages.push(newMessage);
        messages.push(newMessage);
    }

    
}
