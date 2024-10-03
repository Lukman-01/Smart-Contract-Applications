const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("VotingModule", (m) => {

  const vote = m.contract("Voting");

  return {vote};
});