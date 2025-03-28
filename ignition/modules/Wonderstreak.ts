import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

const WonderstreakModule = buildModule("WonderstreakModule", (m) => {
  const wonderstreak = m.contract("Wonderstreak");

  return { wonderstreak };
});

export default WonderstreakModule;
