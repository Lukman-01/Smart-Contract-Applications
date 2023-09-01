// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Lock is Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _voterId;
    Counters.Counter private _candidateId;

    struct Candidate {
        uint256 candidateId;
        string name;
        string age;
        string image;
        uint256 voteCount;
        address _address;
        string ipfs;
    }

    mapping(address => Candidate) public candidates;
    address[] public candidateAddresses;

    event CandidateCreated(
        uint256 indexed candidateId,
        string name,
        string age,
        string image,
        uint256 voteCount,
        address _address,
        string ipfs
    );

    struct Voter {
        uint256 voterId;
        string name;
        string image;
        uint256 allowed;
        bool voted;
        uint256 voterVote; // Renamed parameter to resolve the conflict
        string ipfs;
    }

    mapping(address => Voter) public voters;
    address[] public votedVoters;
    address[] public voterAddresses;

    event VoterCreated(
        uint256 indexed voterId,
        string name,
        string image,
        uint256 allowed,
        bool voted,
        uint256 voterVote, // Renamed parameter to match the struct field
        string ipfs
    );

    constructor() {
        _candidateId.increment();
        _voterId.increment();
    }

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

    function getCandidateAddresses() external view returns (address[] memory) {
        return candidateAddresses;
    }

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

    function getCandidateCount() external view returns (uint256) {
        return candidateAddresses.length;
    }

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

    function getVoterCount() external view returns (uint256) {
        return voterAddresses.length;
    }

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

    function getVotedVoters() external view returns (address[] memory) {
        return votedVoters;
    }

    function getVoterList() external view returns (address[] memory) {
        return voterAddresses;
    }
}
