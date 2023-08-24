const hre = require("hardhat");

async function main() {
  const MedicalHistory = await hre.ethers.getContractFactory("MedicalHistory");
  const initialDoctors = [ // Add addresses of initial authorized doctors
    "0xAddress1",
    "0xAddress2",
    // Add more addresses if needed
  ];

  const medicalHistory = await MedicalHistory.deploy(initialDoctors);

  await medicalHistory.deployed();

  console.log("MedicalHistory deployed to:", medicalHistory.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
