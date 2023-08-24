// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract MedicalHistory {
     
    struct Patient{
        string name;
        uint age;
        string[] conditions;
        string[] alergies;
        string[] medications;
        string procedures;
    }

    mapping(address => Patient) public Patients;


}
