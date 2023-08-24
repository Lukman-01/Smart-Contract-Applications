const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MedicalHistory", function () {
  let MedicalHistory;
  let medicalHistory;

  before(async function () {
    MedicalHistory = await ethers.getContractFactory("MedicalHistory");
    medicalHistory = await MedicalHistory.deploy(["0xAuthorizedDoctor1", "0xAuthorizedDoctor2"]);
    await medicalHistory.deployed();
  });

  it("Should add a patient", async function () {
    const addTx = await medicalHistory.addPatient(
      "John Doe",
      30,
      ["Condition1", "Condition2"],
      ["Allergy1", "Allergy2"],
      ["Medication1", "Medication2"],
      ["Procedure1", "Procedure2"]
    );

    await addTx.wait();

    const patient = await medicalHistory.getPatient(0);

    expect(patient._name).to.equal("John Doe");
    expect(patient._age).to.equal(30);
    expect(patient._conditions).to.deep.equal(["Condition1", "Condition2"]);
    expect(patient._allergies).to.deep.equal(["Allergy1", "Allergy2"]);
    expect(patient._medications).to.deep.equal(["Medication1", "Medication2"]);
    expect(patient._procedures).to.deep.equal(["Procedure1", "Procedure2"]);
  });

  it("Should update a patient's information", async function () {
    // Deploy a patient or use the one added in the previous test

    const updateTx = await medicalHistory.updatePatient(
      0,
      "Updated Name",
      31,
      ["Updated Condition"],
      ["Updated Allergy"],
      ["Updated Medication"],
      ["Updated Procedure"]
    );

    await updateTx.wait();

    const patient = await medicalHistory.getPatient(0);

    expect(patient._name).to.equal("Updated Name");
    expect(patient._age).to.equal(31);
    expect(patient._conditions).to.deep.equal(["Updated Condition"]);
    expect(patient._allergies).to.deep.equal(["Updated Allergy"]);
    expect(patient._medications).to.deep.equal(["Updated Medication"]);
    expect(patient._procedures).to.deep.equal(["Updated Procedure"]);
  });

  it("Should get patient information", async function () {
    const patient = await medicalHistory.getPatient(0);

    expect(patient._name).to.equal("Updated Name");
    expect(patient._age).to.equal(31);
    expect(patient._conditions).to.deep.equal(["Updated Condition"]);
    expect(patient._allergies).to.deep.equal(["Updated Allergy"]);
    expect(patient._medications).to.deep.equal(["Updated Medication"]);
    expect(patient._procedures).to.deep.equal(["Updated Procedure"]);
  });

});
