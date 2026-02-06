#!/usr/bin/env bash
# Quantum-Valor idempotent installer (español)
set -euo pipefail
IFS=$'\n\t'

info(){ printf "\n✅ %s\n" "$1"; }
warn(){ printf "\n⚠️ %s\n" "$1"; }
fatal(){ printf "\n❌ %s\n" "$1"; exit 1; }

export DEBIAN_FRONTEND=noninteractive

SUDO=""
if [ "$EUID" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO=sudo
  else
    warn "No eres root y 'sudo' no está disponible. Algunas instalaciones pueden fallar."
  fi
fi

info "🚀 Iniciando instalación del Ecosistema Quantum-Valor..."

# 1. Actualización del sistema y dependencias base
info "↻ Actualizando repositorios y paquetes base..."
$SUDO apt-get update -y
$SUDO apt-get install -y --no-install-recommends \
  ca-certificates curl gnupg lsb-release build-essential pkg-config libudev-dev libssl-dev

# 2. Instalar Node.js LTS si falta (necesario para clientes TS)
if ! command -v node >/dev/null 2>&1; then
  info "📦 Node.js no encontrado. Instalando Node.js LTS..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | $SUDO bash -
  $SUDO apt-get install -y nodejs
else
  info "✅ Node.js detectado: $(node -v)"
fi

# 3. Rust toolchain
if ! command -v cargo >/dev/null 2>&1; then
  info "🦀 Instalando Rust (rustup)..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # shellcheck disable=SC1090
  source "$HOME/.cargo/env" || true
  # Ensure env lines in profile
  if ! grep -q "CARGO_HOME" "$HOME/.profile" 2>/dev/null; then
    printf '\nexport PATH="$HOME/.cargo/bin:$PATH"\n' >> "$HOME/.profile"
  fi
else
  info "✅ Rust ya está instalado: $(cargo --version)"
fi

# 4. Solana CLI
if ! command -v solana >/dev/null 2>&1; then
  info "☀️ Instalando Solana CLI..."
  sh -c "$(curl -sSfL https://release.solana.com/v1.18.4/install)"
  if ! grep -q "solana" "$HOME/.profile" 2>/dev/null; then
    printf '\nexport PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"\n' >> "$HOME/.profile"
  fi
  export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
else
  info "✅ Solana CLI detectado: $(solana --version)"
fi

# 5. Anchor (avm + anchor)
if ! command -v anchor >/dev/null 2>&1; then
  if command -v cargo >/dev/null 2>&1; then
    info "⚓ Instalando Anchor AVM y Anchor..."
    cargo install --git https://github.com/coral-xyz/anchor avm --locked --force || warn "Falló 'cargo install avm'."
    if command -v avm >/dev/null 2>&1; then
      avm install latest || warn "avm install falló"
      avm use latest || warn "avm use falló"
    else
      warn "avm no quedó disponible en PATH inmediatamente. Asegúrate de tener ~/.cargo/bin en PATH y re-intenta."
    fi
  else
    warn "Cargo no disponible: no puedo instalar Anchor. Instala Rust/cargo primero."
  fi
else
  info "✅ Anchor detectado: $(anchor --version 2>/dev/null || echo 'versión no disponible')"
fi

# 6. Dependencias del cliente (blockchain-core/solana-vlt)
CLIENT_DIR="blockchain-core/solana-vlt"
if [ -d "$CLIENT_DIR" ]; then
  info "📦 Instalando dependencias Node en $CLIENT_DIR"
  pushd "$CLIENT_DIR" >/dev/null
  if [ -f package-lock.json ]; then
    npm ci --no-audit --no-fund
  else
    npm install --no-audit --no-fund
  fi
  # typescript + ts-node global check
  if ! command -v tsc >/dev/null 2>&1; then
    npm install -g typescript ts-node
  else
    info "✅ TypeScript ya instalado: $(tsc -v)"
  fi
  popd >/dev/null
else
  warn "$CLIENT_DIR no existe en este repo. Omitiendo pasos de Node client."
fi

# 7. Resumen de versiones
info "---------------------------------------------------"
info "SISTEMA LISTO PARA OPERAR"
printf "ARQUITECTO: INTO el 3\n"
info "---------------------------------------------------"
solana --version 2>/dev/null || warn "solana no disponible"
anchor --version 2>/dev/null || warn "anchor no disponible"
node -v 2>/dev/null || warn "node no disponible"
tsc -v 2>/dev/null || true
cargo --version 2>/dev/null || true
info "---------------------------------------------------"

info "✅ Instalación completada. Reinicia tu terminal o ejecuta 'source ~/.profile' o 'source ~/.bashrc'."
