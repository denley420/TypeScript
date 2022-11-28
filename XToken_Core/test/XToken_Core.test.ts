import { expect } from "chai";
// import { loadFixture } from "ethereum-waffle";
import { Contract } from "ethers";
import { ethers } from "hardhat";

// import Web3 from 'web3';

var contract: Contract;
var accounts: any;

describe("XToken_Core", function () {
  before(async () => {
    accounts = await ethers.getSigners();
  })

  it("should be deployable (and set the right owner)", async function () {
    const XToken_Core = await ethers.getContractFactory("XToken_Core");
    contract = await XToken_Core.deploy();
    await contract.deployed();
    expect(await contract.owner()).to.equal(accounts[0].address);
  });

  it("should be able to add Minter by owner only", async function () {
    await expect(contract.mint(accounts[0].address, 1)).to.be.reverted;
    await contract.addMinter(accounts[0].address);
    await contract.mint(accounts[0].address, 1);
  });

  it("should be able to burn token", async function () {
    await contract.mint(accounts[0].address, 1);
    expect(await contract.balanceOf(accounts[0].address)).to.equal(2);
    await (contract.burnToken("1"));
    expect(await contract.balanceOf(accounts[0].address)).to.equal(1);
    await expect(contract.burnToken(2)).to.be.reverted;
  });

  it("should be able to burn token from", async function () {
    await contract.addMinter(accounts[0].address);
    await contract.mint(accounts[1].address, 10);
    expect(await contract.balanceOf(accounts[1].address)).to.equal(10);
    await contract.connect(accounts[1]).approveBurn(accounts[0].address, 999999);
    await contract.burnFrom(accounts[1].address, 5);
    expect(await contract.balanceOf(accounts[1].address)).to.equal(5);
  });


  it("should be able to remove Minter by owner only", async function () {
    await contract.addMinter(accounts[1].address);
    await contract.connect(accounts[1]).mint(accounts[1].address, 1);
    await contract.removeMinter(accounts[1].address);
    await expect(contract.connect(accounts[1]).mint(accounts[1].address, 1)).to.be.reverted;
  });

  it("should be able to pause by owner only", async function () {
    await contract.pause();
    await expect(contract.connect(accounts[0]).mint(accounts[0].address, 1)).to.be.reverted;
  });

  it("should be able to unpause by owner only", async function () {
    await contract.unpause();
    await expect(contract.connect(accounts[0]).mint(accounts[0].address, 1));
  });
})