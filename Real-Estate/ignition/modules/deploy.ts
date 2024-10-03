import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const RealEstateModule = buildModule("RealEstateModule", (m) => {

  const estate = m.contract("RealEstate");

  return { estate };
});

export default RealEstateModule;
