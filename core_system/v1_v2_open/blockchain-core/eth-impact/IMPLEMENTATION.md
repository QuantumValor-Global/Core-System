# Ethereum Impact Contracts - Implementation Guide

## Overview

The Ethereum Impact contracts provide tokenization of environmental regeneration activities through:

- **Patocoin (PAT):** Environmental impact tokens
- **ImpactCredits (CRED):** Verified impact credit marketplace

### Smart Contracts

#### Patocoin.sol

Main environmental token contract featuring:

- **Emission:** Mint PAT tokens backed by verified environmental impact
- **Impact Tracking:** Record and track environmental metrics
  - CO2 sequestered (kg)
  - Trees planted
  - Water saved (L)
  - Habitat restored (hectares)
- **Transfer with Impact:** Track impact through token transfers
- **Supply Management:** Enforce maximum supply limits
- **Minter Authorization:** Controlled emission through authorized minters

**Key Functions:**
```solidity
emitPAT(address to, uint256 amount, string impactCategory, uint256 impactValue)
recordImpact(uint256 co2, uint256 trees, uint256 water, uint256 habitat)
impactTransfer(address to, uint256 amount, string impactCategory)
```

#### ImpactCredits.sol

Marketplace for environmental credit trading:

- **Credit Issuance:** Issue verified environmental credits
- **Verification Levels:** Track verification rigor (1-5 stars)
- **Retirement Mechanism:** Burn credits when impact is claimed
- **Categories:** Support multiple impact types

### Deployment

#### Prerequisites

```bash
npm install
# Configure your .env file with:
# - PRIVATE_KEY: Your deployment account private key
# - SEPOLIA_RPC: RPC endpoint for Sepolia testnet
# - MAINNET_RPC: RPC endpoint for Ethereum mainnet
# - ETHERSCAN_API_KEY: For contract verification
```

#### Deploy to Testnet (Sepolia)

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

#### Deploy to Mainnet

```bash
npx hardhat run scripts/deploy.js --network mainnet
```

#### Output

Deployment saves contract addresses to `deployments/{network}-deployment.json`:

```json
{
  "network": "sepolia",
  "deployer": "0x...",
  "contracts": {
    "patocoin": "0x...",
    "impactCredits": "0x..."
  }
}
```

### Testing

```bash
npx hardhat test

# Run specific test
npx hardhat test scripts/test-contracts.js
```

### Verification

After deployment, verify contracts on Etherscan:

```bash
npx hardhat verify --network sepolia 0x<CONTRACT_ADDRESS>
```

### Usage Examples

#### Client Integration (TypeScript/Ethers.js)

```typescript
import { ethers } from "ethers";
import PatocoinABI from "./abi/Patocoin.json";

const provider = new ethers.JsonRpcProvider("https://sepolia.infura.io/v3/");
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
const patocoin = new ethers.Contract(PATOCOIN_ADDRESS, PatocoinABI, wallet);

// Emit PAT tokens
const tx = await patocoin.emitPAT(
  recipientAddress,
  ethers.parseEther("1000"),    // 1000 PAT
  "carbon-offset",
  ethers.parseEther("1000")      // 1000 kg CO2
);
await tx.wait();

// Record impact
await patocoin.recordImpact(
  ethers.parseEther("500000"),   // CO2 kg
  ethers.parseEther("1000"),     // Trees
  ethers.parseEther("1000000"),  // Water liters
  ethers.parseEther("100")       // Habitat hectares
);

// Check metrics
const [co2, trees, water, habitat] = await patocoin.getImpactMetrics();
```

### Gas Optimization

- Batch operations to reduce gas costs
- Use `impactTransfer` instead of standard `transfer` for tracking
- Authorize multiple minters to distribute emission load

### Security

- OpenZeppelin ERC20 standard implementation
- Pausable for emergency scenarios
- Ownable for administrative functions
- Event logging for all critical operations

### Monitoring

Monitor contract events for real-time tracking:

```typescript
// Listen to PAT emissions
patocoin.on("PatoEmitted", (amount, category, value, minter) => {
  console.log(`PAT Emitted: ${amount} for ${category}`);
});

// Listen to impact recording
patocoin.on("ImpactRecorded", (co2, trees, water, habitat) => {
  console.log(`Impact recorded: ${co2} kg CO2`);
});
```

### Roadmap

- [ ] Multi-chain bridge (Solana ↔ Ethereum)
- [ ] DAO governance for minter authorization
- [ ] Oracle integration for real-time impact verification
- [ ] NFT certificates for impact milestones

---

**Version:** 1.0.0
**License:** BUSL-1.1
**Last Updated:** February 2026
