const { expect } = require("chai");
const { ethers } = require("hardhat");
const assert = require("assert");
const BigNumber = require("bignumber.js");

describe("Private Sale Redeem Test", function () {
    let owner, depositor, privateSale, thornToken;
    
    before(async function () {
        [owner, depositor] = await ethers.getSigners();
    
        const ThornERC20 = await ethers.getContractFactory("ThornERC20");
        thornToken = await ThornERC20.deploy("CongDat", "CDT", 6, ethers.parseEther("1000000"));
        await thornToken.waitForDeployment();
        console.log("✅ Thorn ERC20 (CDT) deployed at:", thornToken.target);
        const PrivateSale = await ethers.getContractFactory("PrivateSaleRoundOne");
        privateSale = await PrivateSale.deploy(thornToken.target);
        await privateSale.waitForDeployment();
        console.log("✅ Private Sale deployed at:", privateSale.target);

-        await thornToken.connect(owner).transfer(depositor.address, ethers.parseEther("1000"));

-        await thornToken.connect(depositor).approve(privateSale.target, ethers.parseEther("1000"));

        const now = Math.floor(Date.now() / 1000);
        const vestingStart = now + 60; 
        const vestingTerm = 60 * 60 * 24 * 30; 

        await privateSale.connect(owner).initializePrivateSaleRound(
            now,                
            60 * 60 * 24 * 7,    
            vestingStart,        
            vestingTerm,        
            vestingStart,       
            60 * 60 * 24 * 7,    
            30000,               
            BigNumber(10_000_000).multipliedBy(BigNumber(10).pow(18)).toFixed(0),
            BigNumber(50000).multipliedBy(BigNumber(10).pow(6)).toFixed(0), 
            10000                
        );

        console.log("✅ Private Sale Round  1 Initialized!");
        
        const depositAmount = ethers.parseUnits("10", 6); 
        const thornPrice = ethers.parseUnits("0.05", 2); 
        const setThornPriceTx = await privateSale.connect(owner).setThornPrice(thornPrice);
        await setThornPriceTx.wait();
        await privateSale.connect(depositor).deposit(depositAmount, depositor.address);
        console.log("✅ Deposit successful!");
    });

    it("Should check balance and allowance before redeem", async function () {
        const balanceBefore = await thornToken.balanceOf(depositor.address);
        console.log("🔹 Balance before:", balanceBefore.toString());

        const allowance = await thornToken.allowance(depositor.address, privateSale.target);
        console.log("🔹 Allowance before:", allowance.toString());

        assert(allowance > 0, "⚠ Allowance không hợp lệ!");
    });

    it("Should redeem tokens successfully", async function () {
        console.log("🔹 Redeeming tokens...");

        let bondInfo = await privateSale.getBondInfo(depositor.address);
        console.log("🔸 Bond Info trước redeem:", bondInfo);

        if (bondInfo.payout == 0) {
            console.log("⚠ Không thể redeem vì payout = 0! Hãy kiểm tra lại deposit.");
            return;
        }

        const terms = await privateSale.terms();

        const currentTime = Math.floor(Date.now() / 1000);
        const cliffingTimeStart = Number(await terms.cliffingTimeStart);

        if (currentTime < cliffingTimeStart) {
            console.log("⚠ Không thể redeem vì chưa đến thời gian cliffing!");
            const timeDiff = cliffingTimeStart - currentTime;
            console.log(`Tăng thời gian lên ${timeDiff} giây để đến thời điểm cliffing...`);
            await ethers.provider.send("evm_increaseTime", [timeDiff]);
            await ethers.provider.send("evm_mine");
        }
        console.log(" Đã đến thời gian cliffing, tiếp tục redeem...");
         const ThornERC20 = await ethers.getContractFactory("MockToken");
        const thornToken = await ThornERC20.deploy();
        await thornToken.waitForDeployment();
        console.log("ThornToken deployed tại:", thornToken.target);
        await privateSale.setThornAddress(thornToken.target);
        console.log("Set dia chi thorn token thannh cong.");
        const mintTx = await thornToken.mint(privateSale.target, "1000000000000000000000000"); 
        await mintTx.wait();
        console.log("Mint rat rat nhieu Thorn token cho contract thành công!");
        const contractBalance = await thornToken.balanceOf(privateSale.target);
        console.log("Contract balance:" , contractBalance.toString());
            console.log("bondInfo.payout:", bondInfo.payout);
            const bondInfoAfter = await privateSale.getBondInfo(depositor.address);

            console.log(" bond info after", bondInfoAfter);
            console.log("Depositor", depositor.address);
            const balanceBefore = await thornToken.balanceOf(depositor.address);
            console.log("Balance nguoi dung before redeem:", balanceBefore.toString());
            const remainingPayout = bondInfoAfter[1].toString();
            console.log("Payout  redeem:", remainingPayout);
            await expect(privateSale.connect(depositor).redeem(depositor.address))
                .to.emit(privateSale, "PrivateSaleRedeem")
                .withArgs(
                    0, 
                    remainingPayout,    
                    depositor.address
                );
                console.log("Emit dung");
            const balanceAfter = await thornToken.balanceOf(depositor.address);
            console.log("Balance nguoi dung after redeem:", balanceAfter.toString());
            expect(balanceAfter).to.be.above(0);

    });
});
