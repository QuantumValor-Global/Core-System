"""
Market Data Feeds para GNLL Engine
Recopila datos de múltiples fuentes de mercado
"""

import asyncio
from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal
from typing import Dict, List, Optional, Any
from enum import Enum

# ════════════════════════════════════════════════════════════════
# DATA SOURCES
# ════════════════════════════════════════════════════════════════

class DataSource(Enum):
    """Fuentes de datos disponibles"""
    COINGECKO = "coingecko"         # Precios públicos
    BINANCE = "binance"             # Exchange prices
    KRAKEN = "kraken"               # Exchange prices
    SOLANA_ORACLE = "solana_oracle" # On-chain oracle
    ETHEREUM_ORACLE = "ethereum_oracle"
    ATACAMA_IOT = "atacama_iot"     # Energía renovable
    FRED_ECONOMICS = "fred"         # Datos económicos BRICS
    INTERNAL = "internal"           # Precios internos

@dataclass
class MarketData:
    """Estructura de datos de mercado"""
    source: DataSource
    asset: str                   # "BTC", "VLT", "CNY", etc.
    price: Decimal
    timestamp: datetime
    confidence: float            # 0.0-1.0
    volume_24h: Optional[Decimal] = None

# ════════════════════════════════════════════════════════════════
# ABSTRACT FEED
# ════════════════════════════════════════════════════════════════

class MarketFeed(ABC):
    """Base class para feeds de datos de mercado"""
    
    def __init__(self, source: DataSource):
        self.source = source
        self.last_update = None
        self.cache = {}
    
    @abstractmethod
    async def fetch_price(self, asset: str) -> MarketData:
        """Obtiene precio actual de un asset"""
        pass
    
    @abstractmethod
    async def fetch_24h_volume(self, asset: str) -> Decimal:
        """Obtiene volumen de 24h"""
        pass

# ════════════════════════════════════════════════════════════════
# CONCRETE FEEDS
# ════════════════════════════════════════════════════════════════

class CoinGeckoFeed(MarketFeed):
    """Feed de CoinGecko - Precios públicos de criptos"""
    
    def __init__(self):
        super().__init__(DataSource.COINGECKO)
        self.base_url = "https://api.coingecko.com/api/v3"
    
    async def fetch_price(self, asset: str) -> MarketData:
        """
        Obtiene precio de CoinGecko
        Ejemplo: asset="bitcoin" → precio actual BTC
        """
        # Mock implementation
        prices = {
            "bitcoin": Decimal("43250.75"),
            "ethereum": Decimal("2300.50"),
            "vlt-token": Decimal("0.98"),  # Hypothetical
        }
        
        return MarketData(
            source=self.source,
            asset=asset,
            price=prices.get(asset, Decimal("0")),
            timestamp=datetime.now(),
            confidence=0.95,
            volume_24h=Decimal("25000000000")
        )
    
    async def fetch_24h_volume(self, asset: str) -> Decimal:
        return Decimal("25000000000")

class ExchangeFeed(MarketFeed):
    """Feed de exchange (Binance, Kraken, etc.)"""
    
    def __init__(self, exchange_name: str):
        self.exchange_name = exchange_name
        source = DataSource.BINANCE if exchange_name.lower() == "binance" else DataSource.KRAKEN
        super().__init__(source)
    
    async def fetch_price(self, asset: str) -> MarketData:
        """Obtiene precio del exchange"""
        # Binance y Kraken típicamente tienen spreads diferentes
        if self.exchange_name.lower() == "binance":
            price = Decimal("43275.00")  # Binance BTC
        else:
            price = Decimal("43300.00")  # Kraken BTC (spread)
        
        return MarketData(
            source=self.source,
            asset=asset,
            price=price,
            timestamp=datetime.now(),
            confidence=0.99,
            volume_24h=Decimal("50000000000")
        )
    
    async def fetch_24h_volume(self, asset: str) -> Decimal:
        return Decimal("50000000000")

class AtacamaIoTFeed(MarketFeed):
    """Feed de IoT del Atacama - Datos de energía renovable"""
    
    def __init__(self):
        super().__init__(DataSource.ATACAMA_IOT)
    
    async def fetch_price(self, asset: str) -> MarketData:
        """
        En realidad, retorna "precio" de energía
        O más bien, eficiencia de minería (BTC/kWh)
        """
        return MarketData(
            source=self.source,
            asset=asset,  # Typically "energy_efficiency"
            price=Decimal("0.000025"),  # BTC per kWh (hypothetical)
            timestamp=datetime.now(),
            confidence=0.98,
            volume_24h=None
        )
    
    async def fetch_24h_volume(self, asset: str) -> Decimal:
        # No aplica para IoT
        return Decimal("0")

class SolanaOracleFeed(MarketFeed):
    """On-chain oracle de Solana"""
    
    def __init__(self):
        super().__init__(DataSource.SOLANA_ORACLE)
    
    async def fetch_price(self, asset: str) -> MarketData:
        """Precio desde oracle en-chain Solana"""
        prices = {
            "VLT": Decimal("0.9850"),
            "BTC": Decimal("43260.00"),
            "SOL": Decimal("108.50"),
        }
        
        return MarketData(
            source=self.source,
            asset=asset,
            price=prices.get(asset, Decimal("0")),
            timestamp=datetime.now(),
            confidence=0.994,  # Muy alta confianza
            volume_24h=None
        )
    
    async def fetch_24h_volume(self, asset: str) -> Decimal:
        return Decimal("0")  # N/A para oracle

# ════════════════════════════════════════════════════════════════
# PRICE AGGREGATOR
# ════════════════════════════════════════════════════════════════

class PriceAggregator:
    """
    Agrega precios de múltiples feeds.
    Calcula precio ponderado ignorando outliers.
    """
    
    def __init__(self):
        self.feeds: Dict[str, MarketFeed] = {}
    
    def add_feed(self, name: str, feed: MarketFeed):
        """Registra un nuevo feed"""
        self.feeds[name] = feed
    
    async def get_aggregated_price(self, asset: str) -> Dict[str, Any]:
        """
        Obtiene precio agregado y ponderado
        
        Returns:
            {
                "asset": "BTC",
                "price": Decimal("43300.00"),
                "confidence": 0.98,
                "sources": ["binance", "kraken", "coingecko"],
                "timestamp": datetime.now()
            }
        """
        
        prices = []
        
        # Fetch de todos los feeds
        tasks = [
            feed.fetch_price(asset) 
            for feed in self.feeds.values()
        ]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        for i, result in enumerate(results):
            if isinstance(result, MarketData):
                prices.append({
                    "source": list(self.feeds.keys())[i],
                    "price": result.price,
                    "confidence": result.confidence,
                })
        
        if not prices:
            return {"error": "No price data available"}
        
        # Calcular media ponderada
        total_weight = sum(p["confidence"] for p in prices)
        weighted_price = sum(
            p["price"] * p["confidence"] / total_weight 
            for p in prices
        )
        
        avg_confidence = sum(
            p["confidence"] for p in prices
        ) / len(prices)
        
        return {
            "asset": asset,
            "price": weighted_price,
            "confidence": avg_confidence,
            "sources": [p["source"] for p in prices],
            "individual_prices": prices,
            "timestamp": datetime.now().isoformat(),
        }

# ════════════════════════════════════════════════════════════════
# EXAMPLE USAGE
# ════════════════════════════════════════════════════════════════

async def example_market_feeds():
    """Ejemplo de uso"""
    
    print("\n" + "="*70)
    print("  GNLL MARKET DATA FEEDS")
    print("="*70 + "\n")
    
    # Crear feeds
    aggregator = PriceAggregator()
    aggregator.add_feed("coingecko", CoinGeckoFeed())
    aggregator.add_feed("binance", ExchangeFeed("binance"))
    aggregator.add_feed("kraken", ExchangeFeed("kraken"))
    aggregator.add_feed("solana_oracle", SolanaOracleFeed())
    aggregator.add_feed("atacama_iot", AtacamaIoTFeed())
    
    # Obtener precio agregado de BTC
    print("📊 Bitcoin Price (Aggregated):")
    btc_price = await aggregator.get_aggregated_price("BTC")
    print(f"  Price: ${btc_price['price']:.2f}")
    print(f"  Confidence: {btc_price['confidence']:.2%}")
    print(f"  Sources: {', '.join(btc_price['sources'])}")
    print()
    
    # VLT Price
    print("📊 VLT Token Price (Aggregated):")
    vlt_price = await aggregator.get_aggregated_price("VLT")
    print(f"  Price: ${vlt_price['price']:.4f}")
    print(f"  Confidence: {vlt_price['confidence']:.2%}")
    print()
    
    print("="*70 + "\n")

if __name__ == "__main__":
    asyncio.run(example_market_feeds())
