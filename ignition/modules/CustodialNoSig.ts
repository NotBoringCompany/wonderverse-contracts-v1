import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

const CustodialNoSigModule = buildModule("CustodialNoSigModule", (m) => {
  const custodialNoSig = m.contract("CustodialNoSig");

  return { custodialNoSig };
});

export default CustodialNoSigModule;
