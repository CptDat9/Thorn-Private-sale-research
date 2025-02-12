const { expect } = require("chai");
const { ethers } = require("hardhat");
// const { time } = require("@nomicfoundation/hardhat-network-helpers");
const BigNumber = require("bignumber.js");

async function testDeposit() {
    // const contractInstance = await ethers.getContractAt(contractName, contractAddress, signer);
    let owner, depositor, usdt, privateSaleRoundOne;
    // const thornaddress ="0x5FbDB2315678afecb367f032d93F642f64180aa3";
   
    const depositAmount = ethers.parseUnits("10", 6); // 10 USDT 
    before(async function () {
        [owner, depositor] = await ethers.getSigners();
        const ThornERC20 = await ethers.getContractFactory("ThornERC20");
        usdt = await ThornERC20.deploy("CDat", "CDT", 6, 1000000);
        await usdt.waitForDeployment();
        console.log("USDT deployed tai:", usdt.target);
        await usdt.connect(owner).setVault(owner.address); // Đặt vault là owner
        await usdt.connect(owner).mint(depositor.address, ethers.parseUnits("1000", 6)); 
        console.log("Mint thành công 1000 CDT cho depositor");
        const PrivateSaleRoundOne = await ethers.getContractFactory("PrivateSaleRoundOne");
        privateSaleRoundOne = await PrivateSaleRoundOne.deploy(usdt.target);
        await privateSaleRoundOne.waitForDeployment();
        console.log("PrivateSaleRoundOne deploy tai:", privateSaleRoundOne.target);
          const buyingTimeStart = Math.floor(Date.now() / 1000); 
           const vestingTimeStart = buyingTimeStart + 86400 * 30;  
           const buyingTime = vestingTimeStart - buyingTimeStart;
           const vestingTerm = 86400 * 180; // 180 days 
           const maxDebt = BigNumber(10_000_000).multipliedBy(BigNumber(10).pow(18)).toFixed(0);
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
        // usdt = await ethers.getContractAt("ThornERC20", usdtAddress, depositor);
        // privateSaleRoundOne = await ethers.getContractAt("PrivateSaleRoundOne", privateSaleRoundOne.target, depositor);
    });   
    it("Approve usdt cho privateSaleRoundOne", async function () {
        const approveTx = await usdt.connect(depositor).approve(privateSaleRoundOne.target, depositAmount);
        await approveTx.wait();   
        const allowance = await usdt.allowance(depositor.address, privateSaleRoundOne.target);
        console.log("Allowance sau khi approve:", allowance.toString());
        expect(allowance).to.equal(depositAmount);
        console.log("Approve thành công");
    });
    it("deposit successfully", async function () {
        const terms = await privateSaleRoundOne.terms();
        console.log("Terms:", terms);
        console.log("Buying Time Start:", terms.buyingTimeStart.toString());
        console.log("Buying Time:", terms.buyingTime.toString());
        console.log("Max Debt:", terms.maxDebt.toString());
        console.log("Max Payout:", terms.maxPayout.toString());
        const bondPrice = await privateSaleRoundOne.bondPrice();
        console.log("Bond Price:", bondPrice.toString());
        const discountRatio = (await privateSaleRoundOne.terms()).discountRatio;
        const thornPrice = ethers.parseUnits("0.05", 2); // 0.05 với decimal = 2
        const setThornPriceTx = await privateSaleRoundOne.connect(owner).setThornPrice(thornPrice);
        await setThornPriceTx.wait();
        console.log("Set thorn price thành công");
        console.log("Discount Ratio:", discountRatio.toString());
        const payoutRate = await privateSaleRoundOne.getPayoutRate();
        console.log("Payout Rate = ", payoutRate.toString());
    
        const decimals = await usdt.decimals();
        console.log("USDT Decimals:", decimals.toString());
        const initialUserBalance = ethers.toBigInt(await usdt.balanceOf(depositor.address));
        const initialContractBalance = ethers.toBigInt(await usdt.balanceOf(privateSaleRoundOne.target));
        console.log("Số dư depositor trước deposit:", initialUserBalance.toString());
        console.log("Số dư contract trước deposit:", initialContractBalance.toString());
        const depositTx = await privateSaleRoundOne.connect(depositor).deposit(depositAmount, depositor.address);
        await depositTx.wait();
        const finalUserBalance = ethers.toBigInt(await usdt.balanceOf(depositor.address));
        const finalContractBalance = ethers.toBigInt(await usdt.balanceOf(privateSaleRoundOne.target));

        console.log("Số dư depositor sau deposit:", finalUserBalance.toString());
        console.log("Số dư contract sau deposit:", finalContractBalance.toString());
        
        expect(finalUserBalance).to.equal(initialUserBalance - depositAmount);
        expect(finalContractBalance).to.equal(initialContractBalance + depositAmount);            
        console.log("Deposit thành công");
        const bondInfo = await privateSaleRoundOne.getBondInfo(depositor.address);
        console.log("Bond Info:", bondInfo);
        expect(bondInfo.totalBought).to.be.gt(0);
        expect(bondInfo.pricePaid).to.equal(depositAmount);

        console.log("bondInfo cập nhật chính xác!");
    });
}
testDeposit().catch(console.error); 