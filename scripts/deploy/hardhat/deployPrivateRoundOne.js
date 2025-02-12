const { ethers } = require("hardhat");
const BigNumber = require("bignumber.js");
async function deploy() {
    // const thornaddress ="0x5FbDB2315678afecb367f032d93F642f64180aa3";
    const usdtaddress ="0x5FbDB2315678afecb367f032d93F642f64180aa3";
    const privateSaleRoundOneContract = await ethers.getContractFactory("PrivateSaleRoundOne");
    const privateSaleRoundOne = await privateSaleRoundOneContract.deploy(
        usdtaddress
    );
    console.log("Private round one deploy tai dia chi:", privateSaleRoundOne.target);
    return privateSaleRoundOne;
}
async function setup(privateSaleRoundOne)
{
   const buyingTimeStart = Math.floor(Date.now() / 1000); 
   const vestingTimeStart = buyingTimeStart + 86400 * 30;  
   const buyingTime = vestingTimeStart - buyingTimeStart;
   const vestingTerm = 86400 * 180; // 180 days 
   const maxDebt = BigNumber(1000000).multipliedBy(BigNumber(10).pow(18)).toFixed(0);
   const maxPayout = BigNumber(50000).multipliedBy(BigNumber(10).pow(6)).toFixed(0);
   const discountRatio = 30000; 
   const tge = 10000; 
   const cliffingTimeStart = vestingTimeStart;
   const cliffingTerm = 86400 * 60; 
    const tx = await privateSaleRoundOne.initializePrivateSaleRound(
        buyingTimeStart,
        buyingTime,
        vestingTimeStart,
        vestingTerm,
        cliffingTimeStart,
        cliffingTerm,
        discountRatio,
        maxDebt,
        maxPayout,
        tge
    );
    await tx.wait();
    console.log("Private Sale Round One setup thanh cong!");
}
async function main() {
    const privateSaleRoundOne = await deploy();
    await setup(privateSaleRoundOne);
}
main().
then(() => process.exit(0))
.catch((error) => {
console.error("Error:", error);
process.exit(1);    
});