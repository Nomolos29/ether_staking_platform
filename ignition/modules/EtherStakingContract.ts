import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import hre from "hardhat";


const EtherStakingContract = buildModule("EtherStakingContract", (m) => {

  const deposit = hre.ethers.parseEther("0.0005");

  const stakeEther = m.contract("stakeEther");

  return { stakeEther };
});

export default EtherStakingContract;
