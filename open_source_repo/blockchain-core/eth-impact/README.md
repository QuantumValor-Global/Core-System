# Ethereum Impact Contracts - Patocoin

## Descripción

Contratos inteligentes en Solidity para regeneración ambiental y patocoin:

- **Patocoin:** Token de impacto ambiental
- **Impact Credits:** Sistema de transabilidad de impacto

## Estructura

```
eth-impact/
├── contracts/
│   ├── Patocoin.sol
│   ├── ImpactCredits.sol
│   └── Regeneration.sol
├── test/
├── package.json
└── hardhat.config.js
```

## Compilación

```bash
npx hardhat compile
```

## Testing

```bash
npx hardhat test
```

## Despliegue

```bash
npx hardhat run scripts/deploy.js --network mainnet
```
