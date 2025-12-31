const { ethers } = require("hardhat");

async function main() {
  const DefautsBatiment = await ethers.getContractFactory("DefautsBatiment");
  const defautsBatiment = await DefautsBatiment.deploy();

  await defautsBatiment.waitForDeployment();

  const address = await defautsBatiment.getAddress();
  console.log("DefautsBatiment deployed to:", address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
//
// 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512