// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
contract Lock {
    using Counters for Counters.Counter;

    Counters.Counter public _voterId;
    Counters.Counter public _candidateId;

    address public votingOrganizer;

    struct Candidate {
        uint candidateId;
        string name;
        string age;
        string image;
        uint voteCount;
        address _address;
        string ipfs;
    }

    event CandidateCreated(
        uint  indexed candidateId,
        string name,
        string age,
        string image,
        uint voteCount,
        address _address,
        string ipfs
    );

    address[] public candidateAddress;

    mapping (address => Candidate) public candidates;

    struct Voter{
        uint voter_voterId;
        string voter_name;
        string voter_image;
        address voter_address;
        uint voter_allowed;
        bool voter_voted;
        uint voter_vote;
        string voter_ipfs;
    }

    mapping(address => Voter) public voters;
    address[] public votedVoters;
    address[] public votersAddress;

    event VoterCreated(
        uint indexed voter_voterId,
        string voter_name,
        string voter_image,
        address voter_address,
        uint voter_allowed,
        bool voter_voted,
        uint voter_vote,
        string voter_ipfs
    );

    constructor (){
        votingOrganizer = msg.sender;
    }

    function setCandidate(address _add, string memory _name, string memory _age, string memory _image, string memory _ipfs) public {
        require(votingOrganizer == msg.sender, "Only Organizer can authorize candidate");

        _candidateId.increment();
        uint idNumber = _candidateId.current();

        Candidate storage candidate = candidates[_add];
        candidate.candidateId = idNumber;
        candidate.name = _name;
        candidate.age = _age;
        candidate.image = _image;
        candidate.voteCount = 0;
        candidate._address = _add;
        candidate.ipfs = _ipfs;

        candidateAddress.push(_add);

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

    function getCandidateAddresses() public view returns (address[] memory) {
        return candidateAddress;
    }

    function getCandidateData(address _candidateAddress) public view returns (
        string memory name,
        string memory age,
        string memory image,
        uint voteCount,
        string memory ipfs
    ) {
        Candidate memory candidate = candidates[_candidateAddress];
        return (
            candidate.name,
            candidate.age,
            candidate.image,
            candidate.voteCount,
            candidate.ipfs
        );
    }

    function getCandidateLength() public view returns (uint) {
        return candidateAddress.length;
    }

    function voterRight(
        address _add,
        string memory _name,
        string memory _image,
        string memory _ipfs
    ) public {
        require(votingOrganizer == msg.sender, "Only Organizer can authorize voter");
        _voterId.increment();
        uint idNumber = _voterId.current();

        Voter storage voter = voters[_add];
        require(voter.voter_allowed == 0, "Already registered");

        voter.voter_voterId = idNumber;
        voter.voter_name = _name;
        voter.voter_image = _image;
        voter.voter_address = _add;
        voter.voter_allowed = 1;
        voter.voter_voted = false;
        voter.voter_vote = 0;
        voter.voter_ipfs = _ipfs;

        votersAddress.push(_add);

        emit VoterCreated(
            idNumber,
            _name,
            _image,
            _add,
            1,
            false,
            0,
            _ipfs
        );
    }

    function vote(address _candidateAddress, uint _candidateVoteId) public {
        require(voters[msg.sender].voter_allowed == 1, "You are not authorized to vote");
        require(voters[msg.sender].voter_voted == false, "You have already voted");
        require(candidates[_candidateAddress]._address != address(0), "Candidate not found");
        require(candidates[_candidateAddress].candidateId == _candidateVoteId, "Invalid candidate ID");

        candidates[_candidateAddress].voteCount++;
        voters[msg.sender].voter_voted = true;
        voters[msg.sender].voter_vote = _candidateVoteId;

        votedVoters.push(msg.sender);
    }

    function getVoterLength() public view returns (uint) {
        return votersAddress.length;
    }

    function getVotersData(address _voterAddress) public view returns (
        uint voter_voterId,
        string memory voter_name,
        string memory voter_image,
        uint voter_allowed,
        bool voter_voted,
        uint voter_vote,
        string memory voter_ipfs
    ) {
        Voter memory voter = voters[_voterAddress];
        return (
            voter.voter_voterId,
            voter.voter_name,
            voter.voter_image,
            voter.voter_allowed,
            voter.voter_voted,
            voter.voter_vote,
            voter.voter_ipfs
        );
    }

    function getVotedVoters() public view returns (address[] memory) {
        return votedVoters;
    }

    function getVoterList() public view returns (address[] memory) {
        return votersAddress;
    }
}
