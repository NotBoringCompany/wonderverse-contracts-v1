import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

const BitCosmeticsNoSigModule = buildModule("BitCosmeticsNoSigModule", (m) => {
  const bitCosmeticsNoSig = m.contract("BitCosmeticsNoSig");

  return { bitCosmeticsNoSig };
});

export default BitCosmeticsNoSigModule;
