import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";
import hre from "hardhat";

/**
 * Module for `contracts/wonderbits/impl/Wonderbits.sol`
 */
const WonderbitsModule = buildModule("WonderbitsModule", (m) => {
  const wonderbits = m.contract("Wonderbits");

  return { wonderbits };
});

export default WonderbitsModule;
