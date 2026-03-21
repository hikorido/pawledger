// Deployment script: PawToken → PawLedger → setMinter
// Usage: npx hardhat run deploy.js --network fuji

const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with:", deployer.address);
  console.log(
    "Balance:",
    ethers.formatEther(await ethers.provider.getBalance(deployer.address)),
    "AVAX"
  );

  // 1. Deploy PawToken
  console.log("\n[1/3] Deploying PawToken...");
  const PawToken = await ethers.getContractFactory("PawToken");
  const pawToken = await PawToken.deploy(deployer.address);
  await pawToken.waitForDeployment();
  const pawTokenAddr = await pawToken.getAddress();
  console.log("    PawToken deployed:", pawTokenAddr);

  // 2. Deploy PawLedger (reviewer threshold = 0.1 AVAX, requiredApprovals = 1)
  console.log("\n[2/3] Deploying PawLedger...");
  const PawLedger = await ethers.getContractFactory("PawLedger");
  const pawLedger = await PawLedger.deploy(
    pawTokenAddr,
    ethers.parseEther("0.1"), // reviewerThreshold
    1                          // requiredApprovals
  );
  await pawLedger.waitForDeployment();
  const pawLedgerAddr = await pawLedger.getAddress();
  console.log("    PawLedger deployed:", pawLedgerAddr);

  // 3. Transfer minting rights to PawLedger
  console.log("\n[3/3] Setting PawLedger as PawToken minter...");
  const tx = await pawToken.setMinter(pawLedgerAddr);
  await tx.wait();
  console.log("    Minter set. Tx:", tx.hash);

  // Summary
  console.log("\n─────────────────────────────────────────");
  console.log("Deployment complete!");
  console.log("  PawToken  :", pawTokenAddr);
  console.log("  PawLedger :", pawLedgerAddr);
  console.log("─────────────────────────────────────────");
  console.log("\nNext step: copy these addresses into src/ui/src/config.js");
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
