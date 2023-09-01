// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import Ownable from OpenZeppelin for access control.
import "@openzeppelin/contracts/access/Ownable.sol";

// Import Counters from OpenZeppelin for counting operations.
import "@openzeppelin/contracts/utils/Counters.sol";

// Import SafeMath from OpenZeppelin for safe arithmetic operations.
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title Voting
 * @dev A smart contract for managing candidates and voters in an election.
 * It extends the Ownable contract to provide basic access control.
 */

contract Voting is Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    // Counter for assigning unique voter IDs.
    Counters.Counter private _voterId;

    // Counter for assigning unique candidate IDs.
    Counters.Counter private _candidateId;

    // Struct to represent a Candidate.
    struct Candidate {
        uint256 candidateId;
        string name;
        string age;
        string image;
        uint256 voteCount;
        address _address;
        string ipfs;
    }

    // Mapping to store candidate information by their Ethereum address.
    mapping(address => Candidate) public candidates;

    // Array to store candidate addresses for enumeration.
    address[] public candidateAddresses;

    // Event to log the creation of a new candidate.
    event CandidateCreated(
        uint256 indexed candidateId,
        string name,
        string age,
        string image,
        uint256 voteCount,
        address _address,
        string ipfs
    );

    // Struct to represent a Voter.
    struct Voter {
        uint256 voterId;
        string name;
        string image;
        uint256 allowed;
        bool voted;
        uint256 voterVote; // Renamed parameter to resolve the conflict
        string ipfs;
    }

    // Mapping to store voter information by their Ethereum address.
    mapping(address => Voter) public voters;

    // Array to store addresses of voters who have voted.
    address[] public votedVoters;

    // Array to store all registered voter addresses for enumeration.
    address[] public voterAddresses;

    // Event to log the creation of a new voter.
    event VoterCreated(
        uint256 indexed voterId,
        string name,
        string image,
        uint256 allowed,
        bool voted,
        uint256 voterVote, // Renamed parameter to match the struct field
        string ipfs
    );

    /**
     * @dev Constructor function.
     * It initializes the contract and increments the voter and candidate IDs.
     */
    constructor() {
        _candidateId.increment();
        _voterId.increment();
    }

    /**
     * @dev Function to add a new candidate to the election.
     * Only the contract owner can call this function.
     * @param _add The Ethereum address of the candidate.
     * @param _name The name of the candidate.
     * @param _age The age of the candidate.
     * @param _image The image URL of the candidate.
     * @param _ipfs The IPFS hash of additional candidate information.
     */
    function setCandidate(
        address _add,
        string memory _name,
        string memory _age,
        string memory _image,
        string memory _ipfs
    ) external onlyOwner {
        _candidateId.increment();
        uint256 idNumber = _candidateId.current();

        Candidate storage candidate = candidates[_add];
        candidate.candidateId = idNumber;
        candidate.name = _name;
        candidate.age = _age;
        candidate.image = _image;
        candidate.voteCount = 0;
        candidate._address = _add;
        candidate.ipfs = _ipfs;

        candidateAddresses.push(_add);

        emit CandidateCreated(
            idNumber,
            _name,
            _age,
            _image,
            0,
            _add,
            _ipfs
        );
    }

    /**
     * @dev Function to get the addresses of all registered candidates.
     * @return An array of candidate addresses.
     */
    function getCandidateAddresses() external view returns (address[] memory) {
        return candidateAddresses;
    }

    /**
     * @dev Function to get the data of a specific candidate by their address.
     * @param _candidateAddress The Ethereum address of the candidate.
     * @return name The name of the candidate.
     * @return age The age of the candidate.
     * @return image The image URL of the candidate.
     * @return voteCount The vote count received by the candidate.
     * @return ipfs The IPFS hash of additional candidate information.
     */
    function getCandidateData(address _candidateAddress)
        external
        view
        returns (
            string memory name,
            string memory age,
            string memory image,
            uint256 voteCount,
            string memory ipfs
        )
    {
        Candidate memory candidate = candidates[_candidateAddress];
        return (
            candidate.name,
            candidate.age,
            candidate.image,
            candidate.voteCount,
            candidate.ipfs
        );
    }

    /**
     * @dev Function to get the total count of registered candidates.
     * @return The total count of candidates.
     */
    function getCandidateCount() external view returns (uint256) {
        return candidateAddresses.length;
    }

    /**
     * @dev Function to register a new voter for the election.
     * Only the contract owner can call this function.
     * @param _add The Ethereum address of the voter.
     * @param _name The name of the voter.
     * @param _image The image URL of the voter.
     * @param _ipfs The IPFS hash of additional voter information.
     */
    function voterRight(
        address _add,
        string memory _name,
        string memory _image,
        string memory _ipfs
    ) external onlyOwner {
        _voterId.increment();
        uint256 idNumber = _voterId.current();

        Voter storage voter = voters[_add];
        require(voter.allowed == 0, "Already registered");

        voter.voterId = idNumber;
        voter.name = _name;
        voter.image = _image;
        voter.allowed = 1;
        voter.voted = false;
        voter.voterVote = 0;
        voter.ipfs = _ipfs;

        voterAddresses.push(_add);

        emit VoterCreated(
            idNumber,
            _name,
            _image,
            1,
            false,
            0,
            _ipfs
        );
    }

    /**
     * @dev Function to allow a voter to cast a vote for a candidate.
     * @param _candidateAddress The Ethereum address of the candidate being voted for.
     * @param _candidateVoteId The candidate ID to validate the vote.
     */
    function vote(address _candidateAddress, uint256 _candidateVoteId)
        external
    {
        Voter storage voter = voters[msg.sender];
        require(voter.allowed == 1, "You are not authorized to vote");
        require(!voter.voted, "You have already voted");
        require(
            candidates[_candidateAddress]._address != address(0),
            "Candidate not found"
        );
        require(
            candidates[_candidateAddress].candidateId == _candidateVoteId,
            "Invalid candidate ID"
        );

        candidates[_candidateAddress].voteCount = candidates[_candidateAddress]
            .voteCount
            .add(1);
        voter.voted = true;
        voter.voterVote = _candidateVoteId;

        votedVoters.push(msg.sender);
    }

    /**
     * @dev Function to get the total count of registered voters.
     * @return The total count of voters.
     */
    function getVoterCount() external view returns (uint256) {
        return voterAddresses.length;
    }

    /**
     * @dev Function to get the data of a specific voter by their address.
     * @param _voterAddress The Ethereum address of the voter.
     * @return voterId The voter's unique ID.
     * @return name The name of the voter.
     * @return image The image URL of the voter.
     * @return allowed The voter's allowed status (1 for allowed, 0 for not allowed).
     * @return voted A boolean indicating whether the voter has voted.
     * @return voterVote The ID of the candidate the voter voted for.
     * @return ipfs The IPFS hash of additional voter information.
     */
    function getVoterData(address _voterAddress)
        external
        view
        returns (
            uint256 voterId,
            string memory name,
            string memory image,
            uint256 allowed,
            bool voted,
            uint256 voterVote, // Renamed parameter to match the struct field
            string memory ipfs
        )
    {
        Voter memory voter = voters[_voterAddress];
        return (
            voter.voterId,
            voter.name,
            voter.image,
            voter.allowed,
            voter.voted,
            voter.voterVote,
            voter.ipfs
        );
    }

    /**
     * @dev Function to get the addresses of voters who have already voted.
     * @return An array of addresses of voted voters.
     */
    function getVotedVoters() external view returns (address[] memory) {
        return votedVoters;
    }

    /**
     * @dev Function to get the addresses of all registered voters.
     * @return An array of all registered voter addresses.
     */
    function getVoterList() external view returns (address[] memory) {
        return voterAddresses;
    }
}
