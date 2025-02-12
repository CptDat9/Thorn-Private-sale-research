const { ethers } = require("hardhat");
async function main(){
    const [deployer] = await ethers.getSigners();
    console.log("Deploy contract with :", deployer.address);
    const MockTokenContract = await ethers.getContractFactory("MockToken");
    const MockToken = await MockTokenContract.deploy();
    await MockToken.waitForDeployment();
    console.log("Dia chi MockToken (THORN):", MockToken.target);
    // const initialBalance = await deployer.getBalance();
    // console.log("account balance:", ethers.formatEther(initialBalance));
    const mintTx = await MockToken.mint(deployer.address, ethers.parseEther("1000"));
    await mintTx.wait();
    console.log("da mint 1000 tokens to deployer:", deployer.address);
    
    // const initialBalance2 = await deployer.getBalance();
    // console.log("account balance after:", ethers.formatEther(initialBalance2));}
}
main()
.then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});