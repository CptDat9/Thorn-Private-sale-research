const { ethers } = require("hardhat");
async function main() {
    const ThornERC20Contract =  await ethers.getContractFactory("ThornERC20");
    const PrincipleUSDT = await ThornERC20Contract.deploy("CongDaT", "CDT", 6, 1000000);
    await PrincipleUSDT.waitForDeployment();
    console.log("PrincipleUSDt deployed tai:", PrincipleUSDT.target);
}
main().then(()=>process.exit(0)).
catch((error)=>{
    console.error(error);
    process.exit(1);
});