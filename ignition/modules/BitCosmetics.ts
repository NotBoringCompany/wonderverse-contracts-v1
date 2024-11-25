import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

const BitCosmeticsModule = buildModule("BitCosmeticsModule", (m) => {
  const bitCosmetics = m.contract("BitCosmetics");

  return { bitCosmetics };
});

export default BitCosmeticsModule;
