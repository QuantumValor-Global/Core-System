const hre = require("hardhat");

async function main() {
  console.log("🚀 Deploying Ethereum Impact Contracts...\n");

  // Obtener signer
  const [deployer] = await hre.ethers.getSigners();
  console.log(`📍 Deploying with account: ${deployer.address}`);
  console.log(`   Balance: ${hre.ethers.formatEther(await deployer.provider.getBalance(deployer.address))} ETH\n`);

  // Deployar Patocoin
  console.log("📦 Deploying Patocoin contract...");
  const Patocoin = await hre.ethers.getContractFactory("Patocoin");
  const patocoin = await Patocoin.deploy();
  await patocoin.waitForDeployment();
  const patoAddress = await patocoin.getAddress();
  console.log(`✓ Patocoin deployed to: ${patoAddress}\n`);

  // Deployar ImpactCredits
  console.log("📦 Deploying ImpactCredits contract...");
  const ImpactCredits = await hre.ethers.getContractFactory("ImpactCredits");
  const credits = await ImpactCredits.deploy();
  await credits.waitForDeployment();
  const creditsAddress = await credits.getAddress();
  console.log(`✓ ImpactCredits deployed to: ${creditsAddress}\n`);

  // Verificar suministro
  const totalSupply = await patocoin.totalSupply();
  console.log("📊 Initial State:");
  console.log(`   Patocoin Supply: ${hre.ethers.formatEther(totalSupply)} PAT`);
  console.log(`   Credits Supply: ${hre.ethers.formatEther(await credits.totalSupply())} CRED\n`);

  // Guardar direcciones
  const deploymentInfo = {
    network: hre.network.name,
    deployer: deployer.address,
    contracts: {
      patocoin: patoAddress,
      impactCredits: creditsAddress,
    },
    timestamp: new Date().toISOString(),
    blockNumber: await deployer.provider.getBlockNumber(),
  };

  console.log("💾 Deployment Info:");
  console.log(JSON.stringify(deploymentInfo, null, 2));

  // Guardar en archivo (si es necesario)
  const fs = require("fs");
  const path = require("path");
  const deployDir = path.join(__dirname, "../deployments");

  if (!fs.existsSync(deployDir)) {
    fs.mkdirSync(deployDir, { recursive: true });
  }

  fs.writeFileSync(
    path.join(deployDir, `${hre.network.name}-deployment.json`),
    JSON.stringify(deploymentInfo, null, 2)
  );

  console.log(`\n✓ Deployment saved to deployments/${hre.network.name}-deployment.json`);

  // Verificar en Etherscan (si está configurado)
  if (process.env.ETHERSCAN_API_KEY) {
    console.log("\n🔍 Verifying contracts on Etherscan...");
    await verifyContracts(patoAddress, creditsAddress);
  }
}

async function verifyContracts(patoAddress, creditsAddress) {
  try {
    console.log("   Verifying Patocoin...");
    await hre.run("verify:verify", {
      address: patoAddress,
      constructorArguments: [],
    });
    console.log(`   ✓ Patocoin verified`);

    console.log("   Verifying ImpactCredits...");
    await hre.run("verify:verify", {
      address: creditsAddress,
      constructorArguments: [],
    });
    console.log(`   ✓ ImpactCredits verified`);
  } catch (error) {
    console.log(`   ⚠️  Verification pending or contract already verified`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
