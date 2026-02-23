const hre = require("hardhat");

async function main() {
  console.log("🧪 Testing Patocoin Contract...\n");

  const [deployer, user1, user2] = await hre.ethers.getSigners();

  // Deployar contrato
  const Patocoin = await hre.ethers.getContractFactory("Patocoin");
  const patocoin = await Patocoin.deploy();
  await patocoin.waitForDeployment();

  console.log("✓ Patocoin deployed");

  // Test 1: Emisión básica
  console.log("\n📝 Test 1: Emitting PAT with environmental impact");
  try {
    const tx = await patocoin.emitPAT(
      user1.address,
      hre.ethers.parseEther("1000"), // 1000 PAT
      "carbon-offset",
      hre.ethers.parseEther("1000") // 1000 kg CO2 offset
    );
    await tx.wait();
    console.log("✓ PAT emission successful");

    const balance = await patocoin.balanceOf(user1.address);
    console.log(`  User1 balance: ${hre.ethers.formatEther(balance)} PAT`);
  } catch (error) {
    console.log("✗ Test failed:", error.message);
  }

  // Test 2: Transferencia con tracking
  console.log("\n📝 Test 2: Impact transfer");
  try {
    const tx = await patocoin
      .connect(user1)
      .impactTransfer(
        user2.address,
        hre.ethers.parseEther("100"),
        "reforestation"
      );
    await tx.wait();
    console.log("✓ Impact transfer successful");

    const balance2 = await patocoin.balanceOf(user2.address);
    console.log(`  User2 balance: ${hre.ethers.formatEther(balance2)} PAT`);
  } catch (error) {
    console.log("✗ Test failed:", error.message);
  }

  // Test 3: Registro de impacto
  console.log("\n📝 Test 3: Recording environmental metrics");
  try {
    const tx = await patocoin.recordImpact(
      hre.ethers.parseEther("500000"), // 500,000 kg CO2
      hre.ethers.parseEther("1000"), // 1,000 árboles
      hre.ethers.parseEther("1000000"), // 1,000,000 litros agua
      hre.ethers.parseEther("100") // 100 hectáreas
    );
    await tx.wait();
    console.log("✓ Impact recorded");

    const [co2, trees, water, habitat] = await patocoin.getImpactMetrics();
    console.log(`  CO2 Sequestered: ${hre.ethers.formatEther(co2)} kg`);
    console.log(`  Trees Planted: ${hre.ethers.formatEther(trees)}`);
    console.log(`  Water Saved: ${hre.ethers.formatEther(water)} liters`);
    console.log(`  Habitat Restored: ${hre.ethers.formatEther(habitat)} ha`);
  } catch (error) {
    console.log("✗ Test failed:", error.message);
  }

  // Test 4: Información de suministro
  console.log("\n📝 Test 4: Supply information");
  try {
    const [current, max, remaining] = await patocoin.getSupplyInfo();
    console.log(`  Current Supply: ${hre.ethers.formatEther(current)} PAT`);
    console.log(`  Max Supply: ${hre.ethers.formatEther(max)} PAT`);
    console.log(`  Remaining: ${hre.ethers.formatEther(remaining)} PAT`);
  } catch (error) {
    console.log("✗ Test failed:", error.message);
  }

  // Test 5: Cálculo de valor USD
  console.log("\n📝 Test 5: USD value calculation");
  try {
    const patAmount = hre.ethers.parseEther("1000");
    const usdValue = await patocoin.calculateUSDValue(patAmount);
    console.log(`  1000 PAT = $${hre.ethers.formatEther(usdValue)}`);
  } catch (error) {
    console.log("✗ Test failed:", error.message);
  }

  console.log("\n✓ All tests completed");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
