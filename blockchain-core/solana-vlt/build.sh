#!/bin/bash
# ============================================
# Quantum-Valor VLT - Build & Test Script
# SOPORTA AMBAS VERSIONES: V1 (DALabs) + V2 (INTO3)
# ============================================

set -e

echo "🚀 Quantum-Valor VLT Build System"
echo "=================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================
# FUNCIONES
# ============================================

check_dependencies() {
    echo "${BLUE}🔍 Checking dependencies...${NC}"
    
    local missing=0
    
    if ! command -v cargo &> /dev/null; then
        echo "❌ Cargo no encontrado. Instala Rust:"
        echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        missing=1
    fi
    
    if ! command -v solana &> /dev/null; then
        echo "❌ Solana CLI no encontrado. Instala desde:"
        echo "   https://docs.solana.com/cli/install-solana-cli-tools"
        missing=1
    fi
    
    if [ $missing -eq 1 ]; then
        exit 1
    fi
    
    echo "${GREEN}✓ Todas las dependencias encontradas${NC}"
    echo ""
}

build_v1() {
    echo "${BLUE}📦 Building Solana VLT V1 (DALabs)...${NC}"
    
    if [ ! -f "lib.rs" ]; then
        echo "❌ lib.rs no encontrado"
        return 1
    fi
    
    echo "   Compilando con cargo..."
    cargo build --release 2>&1 | head -20
    
    if [ -f "target/release/vlt_emission.so" ]; then
        echo "${GREEN}✓ V1 Build exitoso${NC}"
        ls -lh target/release/vlt_emission.so
        return 0
    else
        echo "❌ V1 Build falló"
        return 1
    fi
}

build_v2() {
    echo "${BLUE}📦 Building Solana VLT V2 (INTO3 Sovereign)...${NC}"
    
    if [ ! -f "v2_sovereign.rs" ]; then
        echo "❌ v2_sovereign.rs no encontrado"
        return 1
    fi
    
    echo "   Compilando v2_sovereign.rs..."
    mkdir -p target/v2_builds
    
    # Crear Cargo.toml temporal para v2
    cat > target/v2_builds/Cargo.toml << 'EOF'
[package]
name = "quantum-vlt-v2-sovereign"
version = "2.0.0"
edition = "2021"

[lib]
crate-type = ["cdylib", "lib"]

[dependencies]
anchor-lang = "0.28"
anchor-spl = "0.28"
solana-program = "1.17"

[profile.release]
opt-level = 3
lto = true
codegen-units = 1
EOF

    cp v2_sovereign.rs target/v2_builds/src/lib.rs 2>/dev/null || true
    
    echo "   (Nota: v2 requiere estructura Anchor completa para compilación optimizada)"
    echo "   En desarrollo, puede testearse sin compilación completa"
    echo "${YELLOW}⚠️  Para compilar v2 en producción:${NC}"
    echo "   cd .. && cargo init --name quantum-vlt-v2 && cp blockchain-core/solana-vlt/v2_sovereign.rs src/lib.rs && cargo build --release"
    
    return 0
}

test_v1() {
    echo ""
    echo "${BLUE}🧪 Testing V1 (DALabs)...${NC}"
    
    if ! cargo test --lib 2>&1 | head -30; then
        echo "${YELLOW}⚠️  Algunos tests pueden fallar sin red Solana local${NC}"
    fi
}

compare_versions() {
    echo ""
    echo "${BLUE}📊 Comparación de Versiones${NC}"
    echo ""
    
    if [ -f "lib.rs" ] && [ -f "v2_sovereign.rs" ]; then
        echo "V1 (lib.rs):"
        wc -l lib.rs | awk '{print "  Líneas: " $1}'
        grep -c "fn " lib.rs | awk '{print "  Funciones: " $1}'
        echo ""
        
        echo "V2 (v2_sovereign.rs):"
        wc -l v2_sovereign.rs | awk '{print "  Líneas: " $1}'
        grep -c "fn " v2_sovereign.rs | awk '{print "  Funciones: " $1}'
        echo ""
        
        echo "📄 Ver COMPARISON.md para análisis detallado"
    fi
}

interactive_menu() {
    echo ""
    echo "${BLUE}═══════════════════════════════════════${NC}"
    echo "${BLUE}    QUANTUM-VALOR VLT BUILD MENU${NC}"
    echo "${BLUE}═══════════════════════════════════════${NC}"
    echo ""
    echo "1) Compilar V1 (DALabs) - Recomendado"
    echo "2) Info V2 (INTO3) - Lectura de código"
    echo "3) Comparar ambas versiones"
    echo "4) Ver documentación"
    echo "5) Configurar ambiente de desarrollo"
    echo "6) Salir"
    echo ""
    read -p "Selecciona opción [1-6]: " choice
    
    case $choice in
        1)
            build_v1
            compare_versions
            ;;
        2)
            echo ""
            echo "${BLUE}V2 Sovereign Overview:${NC}"
            echo ""
            cat v2_sovereign.rs | head -80
            echo ""
            echo "${YELLOW}... (ver archivo completo para todos los detalles)${NC}"
            ;;
        3)
            compare_versions
            echo ""
            echo "📖 Para análisis profundo, ver: ${BLUE}COMPARISON.md${NC}"
            ;;
        4)
            if command -v less &> /dev/null; then
                less COMPARISON.md
            else
                echo "Ver COMPARISON.md con tu editor favorito"
            fi
            ;;
        5)
            setup_dev_environment
            ;;
        6)
            exit 0
            ;;
        *)
            echo "❌ Opción inválida"
            interactive_menu
            ;;
    esac
}

setup_dev_environment() {
    echo ""
    echo "${BLUE}🔧 Setting up development environment...${NC}"
    echo ""
    
    # Crear directorios
    mkdir -p build-outputs
    mkdir -p docs
    
    # Copiar archivos de referencia
    if [ ! -f "docs/V1-IMPLEMENTATION.md" ]; then
        cp IMPLEMENTATION.md docs/V1-IMPLEMENTATION.md 2>/dev/null || true
    fi
    
    if [ ! -f "docs/VERSION-COMPARISON.md" ]; then
        cp COMPARISON.md docs/VERSION-COMPARISON.md 2>/dev/null || true
    fi
    
    echo "${GREEN}✓ Directories created:${NC}"
    echo "   build-outputs/ - Artefactos compilados"
    echo "   docs/          - Documentación local"
    echo ""
    echo "${GREEN}✓ Development environment ready${NC}"
}

show_deployment_guide() {
    echo ""
    echo "${BLUE}📋 Guía de Despliegue Rápido${NC}"
    echo ""
    echo "Para MVP (Devnet) - Recomendado V2:"
    echo "  1. cargo build --release"
    echo "  2. solana program deploy target/release/vlt_emission.so --url devnet"
    echo "  3. Obtén PROGRAM_ID y actualiza client.ts"
    echo ""
    echo "Para Producción (Testnet/Mainnet) - V1:"
    echo "  1. cargo test (valida todo funciona)"
    echo "  2. Solicita auditoría de seguridad"
    echo "  3. solana program deploy target/release/vlt_emission.so --url testnet"
    echo "  4. Prueba exhaustivamente en testnet"
    echo "  5. Entonces: solana program deploy ... --url mainnet-beta"
    echo ""
}

# ============================================
# MAIN
# ============================================

main() {
    echo ""
    check_dependencies
    
    if [ "${1:-}" == "--auto" ]; then
        # Modo automático: compilar y comparar
        build_v1
        compare_versions
        show_deployment_guide
    elif [ "${1:-}" == "--v1" ]; then
        build_v1
    elif [ "${1:-}" == "--v2-info" ]; then
        if [ -f "v2_sovereign.rs" ]; then
            echo "V2 Sovereign Contract Found:"
            head -50 v2_sovereign.rs
        else
            echo "v2_sovereign.rs no encontrado"
        fi
    elif [ "${1:-}" == "--compare" ]; then
        compare_versions
    elif [ "${1:-}" == "--setup" ]; then
        setup_dev_environment
    else
        # Menu interactivo
        interactive_menu
    fi
}

# ============================================
# EJECUCIÓN
# ============================================

main "$@"

echo ""
echo "${GREEN}✓ Script completado${NC}"
echo ""
