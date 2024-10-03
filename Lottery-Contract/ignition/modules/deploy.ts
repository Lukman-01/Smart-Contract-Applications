import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const LotteryModule = buildModule("LotteryModule", (m) => {

  const lottery = m.contract("Lottery");

  return { lottery };
});

export default LotteryModule;
