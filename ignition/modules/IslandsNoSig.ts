import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

const IslandsNoSigModule = buildModule("IslandsNoSigModule", (m) => {
  const islandsNoSig = m.contract("IslandsNoSig");

  return { islandsNoSig };
});

export default IslandsNoSigModule;
