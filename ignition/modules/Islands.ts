import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

const IslandsModule = buildModule("IslandsModule", (m) => {
  const islands = m.contract("Islands");

  return { islands };
});

export default IslandsModule;
