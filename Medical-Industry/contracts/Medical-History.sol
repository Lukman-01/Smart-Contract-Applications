// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MedicalHistory is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private patientIds;

    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR_ROLE");

    struct Patient {
        string name;
        uint age;
        string[] conditions;
        string[] allergies;
        string[] medications;
        string[] procedures;
        uint256 lastUpdated;
    }

    mapping(uint256 => Patient) public patients;

    constructor(address[] memory _initialDoctors) {
        for (uint256 i = 0; i < _initialDoctors.length; i++) {
            _setupRole(DOCTOR_ROLE, _initialDoctors[i]);
        }
    }

    modifier onlyDoctor() {
        require(hasRole(DOCTOR_ROLE, msg.sender), "Restricted to doctors");
        _;
    }

    function addPatient(
        string memory _name,
        uint _age,
        string[] memory _conditions,
        string[] memory _allergies,
        string[] memory _medications,
        string[] memory _procedures
    ) public onlyDoctor {
        uint256 patientId = patientIds.current();
        patients[patientId] = Patient({
            name: _name,
            age: _age,
            conditions: _conditions,
            allergies: _allergies,
            medications: _medications,
            procedures: _procedures,
            lastUpdated: block.timestamp
        });
        patientIds.increment();
    }

    function updatePatient(
        uint256 _patientId,
        string memory _name,
        uint _age,
        string[] memory _conditions,
        string[] memory _allergies,
        string[] memory _medications,
        string[] memory _procedures
    ) public onlyDoctor {
        Patient storage patient = patients[_patientId];
        patient.name = _name;
        patient.age = _age;
        patient.conditions = _conditions;
        patient.allergies = _allergies;
        patient.medications = _medications;
        patient.procedures = _procedures;
        patient.lastUpdated = block.timestamp;
    }

    function getPatient(uint256 _patientId) public view returns (
        string memory _name,
        uint _age,
        string[] memory _conditions,
        string[] memory _allergies,
        string[] memory _medications,
        string[] memory _procedures,
        uint256 _lastUpdated
    ) {
        Patient storage patient = patients[_patientId];
        return (
            patient.name,
            patient.age,
            patient.conditions,
            patient.allergies,
            patient.medications,
            patient.procedures,
            patient.lastUpdated
        );
    }
}
