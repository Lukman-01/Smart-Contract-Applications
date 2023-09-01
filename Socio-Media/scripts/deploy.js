const { ethers, upgrades } = require("hardhat");

async function main() {
  // Get the contract factory
  const ModernSocialMedia = await ethers.getContractFactory("ModernSocialMedia");

  // Deploy the contract
  const modernSocialMedia = await upgrades.deployProxy(ModernSocialMedia, []);

  await modernSocialMedia.deployed();

  console.log("ModernSocialMedia deployed to:", modernSocialMedia.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
