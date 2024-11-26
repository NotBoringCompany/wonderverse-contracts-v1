import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

const CustodialModule = buildModule("CustodialModule", (m) => {
  const custodial = m.contract("Custodial");

  return { custodial };
});

export default CustodialModule;
