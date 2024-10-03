import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const HotelModule = buildModule("HotelModule", (m) => {

  const hotel = m.contract("Hotel");

  return { hotel };
});

export default HotelModule;
