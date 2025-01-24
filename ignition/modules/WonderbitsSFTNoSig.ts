import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

const WonderbitsSFTNoSigModule = buildModule("WonderbitsSFTNoSigModule", (m) => {
  const wonderbitsSFTNoSig = m.contract("WonderbitsSFTNoSig");

  return { wonderbitsSFTNoSig };
});

export default WonderbitsSFTNoSigModule;
