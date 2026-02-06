# Atacama IoT Hub

## Descripción

Red de sensores integrada en operaciones de minería de Litio del Atacama para validación de activos físicos en tiempo real.

## Sensores

- **Sensores de Litio:** Medición de concentración y peso de reservas
- **Monitoreo Energético:** Paneles solares y capacidad de generación
- **Ambiental:** Emisiones de carbono, temperatura, humedad
- **GPS/Geolocalización:** Validación de ubicación de depósitos

## Estructura

```
atacama-iot/
├── firmware/
│   ├── sensor_drivers/
│   └── data_aggregator.ino
├── api/
│   ├── sensor_api.py
│   └── blockchain_bridge.py
├── dashboard/
│   └── monitoring_ui/
└── calibration/
```

## Integración Blockchain

Los datos de sensores se registran como pruebas de activos (Proof of Assets) en SBC.

## Conexión

```bash
python api/sensor_api.py --port 8080 --rpc-endpoint solana-mainnet
```
