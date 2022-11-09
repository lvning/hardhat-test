// describe("token test",()=>{})
const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("token test", function () {
  let owner, address1, address2, Token, hardhatToken;

  beforeEach(async function () {
    [owner, address1, address2] = await ethers.getSigners();
    Token = await ethers.getContractFactory("Token");
    hardhatToken = await Token.deploy();
  });

  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const ownerBalance = await hardhatToken.balanceOf(owner.address);

    console.log(`the owner of the contract is :${owner.address}`);

    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });

  it("Owner and address1 balance check", async () => {
    await expect(
      hardhatToken.transfer(address1.address, 500)
    ).to.changeTokenBalances(
      hardhatToken,
      [owner.address, address1.address],
      [-500, 500]
    );
  });

  it("Address1 transfer 1000 to address2 check", async () => {
    await expect(
      hardhatToken.connect(address1).transfer(address2.address, 1000)
    ).to.be.revertedWith("Not enough tokens");
  });

  it("Change owner success", async () => {
    await hardhatToken.changeOwner(address1.address);
    expect(await hardhatToken.owner()).to.hexEqual(address1.address);
  });

  it("Change owner failed with non-owner", async () => {
    await expect(
      hardhatToken.connect(address1).changeOwner(address2.address)
    ).to.be.revertedWith("Only the owner can call this.");
  });

  it("Change owner with event emited", async () => {
    await expect(hardhatToken.changeOwner(address1.address))
      .to.emit(hardhatToken, "NewOwner")
      .withArgs(owner.address, address1.address);
  });
});
