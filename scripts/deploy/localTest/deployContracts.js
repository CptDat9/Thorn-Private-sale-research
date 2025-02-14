const { ethers } = require("hardhat");

async function main() {
    const [owner, depositor] = await ethers.getSigners();

    console.log("Triển khai ThornERC20...");
    const ThornERC20 = await ethers.getContractFactory("ThornERC20");
    const usdt = await ThornERC20.deploy("CDat", "CDT", 6, 1000000);
    await usdt.waitForDeployment();
    console.log("✅ USDT deployed tại:", usdt.target);

    await usdt.connect(owner).setVault(owner.address);
    await usdt.connect(owner).mint(depositor.address, ethers.parseUnits("1000", 6));
    console.log("✅ Mint thành công 1000 CDT cho depositor");

    console.log("Triển khai PrivateSaleRoundOne...");
    const PrivateSaleRoundOne = await ethers.getContractFactory("PrivateSaleRoundOne");
    const privateSaleRoundOne = await PrivateSaleRoundOne.deploy(usdt.target);
    await privateSaleRoundOne.waitForDeployment();
    console.log("✅ PrivateSaleRoundOne deployed tại:", privateSaleRoundOne.target);

    console.log("Cấu hình PrivateSaleRoundOne...");
    const buyingTimeStart = Math.floor(Date.now() / 1000);
    const vestingTimeStart = buyingTimeStart + 86400 * 30;
    const vestingTerm = 86400 * 180;
    const maxDebt = ethers.parseUnits("10000000", 18);
    const maxPayout = ethers.parseUnits("50000", 6);
    const discountRatio = 30000;
    const tge = 10000;
    const cliffingTimeStart = vestingTimeStart;
    const cliffingTerm = 86400 * 60;

    await privateSaleRoundOne.initializePrivateSaleRound(
        buyingTimeStart,
        vestingTimeStart - buyingTimeStart,
        vestingTimeStart,
        vestingTerm,
        cliffingTimeStart,
        cliffingTerm,
        discountRatio,
        maxDebt,
        maxPayout,
        tge
    );
    console.log("✅ Private Sale Round One setup thành công!");

    console.log("Triển khai MockToken...");
    const MockToken = await ethers.getContractFactory("MockToken");
    const thornToken = await MockToken.deploy();
    await thornToken.waitForDeployment();
    console.log("✅ MockToken (Thorn) deployed tại:", thornToken.target);

    await privateSaleRoundOne.setThornAddress(thornToken.target);
    console.log("✅ Set địa chỉ Thorn token thành công.");

    await thornToken.mint(privateSaleRoundOne.target, ethers.parseUnits("1000000", 18));
    console.log("✅ Mint 1 triệu Thorn cho PrivateSaleRoundOne.");

    console.log("\n📌 **Tóm tắt địa chỉ hợp đồng:**");
    console.log("   ThornERC20 (USDT):", usdt.target);
    console.log("   PrivateSaleRoundOne:", privateSaleRoundOne.target);
    console.log("   MockToken (Thorn):", thornToken.target);
}

main().catch((error) => {
    console.error("❌ Triển khai thất bại:", error);
    process.exit(1);
});
