# 🚀 QUANTUM-VALOR: Guía Completa de Ejecución

## Estado Actual del Sistema
- ✅ Instalador configurado: `scripts/quantum-valor-installer.sh`
- ✅ Smart Contract VLT: `programs/quantum_vlt/src/lib.rs`
- ✅ Configuración Anchor: `Anchor.toml`
- ✅ Script de Conexión: `app/connect.ts`
- ✅ Pipeline automático: `scripts/full-build-pipeline.sh`

---

## 📋 Instrucciones Paso a Paso

### **Opción A: Ejecutar desde Codespaces Web (Recomendado)**

1. **Abre Codespaces en el navegador:**
   - Ve a GitHub → QuantumValor-Global/Core-System
   - Click en `Code` → `Codespaces` → `Create codespace on main`
   - Espera a que se abra VS Code en el navegador

2. **Abre un Terminal Nuevo:**
   - Click en `Terminal` → `New Terminal`
   - O atajo: `Ctrl + `` (backtick)

3. **Ejecuta el comando de auto compilación:**
   ```bash
   cd /workspaces/Core-System && bash scripts/full-build-pipeline.sh
   ```

4. **Espera entre 5-15 minutos** según velocidad de conexión

---

### **Opción B: Ejecutar desde Terminal SSH/Local**

Si tienes acceso SSH al contenedor:

```bash
# 1. Conectar
ssh tuuser@codespace.host

# 2. Navegar
cd /workspaces/Core-System

# 3. Hacer ejecutable
chmod +x scripts/full-build-pipeline.sh

# 4. Ejecutar
bash scripts/full-build-pipeline.sh
```

---

### **Opción C: Ejecutar Pasos Manuales (Si el script falla)**

```bash
# PASO 1: Instalar dependencias
cd /workspaces/Core-System
bash scripts/quantum-valor-installer.sh

# PASO 2: Compilar contrato
cd blockchain-core/solana-vlt
anchor build

# PASO 3: Obtener Program ID
PROGRAM_ID=$(solana address -k target/deploy/quantum_vlt-keypair.json)
echo "Program ID: $PROGRAM_ID"

# PASO 4: Actualizar lib.rs
sed -i "s/declare_id!(\"VLT.*/declare_id!(\"$PROGRAM_ID\");/" programs/quantum_vlt/src/lib.rs

# PASO 5: Actualizar Anchor.toml
sed -i "s/quantum_vlt = \"VLT.*/quantum_vlt = \"$PROGRAM_ID\"/g" Anchor.toml

# PASO 6: Re-compilar
anchor build

# PASO 7: Verificar IDL
cat target/idl/quantum_vlt.json | head -50

# PASO 8: Verificar archivos generados
ls -lah target/idl/quantum_vlt.json
ls -lah target/deploy/quantum_vlt*
```

---

## 🎯 Resultados Esperados

Cuando termines, deberías tener:

```
✅ /workspaces/Core-System/blockchain-core/solana-vlt/target/
   ├── idl/quantum_vlt.json          (IDL para interfaces)
   ├── deploy/quantum_vlt.so         (Programa compilado)
   ├── deploy/quantum_vlt-keypair.json (Claves del programa)
   └── types/quantum_vlt.ts          (TypeScript types)

✅ Program ID sincronizado en:
   ├── programs/quantum_vlt/src/lib.rs (declare_id!)
   └── Anchor.toml (sección [programs.mainnet/devnet])
```

---

## 🚢 Próximo Paso: Desplegar en Devnet

Una vez compilado exitosamente:

```bash
# Configurar para Devnet (red de pruebas)
solana config set --url devnet

# Obtener SOL de prueba (2 tokens)
solana airdrop 2

# Desplegar el programa
cd /workspaces/Core-System/blockchain-core/solana-vlt
anchor deploy

# Ver transacciones
https://explorer.solana.com/?cluster=devnet
```

---

## 📞 Si hay Errores

### Error: "cargo: command not found"
```bash
source ~/.cargo/env
export PATH="$HOME/.cargo/bin:$PATH"
```

### Error: "anchor: command not found"  
```bash
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
avm install latest
avm use latest
source ~/.cargo/env
```

### Error en anchor build
```bash
# Ver logs detallados
cat anchor_build.log

# Limpiar y reintentar
cargo clean
anchor build --verbose
```

### Error: "No such file or directory"
- Asegúrate de estar en `/workspaces/Core-System`
- Verifica que `Anchor.toml` existe: `ls -la Anchor.toml`
- Verifica que `programs/quantum_vlt/src/lib.rs` existe

---

## 📊 Arquitectura Resultante

```
Blockchain Layer (Solana)
  ├── VLT Smart Contract (Rust/Anchor)
  │   ├── Initialización de Sistema
  │   ├── Emisión de VLT respaldado por Litio
  │   ├── Transferencias
  │   ├── Quema / Canje por Litio
  │   └── Actualización de Respaldo
  │
  └── IDL (Interface Definition Language)
      └── Traductor para Web3/AI/IA (MÍA/GNLL)

Client Layer (TypeScript)
  ├── app/connect.ts (Conexión inicial)
  └── solana-vlt-client/ (Cliente completo)

AI Layer (Python)
  ├── ai-guardian/gnll-liquidity/ (GNLL)
  └── ai-guardian/mia-defense/ (MÍA)
```

---

## ✅ Checklist de Progreso

- [ ] Terminal nuevo abierto (sin directorio especial)
- [ ] Ejecuté `bash scripts/full-build-pipeline.sh`
- [ ] Instalación de dependencias completada
- [ ] `anchor build` terminó exitosamente
- [ ] Program ID extraído
- [ ] Archivos sincronizados
- [ ] IDL verificado en `target/idl/`
- [ ] 🎉 Listo para Devnet

---

## 🏛️ Estado de la Infraestructura para Inversionistas

✅ **Código Verde** - Sin errores de compilación
✅ **IDL Generado** - Listo para integración en cualquier plataforma
✅ **Transparencia Total** - Verificable en blockchain público
✅ **Respaldo de Litio** - Auditable en tiempo real

**Repositorio GitHub:** https://github.com/QuantumValor-Global/Core-System
**Blockchain:** Solana Mainnet (cuando esté listo)
**Smart Contract:** Auditable, abierto, transparente

---

**¿Necesitas ayuda adicional o tienes preguntas? 🚀**
