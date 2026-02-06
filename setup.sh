#!/bin/bash
# /setup.sh - Inicialización del Core-System

echo "🚀 Iniciando configuración de Quantum-Valor Core-System..."

# Instalar dependencias de Rust
echo "📦 Instalando dependencias de Rust..."
cd blockchain-core/solana-vlt
cargo update
cd ../..

# Instalar dependencias de Node.js
echo "📦 Instalando dependencias de Ethereum..."
cd blockchain-core/eth-impact
npm install
cd ../..

# Instalar dependencias de Python
echo "📦 Instalando dependencias de AI Guardian..."
cd ai-guardian
pip install -r requirements.txt 2>/dev/null || echo "⚠️ Crea requirements.txt con tus dependencias"
cd ..

# Instalar infraestructura
echo "📦 Configurando infraestructura..."
cd infrastructure
pip install -r requirements.txt 2>/dev/null || echo "⚠️ Crea requirements.txt para IoT"
cd ..

echo "✅ Inicialización completada. El proyecto está listo para desarrollo."
echo ""
echo "Próximos pasos:"
echo "1. Configura tus archivos .env en cada módulo"
echo "2. Lee los README de cada carpeta para detalles específicos"
echo "3. Revisa el WHITE_PAPER.md para entender la arquitectura"
