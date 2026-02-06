#!/bin/bash
# Installation guide for Blockchain Core

echo "🚀 Quantum-Valor Blockchain Core - Installation"
echo "================================================"
echo ""

# Directorio actual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Instalar dependencias de Solana/Rust
echo "🔨 Setting up Solana/Rust environment..."
cd solana-vlt

if [ ! -d "target" ]; then
    echo "   Installing Rust dependencies..."
    cargo fetch
fi

cd ..

# Instalar dependencias de Ethereum
echo "🔨 Setting up Ethereum environment..."
cd eth-impact

if [ ! -d "node_modules" ]; then
    echo "   Installing Node.js dependencies..."
    npm install
fi

cd ..

echo ""
echo "✓ Setup complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. BUILD SOLANA CONTRACTS:"
echo "   cd solana-vlt && cargo build --release"
echo ""
echo "2. DEPLOY SOLANA CONTRACTS:"
echo "   solana program deploy solana-vlt/target/release/vlt_emission.so --url devnet"
echo ""
echo "3. BUILD ETHEREUM CONTRACTS:"
echo "   cd eth-impact && npx hardhat compile"
echo ""
echo "4. TEST ETHEREUM CONTRACTS:"
echo "   npx hardhat test"
echo ""
echo "5. DEPLOY ETHEREUM CONTRACTS:"
echo "   npx hardhat run scripts/deploy.js --network sepolia"
echo ""
echo "6. VERIFY ETHEREUM CONTRACTS:"
echo "   npx hardhat verify --network sepolia <CONTRACT_ADDRESS>"
echo ""
echo "📚 Documentation:"
echo "   - solana-vlt/IMPLEMENTATION.md"
echo "   - eth-impact/IMPLEMENTATION.md"
