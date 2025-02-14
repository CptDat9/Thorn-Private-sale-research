const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TokenPrice Contract Tests", function () {
    let owner, policyAdmin, user;
    let tokenPrice, usdtToken, thornToken;
    
    before(async function () {
        [owner, policyAdmin, user] = await ethers.getSigners();
        
        const ThornERC20 = await ethers.getContractFactory("ThornERC20");
        usdtToken = await ThornERC20.deploy("USDT Mock", "USDT", 6, ethers.parseEther("1000000"));
        await usdtToken.waitForDeployment();
        console.log("USDT (ThornERC20) deploy:", usdtToken.target);
        
        const MockToken = await ethers.getContractFactory("MockToken");
        thornToken = await MockToken.deploy();
        await thornToken.waitForDeployment();
        console.log("Thorn (MockToken) deploy:", thornToken.target);
        
        const TokenPrice = await ethers.getContractFactory("TokenPrice");
        tokenPrice = await TokenPrice.deploy(usdtToken.target, thornToken.target);
        await tokenPrice.waitForDeployment();
        
        console.log("TokenPrice Contract deploy:", tokenPrice.target);
    });
    
    it("Khoi tao thanh cong", async function () {
        expect(await tokenPrice.USDT_ADDRESS()).to.equal(usdtToken.target);
        expect(await tokenPrice.THORN_ADDRESS()).to.equal(thornToken.target);
    });
    
    it(" allow policy admin to set Aave Oracle", async function () {
        const currentOracle = await tokenPrice.AAVE_ORACLE();
        console.log("Current Aave Oracle:", currentOracle);
        const newAaveOracle = ethers.Wallet.createRandom().address;
        console.log("New Aave Oracle:", newAaveOracle);
        await tokenPrice.setAaveOracle(newAaveOracle);
        const updatedOracle = await tokenPrice.AAVE_ORACLE();
        console.log("Updated Oracle:", updatedOracle);
        expect(updatedOracle).to.equal(newAaveOracle);
    });
    
    it(" allow policy admin to set support token oracle price", async function () {
        const token = ethers.Wallet.createRandom().address;
        await tokenPrice.connect(owner).setSupportTokenOraclePrice(token, true);
        console.log("supportTokensPriceOracle:", await tokenPrice.supportTokensPriceOracle(token));
        expect(await tokenPrice.supportTokensPriceOracle(token)).to.be.true;
    });
    
    it("Should correctly get LP token info", async function () {
        const lpToken = ethers.Wallet.createRandom().address;
        const otherHalf = ethers.Wallet.createRandom().address;
    
        //Thêm otherHalf vào danh sách hỗ trợ trước khi set LP token
        await tokenPrice.connect(owner).setSupportTokenOraclePrice(otherHalf, true);
    
        await tokenPrice.connect(owner).setLpTokens(thornToken.target, { lpToken, otherHalf });
        const lpInfo = await tokenPrice.getLpToken(thornToken.target);
        console.log("LP info: ",  lpInfo.lpToken);
        console.log("Lp info otherHalf: ", lpInfo.otherHalf);
        expect(lpInfo.lpToken).to.equal(lpToken);
        expect(lpInfo.otherHalf).to.equal(otherHalf);
    });
    
    it("Should return correct asset price", async function () {
        const price = await tokenPrice.getAssetPrice(thornToken.target);
        console.log("Token price Thorn:", price);
        expect(price).to.be.gt(0);
    });
});
