// describe("token test",()=>{})
const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Reentrancy test", function () {
  let owner, address1, Token, hardhatToken, AToken, hardhatAToken;

  beforeEach(async function () {
    [owner, address1, address2] = await ethers.getSigners();
    Token = await ethers.getContractFactory("ReentrancyToken");
    hardhatToken = await Token.deploy();
    AToken = await ethers.getContractFactory("Attacker");
    hardhatAToken = await AToken.deploy(hardhatToken.address);
  });

  it("Reentrancy success", async function () {
    await hardhatToken.buy({ value: ethers.utils.parseUnits("2", "ether") });
    await hardhatToken.buy({ value: ethers.utils.parseUnits("8", "ether") });
    await expect(
      hardhatAToken
        .connect(address1)
        .attack({ value: ethers.utils.parseUnits("1", "ether") })
    ).to.changeEtherBalance(
      address1.address,
      ethers.utils.parseUnits("10", "ether")
    );
  });
});
