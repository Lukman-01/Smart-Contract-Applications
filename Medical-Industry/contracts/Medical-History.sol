// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract MedicalHistory {
    struct Patient {
        string name;
        uint age;
        string[] conditions;
        string[] allergies;
        string[] medications;
        string[] procedures;
        uint256 lastUpdated; // Timestamp of the last update
    }

    mapping(address => Patient) public Patients;
    mapping(address => bool) public authorizedDoctors;

    modifier onlyAuthorizedDoctor() {
        require(authorizedDoctors[msg.sender], "Unauthorized doctor");
        _;
    }

    constructor(address[] memory _doctors) {
        for (uint256 i = 0; i < _doctors.length; i++) {
            authorizedDoctors[_doctors[i]] = true;
        }
    }

    function addPatient(
        address _patientAddress,
        string memory _name,
        uint _age,
        string[] memory _conditions,
        string[] memory _allergies,
        string[] memory _medications,
        string[] memory _procedures
    ) public onlyAuthorizedDoctor {
        Patients[_patientAddress] = Patient({
            name: _name,
            age: _age,
            conditions: _conditions,
            allergies: _allergies,
            medications: _medications,
            procedures: _procedures,
            lastUpdated: block.timestamp
        });
    }

    function updatePatient(
        address _patientAddress,
        string memory _name,
        uint _age,
        string[] memory _conditions,
        string[] memory _allergies,
        string[] memory _medications,
        string[] memory _procedures
    ) public onlyAuthorizedDoctor {
        Patient storage patient = Patients[_patientAddress];
        patient.name = _name;
        patient.age = _age;
        patient.conditions = _conditions;
        patient.allergies = _allergies;
        patient.medications = _medications;
        patient.procedures = _procedures;
        patient.lastUpdated = block.timestamp;
    }

    function getPatient(address _patientAddress) public view returns (
        string memory _name,
        uint _age,
        string[] memory _conditions,
        string[] memory _allergies,
        string[] memory _medications,
        string[] memory _procedures,
        uint256 _lastUpdated
    ) {
        Patient storage patient = Patients[_patientAddress];
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
