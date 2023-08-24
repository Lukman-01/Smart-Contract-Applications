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
}
