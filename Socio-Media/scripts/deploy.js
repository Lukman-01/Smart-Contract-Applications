const { ethers } = require("hardhat");

async function main() {
  const ModernSocialMedia = await ethers.getContractFactory("ModernSocialMedia");
  const modernSocialMedia = await ModernSocialMedia.deploy();

  await modernSocialMedia.deployed();

  console.log("ModernSocialMedia deployed to:", modernSocialMedia.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
