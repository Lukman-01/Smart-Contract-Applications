import { ethers } from "hardhat";

async function deployRealEstate() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying RealEstate contract with the account:", deployer.address);

  const RealEstate = await ethers.getContractFactory("RealEstate");
  const realEstateContract = await RealEstate.deploy();
  await realEstateContract.deployed();

  console.log("RealEstate contract address:", realEstateContract.address);
}

// Run the deployment function
deployRealEstate()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
