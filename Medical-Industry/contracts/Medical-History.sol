// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title MedicalHistory
 * @dev A smart contract for managing patient medical history.
 */
contract MedicalHistory {
    uint256 private patientIdCounter; // Manual counter for patient IDs
    address public owner;

    mapping(address => bool) public doctors;

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

    /**
     * @dev Constructor to initialize the contract with initial authorized doctors.
     * @param _initialDoctors Addresses of initial authorized doctors.
     */
    constructor(address[] memory _initialDoctors) {
        owner = msg.sender;
        for (uint256 i = 0; i < _initialDoctors.length; i++) {
            doctors[_initialDoctors[i]] = true;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Restricted to contract owner");
        _;
    }

    modifier onlyDoctor() {
        require(doctors[msg.sender], "Restricted to authorized doctors");
        _;
    }

    /**
     * @dev Adds a new doctor to the list of authorized doctors.
     * @param _doctor Address of the new doctor.
     */
    function addDoctor(address _doctor) public onlyOwner {
        doctors[_doctor] = true;
    }

    /**
     * @dev Adds a new patient to the medical history.
     * @param _name Name of the patient.
     * @param _age Age of the patient.
     * @param _conditions List of medical conditions of the patient.
     * @param _allergies List of allergies of the patient.
     * @param _medications List of medications prescribed to the patient.
     * @param _procedures List of medical procedures undergone by the patient.
     */
    function addPatient(
        string memory _name,
        uint _age,
        string[] memory _conditions,
        string[] memory _allergies,
        string[] memory _medications,
        string[] memory _procedures
    ) public onlyDoctor {
        uint256 patientId = patientIdCounter;
        patients[patientId] = Patient({
            name: _name,
            age: _age,
            conditions: _conditions,
            allergies: _allergies,
            medications: _medications,
            procedures: _procedures,
            lastUpdated: block.timestamp
        });
        patientIdCounter++;
    }

    /**
     * @dev Updates patient information.
     * @param _patientId Id of the patient to update.
     * @param _name Updated name of the patient.
     * @param _age Updated age of the patient.
     * @param _conditions Updated list of medical conditions.
     * @param _allergies Updated list of allergies.
     * @param _medications Updated list of medications.
     * @param _procedures Updated list of medical procedures.
     */
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

    /**
     * @dev Retrieves patient information.
     * @param _patientId Id of the patient to retrieve information for.
     * @return _name Name of the patient.
     * @return _age Age of the patient.
     * @return _conditions List of medical conditions.
     * @return _allergies List of allergies.
     * @return _medications List of medications.
     * @return _procedures List of medical procedures.
     * @return _lastUpdated Timestamp of the last update.
     */
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
