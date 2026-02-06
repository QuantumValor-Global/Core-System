#!/bin/bash
# =====================================================
# QUANTUM-VALOR: Fase Completa de Compilación y Build
# Automatiza: Instalación → Build → Sincronización ID
# =====================================================

set -e
IFS=$'\n\t'

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { printf "${GREEN}✅${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}⚠️${NC}  %s\n" "$1"; }
error() { printf "${RED}❌${NC} %s\n" "$1"; exit 1; }
step()  { printf "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n${BLUE}%s${NC}\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n" "$1"; }

REPO_ROOT="/workspaces/Core-System"
SOLANA_VLT_DIR="$REPO_ROOT/blockchain-core/solana-vlt"

# =====================================================
# PASO 1: INSTALACIÓN DE DEPENDENCIAS
# =====================================================
step "PASO 1: Instalación de Dependencias (Rust, Solana, Anchor, Node.js)"
bash "$REPO_ROOT/scripts/quantum-valor-installer.sh"
info "Dependencias instaladas"

# Recargar PATH para nuevas herramientas
export PATH="$HOME/.cargo/bin:$HOME/.local/share/solana/install/active_release/bin:$PATH"
source "$HOME/.profile" 2>/dev/null || true

# =====================================================
# PASO 2: VERIFICACIÓN DE HERRAMIENTAS
# =====================================================
step "PASO 2: Verificando Herramientas"

echo "Rust (cargo):"
cargo --version || error "Cargo no disponible"

echo "Solana CLI:"
solana --version || error "Solana CLI no disponible"

echo "Anchor Framework:"
anchor --version || error "Anchor no disponible"

echo "Node.js:"
node -v || error "Node.js no disponible"

info "Todas las herramientas están disponibles"

# =====================================================
# PASO 3: COMPILACIÓN DEL PROGRAMA ANCHOR
# =====================================================
step "PASO 3: Compilando Contrato Maestro VLT (anchor build)"

cd "$SOLANA_VLT_DIR"
info "Directorio actual: $(pwd)"

anchor build 2>&1 | tee anchor_build.log

if [ $? -ne 0 ]; then
    error "anchor build falló. Ver anchor_build.log"
fi

info "✓ Compilación completada"

# =====================================================
# PASO 4: VERIFICACIÓN DEL IDL
# =====================================================
step "PASO 4: Verificando IDL Generado"

IDL_PATH="$SOLANA_VLT_DIR/target/idl/quantum_vlt.json"

if [ ! -f "$IDL_PATH" ]; then
    error "IDL no fue generado: $IDL_PATH"
fi

info "✓ IDL generado en: $IDL_PATH"
echo ""
echo "Primeras 50 líneas del IDL:"
head -50 "$IDL_PATH"

# =====================================================
# PASO 5: OBTENER PROGRAM ID GENERADO
# =====================================================
step "PASO 5: Extrayendo Program ID Generado"

KEYPAIR_PATH="$SOLANA_VLT_DIR/target/deploy/quantum_vlt-keypair.json"

if [ ! -f "$KEYPAIR_PATH" ]; then
    error "Keypair no fue generada: $KEYPAIR_PATH"
fi

PROGRAM_ID=$(solana address -k "$KEYPAIR_PATH" 2>/dev/null)

if [ -z "$PROGRAM_ID" ]; then
    error "No se pudo extraer el Program ID"
fi

info "✓ Program ID generado: ${BLUE}$PROGRAM_ID${NC}"

# =====================================================
# PASO 6: SINCRONIZAR PROGRAM ID EN ARCHIVOS
# =====================================================
step "PASO 6: Sincronizando Program ID en Archivos de Configuración"

# 6a. Actualizar lib.rs
LIB_RS_PATH="$SOLANA_VLT_DIR/programs/quantum_vlt/src/lib.rs"
info "Actualizando $LIB_RS_PATH"

sed -i "1,10s/declare_id!(\"VLT.*\");/declare_id!(\"$PROGRAM_ID\");/" "$LIB_RS_PATH"
grep "declare_id!" "$LIB_RS_PATH" | head -1

info "✓ lib.rs actualizado"

# 6b. Actualizar Anchor.toml
ANCHOR_TOML_PATH="$SOLANA_VLT_DIR/Anchor.toml"
info "Actualizando $ANCHOR_TOML_PATH"

sed -i "s/quantum_vlt = \"VLT.*/quantum_vlt = \"$PROGRAM_ID\"/g" "$ANCHOR_TOML_PATH"
grep "quantum_vlt = " "$ANCHOR_TOML_PATH"

info "✓ Anchor.toml actualizado"

# =====================================================
# PASO 7: RE-COMPILAR CON PROGRAM ID CORRECTO
# =====================================================
step "PASO 7: Re-compilando con Program ID Sincronizado"

anchor build 2>&1 | tail -30

if [ $? -ne 0 ]; then
    warn "Re-compilación tuvo advertencias (puede ser normal)"
else
    info "✓ Re-compilación exitosa"
fi

# =====================================================
# PASO 8: VERIFICACIÓN FINAL
# =====================================================
step "PASO 8: Verificación Final del Sistema"

echo "📋 Archivos Generados:"
echo "  - IDL:      $([ -f "$IDL_PATH" ] && echo "✓" || echo "✗") $IDL_PATH"
echo "  - Keypair:  $([ -f "$KEYPAIR_PATH" ] && echo "✓" || echo "✗") $KEYPAIR_PATH"
echo ""
echo "🔐 Configuración:"
echo "  - Program ID: $PROGRAM_ID"
echo "  - lib.rs actualizado: $(grep -q "$PROGRAM_ID" "$LIB_RS_PATH" && echo "✓" || echo "✗")"
echo "  - Anchor.toml actualizado: $(grep -q "$PROGRAM_ID" "$ANCHOR_TOML_PATH" && echo "✓" || echo "✗")"
echo ""

# =====================================================
# PASO 9: PRÓXIMOS PASOS
# =====================================================
step "PRÓXIMOS PASOS: Despliegue en Devnet (Opcional)"

cat << 'NEXT_STEPS'

Para desplegar en Solana Devnet y probar con fondos de prueba:

  1️⃣  Configurar cliente Solana para Devnet:
      solana config set --url devnet

  2️⃣  Obtener SOL de prueba (airdrop):
      solana airdrop 2

  3️⃣  Desplegar el programa:
      anchor deploy

  4️⃣  Ejecutar el script de conexión para verificar:
      cd blockchain-core/solana-vlt
      npx ts-node app/connect.ts

  5️⃣  Ver transacciones en explorer:
      https://explorer.solana.com/?cluster=devnet
      (Busca tu dirección: PROGRAM_ID)

NEXT_STEPS

info "═══════════════════════════════════════════════════"
info "🎉 COMPILACIÓN Y SINCRONIZACIÓN COMPLETADAS"
info "═══════════════════════════════════════════════════"

# Guardar el Program ID en un archivo para referencias futuras
echo "$PROGRAM_ID" > "$SOLANA_VLT_DIR/.program_id"
info "Program ID guardado en: $SOLANA_VLT_DIR/.program_id"
