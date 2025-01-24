import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

const WonderbitsNoSigModule = buildModule("WonderbitsNoSigModule", (m) => {
  const wonderbitsNoSig = m.contract("WonderbitsNoSig");

  return { wonderbitsNoSig };
});

export default WonderbitsNoSigModule;
