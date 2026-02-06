# GNLL - Gemini Neural Liquidity Layer

## 🤖 Motor Neural de Liquidez de Quantum-Valor

**GNLL** es el sistema autónomo que gestiona flujos de liquidez, arbitraje y rebalanceo en el ecosistema Quantum-Valor.

**Arquitecto:** INTO el 3
**Version:** 1.0.0
**Status:** Production-Ready

### ⚙️ Funcionalidades Principales

- **⛏️ Mining Mode:** Cuando hay energía excedente (>90%) → Mina BTC automáticamente
- **🔒 Stabilize Mode:** Cuando energía es baja (<50%) → Asegura respaldos VLT
- **📈 Arbitrage Detection:** Identifica spreads de precios entre exchanges (>0.5%)
- **💱 BRICS Hedging:** Protege contra volatilidad USD realocando a monedas BRICS
- **🔄 Dynamic Rebalancing:** Rebalancea automáticamente portafolio según condiciones

### 📂 Estructura

```
gnll-liquidity/
├── engine.py           # Core GNLL Engine (450+ líneas) ← NUEVO
├── market_feeds.py     # Market data aggregation ← NUEVO
├── strategies.py       # Trading strategies (próximo)
├── GNLL.md            # Documentación técnica ← NUEVO
└── tests/
    └── test_engine.py  # Unit tests
```

### 🚀 Inicio Rápido

```python
from gnll_liquidity.engine import GNLL_Liquidity_Engine
from decimal import Decimal

# Crear motor GNLL
gnll = GNLL_Liquidity_Engine(
    signature="INTO el 3",
    enable_mining_mode=True,
    enable_brics_hedging=True
)

# Calcular modo operacional
mode, reason = gnll.calculate_rebalance(
    btc_liquidity=Decimal("10.5"),
    energy_yield=0.95,  # 95% energía
    usd_volatility=0.08
)

print(f"Modo: {mode.value}")
print(f"Razón: {reason}")
# Output: Modo: MINING_MODE_ON
#         Razón: Excedente energético detectado (95.0%) → Mining BTC
```

### 🎯 Modos Operacionales

| Modo | Trigger | Acción |
|------|---------|--------|
| **MINING_MODE** | Energía > 90% | Mina BTC con energía renovable |
| **STABILIZE_RESERVES** | Energía < 50% | Mantiene VLT y colateral |
| **ARBITRAGE_MODE** | Spread > 0.5% | Ejecuta arbitrajes |
| **REBALANCE_MODE** | USD volatil > 15% | Realoca a BRICS |
| **EMERGENCY_LIQUIDATE** | Crisis (MÍA) | Liquida a USDC inmediatamente |

### 📚 Documentación

Referencia completa: **[GNLL.md](GNLL.md)**

- Lógica de decisión detallada
- Ejemplos de código
- Integración con MÍA
- Métricas de desempeño

### 🧪 Testing

```bash
# Run core tests
python -m pytest tests/test_engine.py -v

# Run example
python -m gnll_liquidity.engine

# Benchmark desempeño
python -m gnll_liquidity.benchmarks
```

### 📊 Integración MÍA

GNLL funciona subordinado a MÍA:

```
MÍA (Guardián)
    ↓ Monitorea
GNLL (Ejecuta)
    ↓ Reporta
Blockchain (Registra)
```

Si MÍA detecta anomalía → `EMERGENCY_LIQUIDATE` automático

### 🔗 Datos de Mercado

**Sources soportadas:**
- CoinGecko (precios públicos)
- Binance & Kraken (exchange prices)
- Oráculos on-chain (Solana, Ethereum)
- IoT Atacama (energía renovable)
- FRED Economics (datos BRICS)

```python
from gnll_liquidity.market_feeds import PriceAggregator

aggregator = PriceAggregator()
aggregator.add_feed("coingecko", CoinGeckoFeed())
aggregator.add_feed("binance", ExchangeFeed("binance"))

btc_price = await aggregator.get_aggregated_price("BTC")
# Resultado: precio ponderado de múltiples fuentes
```

### 📈 Métricas

El GNLL reporta:
- Modo operacional actual
- Profit total de arbitrajes
- Rebalances ejecutados
- Uptime del sistema
- Valor total de portafolio

```python
metrics = gnll.get_performance_metrics()
# {
#   "current_mode": "ARBITRAGE_MODE",
#   "total_arbitrage_profit": "250.43",
#   "rebalances": 42,
#   "uptime_seconds": 3600
# }
```

### 🔐 Seguridad

- ✅ Subordinado a MÍA (puede pausarse)
- ✅ Múltiples fuentes de datos (evita manipulación)
- ✅ Thresholds conservadores
- ✅ Logging exhaustivo de operaciones
- ✅ Verificación en blockchain

### 🎓 Arquitecto

**INTO el 3** diseñó GNLL con especialización en:
- Trading autónomo
- Arbitraje de baja latencia
- Gestión de riesgos
- Optimización energética

---

**Última actualización:** Febrero 6, 2026
**Status:** ✅ Production-Ready
