// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract MedicalHistory {
     
    struct Patient{
        string name;
        uint age;
        string[] conditions;
        string[] allergies;
        string[] medications;
        string[] procedures;
    }

    mapping(address => Patient) public Patients;

    function addPatient(
        string memory _name,
        uint _age,
        string[] memory _conditions,
        string[] memory _allergies,
        string[] memory _medications,
        string[] memory _procedures
    ) public {
        Patients[msg.sender] = Patient({
            name: _name,
            age: _age,
            conditions: _conditions,
            allergies: _allergies,
            medications: _medications,
            procedures: _procedures
        });
    }

    function updatePatient(
        string memory _name,
        uint _age,
        string[] memory _conditions,
        string[] memory _allergies,
        string[] memory _medications,
        string[] memory _procedures
    ) public {
        Patient storage patient = Patients[msg.sender];
        patient.name = _name;
        patient.age = _age;
        patient.conditions = _conditions;
        patient.allergies = _allergies;
        patient.medications = _medications;
        patient.procedures = _procedures;
    }
    
}
