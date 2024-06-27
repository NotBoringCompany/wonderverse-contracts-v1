import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

const WonderchampsModule = buildModule("WonderchampsModule", (m) => {
  const wonderchamps = m.contract("Wonderchamps");

  return { wonderchamps };
});

export default WonderchampsModule;
