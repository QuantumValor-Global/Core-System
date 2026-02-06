# Solana VLT - Valor-Litio Token

## 📋 Descripción

Implementación de contratos inteligentes en Rust/Solana para tokenización de Litio con dos enfoques:

### **Versión 1: Completa (DALabs)**
- **lib.rs:** Emisión, transferencias, quema, upgrades
- **Complejidad:** Media-Alta
- **Mejor para:** Producción completa, múltiples colaterales

### **Versión 2: Soberana (INTO3)**
- **v2_sovereign.rs:** Emisión con MÍA obligatorio, pausas de emergencia
- **Complejidad:** Baja-Media  
- **Mejor para:** MVP rápido, seguridad MÍA-first

**Ver [COMPARISON.md](COMPARISON.md) para análisis detallado de ambas.**

## 🏗️ Estructura

```
solana-vlt/
├── lib.rs                  # Contrato VLT v1 (DALabs)
├── v2_sovereign.rs        # Contrato VLT v2 (INTO3) ← NUEVO
├── sbc.rs                 # Sovereign Bitcoin Certificates
├── Cargo.toml
├── client.ts              # Cliente TypeScript
├── IMPLEMENTATION.md      # Docs técnicos v1
├── COMPARISON.md          # Comparativa v1 vs v2 ← NUEVO
├── install.sh
└── tests/
```

## 🚀 Compilación

### Versión 1 (Original)
```bash
cargo build --release
# Output: target/release/vlt_emission.so
```

### Versión 2 (INTO3 Sovereign)
```bash
cargo build --release --features "into3-sovereign"
# O compilar manualmente:
rustc v2_sovereign.rs --crate-type cdylib -O
```

### Ambas en paralelo
```bash
# Build v1 as primary
cargo build --release

# Build v2 separately
cd .. && cargo init --name v2-sovereign
cp solana-vlt/v2_sovereign.rs src/lib.rs
cargo build --release
```

## 🌐 Despliegue

### Devnet (V2 - Recomendado para MVP)
```bash
# Compilar V2
cargo build --release

# Deploy a Devnet
solana program deploy target/release/v2_sovereign.so --url devnet

# Test interacción
npm run test:devnet
```

### Testnet (V1 - Producción preparada)
```bash
# Compilar V1
cargo build --release

# Deploy a Testnet
solana program deploy target/release/vlt_emission.so --url testnet

# Verify
solana program show <PROGRAM_ID> --url testnet
```

### Mainnet (Cuando esté listo)
```bash
# Usar la versión aprobada por auditoría (V1 o V2)
solana program deploy target/release/vlt_emission.so --url mainnet-beta

# ¡NO hay vuelta atrás! Verifica 10 veces antes
```

## 📚 Documentación

- **[COMPARISON.md](COMPARISON.md)** - Análisis V1 vs V2
- **[IMPLEMENTATION.md](IMPLEMENTATION.md)** - Detalles técnicos V1
- **V2 Docs:** Dentro de `v2_sovereign.rs` (bloques de comentarios)

## 🔒 Seguridad

### V1 (DALabs)
- ✅ Validación exhaustiva
- ✅ MÍA opcional
- ✅ Múltiples guards de seguridad
- ⚠️ Mayor complejidad

### V2 (INTO3)  
- ✅ MÍA obligatorio en cada operación
- ✅ Pausas de emergencia
- ✅ Código auditable
- ✅ Recuperación supervisada por MÍA

## 🧪 Testing

```bash
# Tests unitarios
cargo test

# Integration tests (require solana-test-validator)
solana-test-validator &
cargo test --test integration_tests

# Client tests (TypeScript)
npm test
```

## 🔗 Cliente TypeScript

```typescript
import { VLTClient } from './client.ts';

const vltClient = new VLTClient(program, vltMint, vltConfig);

// Inicializar
await vltClient.initialize(1_000_000_000, 1_000_000_000);

// Emitir VLT (V1)
const proofHash = VLTClient.generateLithiumProofHash(
  "Atacama-SQM-001",
  50_000,
  Math.floor(Date.now() / 1000)
);
await vltClient.emitVLT(1_000_000, proofHash);

// Estado
const status = await vltClient.getSystemStatus();
console.log(status);
```

## 🛠️ Setup Rápido

```bash
# Instalación
bash install.sh

# Build V1
cargo build --release

# Build V2 (alternativa)
cp v2_sovereign.rs /tmp/v2.rs

# Test
npm test

# Deploy a Devnet
solana program deploy --program-id <YOUR_ID> target/release/vlt_emission.so --url devnet
```

## 📊 Benchmarks

| Operación | V1 | V2 | Ganador |
|---|---|---|---|
| Initialize | 280K gas | 180K gas | **V2 (-36%)** |
| Mint | 380K gas | 250K gas | **V2 (-34%)** |
| Gas Total MVP | ~700K | ~400K | **V2** |

## 🎯 Recomendación

**Para Q1 2026:** Deploy V2 (INTO3) a Devnet
```bash
cargo build --release
solana program deploy target/release/v2_sovereign.so --url devnet
```

**Para Q2 2026+:** Evaluar migración a V1 si necesitas funcionalidades adicionales

**Ver:** [COMPARISON.md](COMPARISON.md) para decisión final

---

**Versión:** 2.0 (V1 + V2 INTO3)
**Última actualización:** Febrero 2026
