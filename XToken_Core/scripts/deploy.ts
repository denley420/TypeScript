import { ethers } from "hardhat";

async function deploy_XToken_Core(){

  console.log("Deploying XToken_Core");
  console.log("------------------------------------------------------");
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const XToken_Core = await ethers.getContractFactory("XToken_Core");
  const contract = await XToken_Core.deploy();
  await contract.deployed();

  console.log("[XToken_Core] address:", contract.address);

}
deploy_XToken_Core().then().catch();