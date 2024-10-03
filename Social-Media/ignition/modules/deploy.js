const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("ModernSocialMediaModule", (m) => {

  const socialMedia = m.contract("ModernSocialMedia");

  return {socialMedia};
});