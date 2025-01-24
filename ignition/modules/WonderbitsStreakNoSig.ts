import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

const WonderstreakNoSigModule = buildModule("WonderstreakModule", (m) => {
  const wonderstreakNoSig = m.contract("WonderstreakNoSig");

  return { wonderstreakNoSig };
});

export default WonderstreakNoSigModule;
