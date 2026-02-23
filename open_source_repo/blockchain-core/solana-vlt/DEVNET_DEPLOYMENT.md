# 🚀 Guía de Despliegue en Solana Devnet

**Program ID:** `VLT3QuantumValorLithiumBacking1111111111111`

---

## Paso 1: Preparar Ambiente Solana

```bash
# Configurar para Devnet (red de pruebas)
solana config set --url devnet

# Verificar configuración
solana config get
# Debería mostrar:
# RPC URL: https://api.devnet.solana.com
# WebSocket URL: wss://api.devnet.solana.com/ (computed)
# Keypair Path: ~/.config/solana/id.json
# Commitment: confirmed

# Generar keypair si no existe
solana-keygen new --outfile ~/.config/solana/id.json

# Ver dirección pública
solana address
```

---

## Paso 2: Obtener SOL de Prueba

```bash
# Solicitar 2 SOL de prueba (suficiente para deploy + txns)
solana airdrop 2

# Verificar saldo
solana balance

# Debería mostrar algo como:
# 2 SOL
```

---

## Paso 3: Compilar y Desplegar

```bash
# Ir a la carpeta del programa
cd /workspaces/Core-System/blockchain-core/solana-vlt

# Compilar con Anchor
anchor build

# Desplegar a Devnet
anchor deploy

# Verás output como:
# Deploying cluster: https://api.devnet.solana.com
# Program path: /workspaces/Core-System/blockchain-core/solana-vlt/target/deploy/quantum_vlt.so
# Program Id: VLT3QuantumValorLithiumBacking1111111111111
# ....
```

---

## Paso 4: Verificar Deployment

### En el Explorer Web

Visita: **https://explorer.solana.com/**

1. En la barra de búsqueda, pega el Program ID:
   ```
   VLT3QuantumValorLithiumBacking1111111111111
   ```

2. Deberías ver:
   - ✅ Program Status: **Active**
   - 📦 Program Data Size: ~10-12 KB
   - 🔐 Owner: **BPFLoaderUpgradeab1e11111111111111111111111**
   - 📋 Transacciones de deployment

### En Terminal

```bash
# Verificar que el programa está deployado
solana program info VLT3QuantumValorLithiumBacking1111111111111

# Debería mostrar:
# Program Id: VLT3QuantumValorLithiumBacking1111111111111
# Owner: BPFLoaderUpgradeab1e
# Lamports: 907920
# Data len: 11336
# Executable: Yes
```

---

## Paso 5: Probar el Programa

### Test Manual en TypeScript

```bash
# Instalar dependencias
npm install

# O si yarn:
yarn install

# Ir a la carpeta app
cd app

# Ejecutar test de conexión
npx ts-node connect.ts

# Debería mostrar:
# -----------------------------------------
# SISTEMA QUANTUM-VALOR ACTIVADO
# ARQUITECTO: INTO el 3
# CONECTADO A LA RED: https://api.devnet.solana.com
# -----------------------------------------
# (Si hay error sobre estado no inicializado, es NORMAL)
```

### Crear una Instrucción de Inicialización

```typescript
// En app/initialize.ts (crear este archivo)
import * as anchor from "@coral-xyz/anchor";
import { web3 } from "@coral-xyz/anchor";
import * as spl from "@solana/spl-token";

const provider = anchor.AnchorProvider.env();
anchor.setProvider(provider);

const program = anchor.workspace.QuantumVlt;
const authority = provider.wallet.publicKey;

// Crear mint de VLT
const vltMint = web3.Keypair.generate();

// Crear cuenta de config (PDA)
const [vltConfigPDA] = web3.PublicKey.findProgramAddressSync(
  [Buffer.from("vlt_config")],
  program.programId
);

// Ejecutar inicialización
const tx = await program.methods
  .initializeVltSystem(
    new anchor.BN(1_000_000_000),  //  $1B en respaldo
    new anchor.BN(10_000_000_000)  // 10B VLT max supply
  )
  .accounts({
    authority,
    vltConfig: vltConfigPDA,
    vltMint: vltMint.publicKey,
    tokenProgram: spl.TOKEN_PROGRAM_ID,
    systemProgram: web3.SystemProgram.programId,
    rent: web3.SYSVAR_RENT_PUBKEY,
  })
  .signers([vltMint])
  .rpc();

console.log("TX:", tx);
console.log("Mint:", vltMint.publicKey.toString());
console.log("Config:", vltConfigPDA.toString());
```

---

## Paso 6: Monitorear Eventos

```bash
# Ver programas deployados
solana program list

# Ver transacciones del programa
solana transaction history VLT3QuantumValorLithiumBacking1111111111111

# En el Explorer, ir a:
# https://explorer.solana.com/?cluster=devnet
# y buscar tu wallet address para ver todas tus txns
```

---

## Paso 7: Integración con Frontend/IA

### Conectar desde tu App

```typescript
import * as anchor from "@coral-xyz/anchor";
import { Connection, PublicKey } from "@solana/web3.js";

const programId = new PublicKey(
  "VLT3QuantumValorLithiumBacking1111111111111"
);

const connection = new Connection(
  "https://api.devnet.solana.com",
  "confirmed"
);

// Leer estado de VLT
const vltConfigAddress = PublicKey.findProgramAddressSync(
  [Buffer.from("vlt_config")],
  programId
)[0];

const accountInfo = await connection.getAccountInfo(vltConfigAddress);
// Deserializar y usar...
```

---

## 🔍 Troubleshooting

### Error: "Program already exists"
```bash
# Si el programa ya existe, necesitas actualizar:
anchor upgrade --provider.cluster devnet
```

### Error: "Insufficient SOL"
```bash
# Solicitar más tokens
solana airdrop 5

# Si airdrop está limitado, ir a:
# https://faucet.solana.com/
```

### Error: "Transaction too large"
```bash
# Es normal al inicializar con muchas cuentas
# Divide en múltiples transacciones o usa instrucciones composables
```

### Programa no aparece en Explorer
```bash
# Puede tomar 30-60 segundos
# Espera y recarga la página
# O verifica directamente con solana CLI:
solana account VLT3QuantumValorLithiumBacking1111111111111
```

---

## 📊 Costos de Devnet

**¡GRATIS!** 

Devnet usa "airdrop" que simula SOL sin valor real. Perfecto para:
- ✅ Testing
- ✅ Desarrollo
- ✅ Demo a inversionistas
- ✅ Integración de sistemas

---

## 🎯 Próximo Paso: Mainnet

Una vez verificado en Devnet:

```bash
# Cambiar a Mainnet (requerir fondos REALES)
solana config set --url mainnet

# Verificar saldo (necesitas SOL real esta vez)
solana balance

# Desplegar a Mainnet
anchor deploy  # Costará ~0.1-0.5 SOL
```

---

**Status:** 🟢 Listo para Devnet  
**Arquitecto:** INTO el 3  
**Blockchain:** Solana Devnet → Mainnet
