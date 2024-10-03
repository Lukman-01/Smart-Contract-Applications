const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("MedicalHistoryModule", (m) => {

  const doctors = ["0x186a761645f2A264ad0A655Fb632Ca99150803A9", "0x40feacdeee6f017fA2Bc1a8FB38b393Cf9022d71"];

  const medHistory = m.contract("MedicalHistory", [doctors]);

  return {medHistory};
});