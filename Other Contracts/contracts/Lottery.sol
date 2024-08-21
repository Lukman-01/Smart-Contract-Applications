// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lottery
 * @dev A simple lottery contract where participants can join by paying 1 ether, 
 * and a manager can pick a random winner who will receive the entire balance of the contract.
 */
contract Lottery {
    // Address of the contract manager (the one who deployed the contract)
    address public manager;
    
    // Dynamic array of addresses representing the players participating in the lottery
    address payable[] public players;
    
    // Address of the winner, payable to allow sending ether to the winner
    address payable public winner;

    // Reentrancy guard state variable to prevent reentrant calls to functions
    bool private locked = false;

    // Event emitted when a player successfully participates in the lottery
    event PlayerParticipated(address indexed player);
    
    // Event emitted when a winner is picked and awarded the balance
    event WinnerPicked(address indexed winner, uint256 amount);

    /**
     * @dev Modifier to restrict access to only the manager of the contract.
     */
    modifier onlyManager() {
        require(msg.sender == manager, "You are not the manager");
        _;
    }

    /**
     * @dev Modifier to prevent reentrant calls to a function.
     */
    modifier noReentrant() {
        require(!locked, "ReentrancyGuard: reentrant call");
        locked = true;
        _;
        locked = false;
    }

    /**
     * @dev Constructor sets the deployer of the contract as the manager.
     */
    constructor() {
        manager = msg.sender;
    }

    /**
     * @dev Allows a player to participate in the lottery by sending exactly 1 ether.
     * The player's address is added to the players array.
     * Emits a PlayerParticipated event on success.
     */
    function participate() public payable {
        require(msg.value == 1 ether, "Please pay exactly 1 ether to participate");
        players.push(payable(msg.sender));
        emit PlayerParticipated(msg.sender);
    }

    /**
     * @dev Returns the current balance of the contract.
     * Can only be called by the manager.
     * @return The balance of the contract in wei.
     */
    function getBalance() public view onlyManager returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Internal function to generate a pseudo-random number based on block data and the number of players.
     * @return A pseudo-random uint256.
     */
    function random() internal view returns (uint256) {
        // Generates a pseudo-random number using block.prevrandao, block.timestamp, and the length of the players array
        return uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, players.length)));
    }

    /**
     * @dev Allows the manager to pick a winner randomly from the list of players.
     * Requires a minimum of 3 players to participate. 
     * The winner receives the entire balance of the contract, and the players array is reset.
     * Emits a WinnerPicked event on success.
     */
    function pickWinner() public onlyManager noReentrant {
        require(players.length >= 3, "Players are less than 3");

        // Generate a random index based on the number of players
        uint256 r = random();
        uint256 index = r % players.length;
        winner = players[index];

        // Transfer the entire contract balance to the winner
        winner.transfer(address(this).balance);
        emit WinnerPicked(winner, address(this).balance);

        // Reset the players array to start a new round of the lottery
        delete players;
    }
}
