import { ethers } from "hardhat";

async function main() {
  const SougenGenesis = await ethers.getContractFactory("SougenGenesis");
  const sougenGensis = await SougenGenesis.deploy();

  await sougenGensis.deployed();
  console.log("GensisPass deployed to: ", sougenGensis.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
