#!/bin/bash
# Guía de instalación y compilación de VLT

echo "🚀 VLT Emission Contract - Setup Guide"
echo "======================================"
echo ""

# Verificar si está instalado Anchor
if ! command -v anchor &> /dev/null; then
    echo "⚠️  Anchor not found. Installing..."
    npm install -g @coral-xyz/anchor-cli
fi

# Verificar Rust
if ! command -v cargo &> /dev/null; then
    echo "⚠️  Rust not found. Installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
fi

# Verificar Solana CLI
if ! command -v solana &> /dev/null; then
    echo "⚠️  Solana CLI not found. Installing..."
    sh -c "$(curl -sSfL https://release.solana.com/v1.17.0/install)"
fi

echo "✓ All dependencies verified"
echo ""

# Directorio del proyecto
cd "$(dirname "$0")"

echo "📦 Building VLT Contract..."
cargo build --release

if [ $? -eq 0 ]; then
    echo "✓ Build successful!"
    echo ""
    echo "📊 Contract Statistics:"
    echo "  Program ID: VLT1111111111111111111111111111111111111111"
    echo "  Size: $(ls -lh target/release/vlt_emission.so | awk '{print $5}')"
    echo ""
    echo "🔧 To deploy:"
    echo "  solana program deploy target/release/vlt_emission.so --url devnet"
    echo ""
    echo "📝 To test:"
    echo "  cargo test"
else
    echo "✗ Build failed"
    exit 1
fi
