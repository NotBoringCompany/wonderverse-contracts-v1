import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

const WonderbitsSFTModule = buildModule("WonderbitsSFTModule", (m) => {
  const wonderbitsSFT = m.contract("WonderbitsSFT");

  return { wonderbitsSFT };
});

export default WonderbitsSFTModule;
