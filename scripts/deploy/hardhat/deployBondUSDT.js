const { ethers, upgrades } = require("hardhat");

async function main() {
    const thornaddress ="0x5FbDB2315678afecb367f032d93F642f64180aa3";
    const usdtaddress ="0x5FbDB2315678afecb367f032d93F642f64180aa3";
  console.log("dang deploy Bond...");
  const BondDepository = await ethers.getContractFactory("BondDepository");
  const bondContract = await upgrades.deployProxy(BondDepository, 
[
thornaddress, 
usdtaddress
]);
  await bondContract.waitForDeployment();

  console.log("BondDepository deploy tai:", bondContract.target);
  console.log("deploy thanh cong");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error:", error);
    process.exit(1);
  });
