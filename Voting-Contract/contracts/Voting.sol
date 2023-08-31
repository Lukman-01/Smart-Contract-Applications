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
}
