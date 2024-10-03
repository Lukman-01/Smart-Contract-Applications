const hre = require("hardhat");

async function main() {
  const MedicalHistory = await hre.ethers.getContractFactory("MedicalHistory");

  const initialDoctors = ["0x40feacdeee6f017fA2Bc1a8FB38b393Cf9022d71","0x186a761645f2A264ad0A655Fb632Ca99150803A9"];

  // Deploy the contract with the initial doctor addresses as constructor argument
  const medicalHistory = await MedicalHistory.deploy(initialDoctors);

  // Log the deployed contract address
  console.log("MedicalHistory deployed to:", medicalHistory);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

// const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

// const initialDoctors = ["0x40feacdeee6f017fA2Bc1a8FB38b393Cf9022d71","0x186a761645f2A264ad0A655Fb632Ca99150803A9"];

// module.exports = buildModule("MedicalHistoryModule", (m) => {

//   const MedicalHistory = m.contract("MedicalHistory", initialDoctors);

//   return { MedicalHistory };
// });