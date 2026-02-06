# Blockchain Core - Solana VLT

## Arquitectura del Contrato

### Módulos Principales

#### 1. **lib.rs** - VLT Emission Contract
El corazón del sistema de tokenización de litio.

**Funciones principales:**
- `initialize_vlt_system()` - Configuración inicial del sistema
- `emit_vlt_backed()` - Emisión de VLT respaldado por litio
- `transfer_vlt()` - Transferencias con registro
- `burn_vlt_for_lithium()` - Canje por litio físico
- `update_lithium_backing()` - Actualización de respaldo
- `toggle_system_status()` - Control del sistema

**Características de Seguridad:**
- Validación de maximum supply
- Verificación de respaldo suficiente
- Control de autoridades
- Eventos inmutables

#### 2. **sbc.rs** - Sovereign Bitcoin Certificate
Certificados de Bitcoin respaldados por energía renovable.

### Flujo de Emisión

```
Litio Físico (Atacama)
        ↓
    [Prueba de Litio - Hash SHA256]
        ↓
    [Contrato VLT - Validación]
        ↓
    [Emisión de VLT Tokens]
        ↓
    [Registro de Eventos]
        ↓
    [Respaldo Verificable en Blockchain]
```

### Validaciones Críticas

1. **Respaldo de Litio:** Cada VLT emitido debe estar respaldado por litio verificable
2. **Máximo Suministro:** No se puede exceder el techo de emisión
3. **Autorización:** Solo las autoridades autorizadas pueden actuar
4. **Estado del Sistema:** El sistema puede pausarse en caso de emergencia

### Compilación

```bash
cd /blockchain-core/solana-vlt
cargo build --release
```

### Testing

```bash
cargo test
```

### Despliegue

```bash
# En testnet
solana program deploy target/release/vlt_emission.so --url testnet

# En mainnet (requiere wallet autorizada)
solana program deploy target/release/vlt_emission.so --url mainnet-beta
```

### Interacción desde el Cliente

```rust
// Ejemplo: Emitir 1,000 VLT
let tx = emit_vlt_backed(
    client,
    amount: 1_000_000_000, // 1,000 VLT en lamports
    lithium_proof_hash: [0x12, 0x34, ...],
)?;
```

### Monitoreo

Los eventos del contrato pueden monitorearse en tiempo real:
- `VLTEmitted` - Nueva emisión
- `VLTTransferred` - Transferencias
- `VLTBurned` - Redenciones
- `LithiumBackingUpdated` - Cambios de respaldo
- `SystemStatusChanged` - Cambios de estado

---

**Versión:** 0.1.0
**Licencia:** BUSL-1.1
**Última actualización:** Febrero 2026
