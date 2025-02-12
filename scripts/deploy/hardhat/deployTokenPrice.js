const { ethers, upgrades } = require("hardhat");

async function main() {
    const thornaddress ="0x5FbDB2315678afecb367f032d93F642f64180aa3";
    const usdtaddress ="0x5FbDB2315678afecb367f032d93F642f64180aa3";
    const tokenPriceContract = await ethers.getContractFactory("TokenPrice");
    const tokenPrice = await  tokenPriceContract.deploy(
        usdtaddress,
        thornaddress
    );
    await tokenPrice.waitForDeployment();
    console.log("Deploy thanh cong.");
    console.log("TokenPrice deploy tai", tokenPrice.target);
}
main().then(()=> process.exit(0))
.catch((error)=>{
    console.error("Error: " + error);  
    process.exit(1);
});
