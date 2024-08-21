// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Lottery {
    // Entities: manager, players, and winner
    address public manager;
    address payable[] public players;
    address payable public winner;

    // Reentrancy guard variable
    bool private locked = false;

    event PlayerParticipated(address indexed player);
    event WinnerPicked(address indexed winner, uint256 amount);

    modifier onlyManager() {
        require(msg.sender == manager, "You are not the manager");
        _;
    }

    modifier noReentrant() {
        require(!locked, "ReentrancyGuard: reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        manager = msg.sender;
    }

    function participate() public payable {
        require(msg.value == 1 ether, "Please pay exactly 1 ether to participate");
        players.push(payable(msg.sender));
        emit PlayerParticipated(msg.sender);
    }

    function getBalance() public view onlyManager returns (uint256) {
        return address(this).balance;
    }

    function random() internal view returns (uint256) {
        // Using keccak256 with block prevrandao, timestamp, and player length to generate randomness
        return uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, players.length)));
    }

    function pickWinner() public onlyManager noReentrant {
        require(players.length >= 3, "Players are less than 3");

        uint256 r = random();
        uint256 index = r % players.length;
        winner = players[index];

        // Transfer balance to the winner
        winner.transfer(address(this).balance);
        emit WinnerPicked(winner, address(this).balance);

        // Reset the players array
        delete players;
    }
}
