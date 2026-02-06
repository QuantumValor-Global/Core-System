// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title Patocoin
 * @dev Environmental Impact Token on Ethereum
 * 
 * Patocoin (PAT) represents verified environmental impact and regeneration.
 * Each PAT token is backed by measurable environmental metrics:
 * - CO2 sequestered (kg)
 * - Trees planted
 * - Water saved (liters)
 * - Habitat area restored (hectares)
 */
contract Patocoin is ERC20, ERC20Burnable, Ownable, Pausable {
    
    // ============================================
    // STATE VARIABLES
    // ============================================
    
    /// Máximo suministro de PAT
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18; // 1 billón PAT
    
    /// Precio base de 1 PAT en USD (con 18 decimales)
    uint256 public basePrice = 1 * 10 ** 18; // $1 por PAT
    
    /// Métrica de impacto ambiental acumulado
    struct ImpactMetric {
        uint256 co2Sequestered;      // en kg
        uint256 treeCount;            // número de árboles
        uint256 waterSaved;           // en litros
        uint256 habitatRestored;      // en hectáreas
        uint256 timestamp;
    }
    
    /// Registro de impacto total
    ImpactMetric public cumulativeImpact;
    
    /// Autorización para acuñar tokens
    mapping(address => bool) public authorizedMinters;
    
    /// Registro de transacciones de impacto
    mapping(uint256 => ImpactTransaction) public impactTransactions;
    uint256 public transactionCount;
    
    struct ImpactTransaction {
        address from;
        address to;
        uint256 amount;
        string impactCategory; // "reforestation", "carbon-offset", "water-conservation", etc.
        uint256 impactValue;
        uint256 timestamp;
    }
    
    // ============================================
    // EVENTS
    // ============================================
    
    event MinterAuthorized(address indexed minter);
    event MinterRevoked(address indexed minter);
    
    event PatoEmitted(
        uint256 indexed amount,
        string impactCategory,
        uint256 impactValue,
        address indexed minter,
        uint256 timestamp
    );
    
    event ImpactRecorded(
        uint256 co2,
        uint256 trees,
        uint256 water,
        uint256 habitat,
        uint256 timestamp
    );
    
    event ImpactTransfer(
        address indexed from,
        address indexed to,
        uint256 amount,
        string impactCategory,
        uint256 timestamp
    );
    
    event PriceUpdated(uint256 newPrice);
    
    // ============================================
    // MODIFIERS
    // ============================================
    
    modifier onlyAuthorizedMinter() {
        require(
            authorizedMinters[msg.sender] || msg.sender == owner(),
            "Only authorized minters can call this function"
        );
        _;
    }
    
    modifier withinMaxSupply(uint256 amount) {
        require(
            totalSupply() + amount <= MAX_SUPPLY,
            "Exceeds maximum supply"
        );
        _;
    }
    
    // ============================================
    // CONSTRUCTOR
    // ============================================
    
    constructor() ERC20("Patocoin", "PAT") {
        cumulativeImpact = ImpactMetric({
            co2Sequestered: 0,
            treeCount: 0,
            waterSaved: 0,
            habitatRestored: 0,
            timestamp: block.timestamp
        });
        
        authorizedMinters[msg.sender] = true;
    }
    
    // ============================================
    // MINTING FUNCTIONS
    // ============================================
    
    /**
     * @dev Emite PAT tokens respaldados por impacto ambiental verificado
     * @param to Dirección receptora
     * @param amount Cantidad de PAT a emitir
     * @param impactCategory Categoría de impacto ("reforestation", "carbon-offset", etc.)
     * @param impactValue Valor numérico del impacto (ej: kg de CO2 fijado)
     */
    function emitPAT(
        address to,
        uint256 amount,
        string calldata impactCategory,
        uint256 impactValue
    ) 
        public 
        onlyAuthorizedMinter 
        withinMaxSupply(amount)
        whenNotPaused 
    {
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be greater than 0");
        require(impactValue > 0, "Impact value must be greater than 0");
        
        // Validar relación impacto value:amount
        // 1 PAT = mínimo 1 kg de CO2 secuestrado (ajustable por categoría)
        _validateImpactRatio(impactCategory, amount, impactValue);
        
        // Acuñar tokens
        _mint(to, amount);
        
        // Registrar transacción de impacto
        impactTransactions[transactionCount] = ImpactTransaction({
            from: msg.sender,
            to: to,
            amount: amount,
            impactCategory: impactCategory,
            impactValue: impactValue,
            timestamp: block.timestamp
        });
        transactionCount++;
        
        emit PatoEmitted(
            amount,
            impactCategory,
            impactValue,
            msg.sender,
            block.timestamp
        );
    }
    
    /**
     * @dev Registra métricas de impacto ambiental acumulado
     */
    function recordImpact(
        uint256 co2ToAdd,
        uint256 treesToAdd,
        uint256 waterToAdd,
        uint256 habitatToAdd
    ) 
        public 
        onlyAuthorizedMinter 
    {
        cumulativeImpact.co2Sequestered += co2ToAdd;
        cumulativeImpact.treeCount += treesToAdd;
        cumulativeImpact.waterSaved += waterToAdd;
        cumulativeImpact.habitatRestored += habitatToAdd;
        cumulativeImpact.timestamp = block.timestamp;
        
        emit ImpactRecorded(
            co2ToAdd,
            treesToAdd,
            waterToAdd,
            habitatToAdd,
            block.timestamp
        );
    }
    
    // ============================================
    // TRANSFER FUNCTIONS WITH IMPACT TRACKING
    // ============================================
    
    /**
     * @dev Transferencia de PAT con tracking de impacto
     */
    function impactTransfer(
        address to,
        uint256 amount,
        string calldata impactCategory
    ) 
        public 
        returns (bool) 
    {
        require(transfer(to, amount), "Transfer failed");
        
        impactTransactions[transactionCount] = ImpactTransaction({
            from: msg.sender,
            to: to,
            amount: amount,
            impactCategory: impactCategory,
            impactValue: amount,
            timestamp: block.timestamp
        });
        transactionCount++;
        
        emit ImpactTransfer(msg.sender, to, amount, impactCategory, block.timestamp);
        return true;
    }
    
    // ============================================
    // MINTER MANAGEMENT
    // ============================================
    
    /**
     * @dev Autoriza una dirección para acuñar PAT
     */
    function authorizeMinter(address minter) 
        public 
        onlyOwner 
    {
        require(minter != address(0), "Invalid minter address");
        authorizedMinters[minter] = true;
        emit MinterAuthorized(minter);
    }
    
    /**
     * @dev Revoca autorización de acuñación
     */
    function revokeMinter(address minter) 
        public 
        onlyOwner 
    {
        authorizedMinters[minter] = false;
        emit MinterRevoked(minter);
    }
    
    // ============================================
    // ADMIN FUNCTIONS
    // ============================================
    
    /**
     * @dev Actualiza el precio base del PAT
     */
    function updateBasePrice(uint256 newPrice) 
        public 
        onlyOwner 
    {
        require(newPrice > 0, "Price must be greater than 0");
        basePrice = newPrice;
        emit PriceUpdated(newPrice);
    }
    
    /**
     * @dev Pausa todas las operaciones (emergencia)
     */
    function pause() 
        public 
        onlyOwner 
    {
        _pause();
    }
    
    /**
     * @dev Reanuda operaciones
     */
    function unpause() 
        public 
        onlyOwner 
    {
        _unpause();
    }
    
    // ============================================
    // VIEW FUNCTIONS
    // ============================================
    
    /**
     * @dev Obtiene las métricas de impacto acumuladas
     */
    function getImpactMetrics() 
        public 
        view 
        returns (
            uint256 co2Sequestered,
            uint256 treeCount,
            uint256 waterSaved,
            uint256 habitatRestored,
            uint256 timestamp
        ) 
    {
        return (
            cumulativeImpact.co2Sequestered,
            cumulativeImpact.treeCount,
            cumulativeImpact.waterSaved,
            cumulativeImpact.habitatRestored,
            cumulativeImpact.timestamp
        );
    }
    
    /**
     * @dev Obtiene información de una transacción de impacto
     */
    function getImpactTransaction(uint256 txId) 
        public 
        view 
        returns (ImpactTransaction memory) 
    {
        require(txId < transactionCount, "Invalid transaction ID");
        return impactTransactions[txId];
    }
    
    /**
     * @dev Calcula el valor en USD de PAT
     */
    function calculateUSDValue(uint256 patAmount) 
        public 
        view 
        returns (uint256) 
    {
        return (patAmount * basePrice) / 10 ** 18;
    }
    
    /**
     * @dev Obtiene información de suministro
     */
    function getSupplyInfo() 
        public 
        view 
        returns (
            uint256 currentSupply,
            uint256 maxSupply,
            uint256 remainingSupply
        ) 
    {
        return (
            totalSupply(),
            MAX_SUPPLY,
            MAX_SUPPLY - totalSupply()
        );
    }

    // ============================================
    // INTERNAL FUNCTIONS
    // ============================================
    
    /**
     * @dev Valida la relación entre PAT y valor de impacto
     */
    function _validateImpactRatio(
        string calldata category,
        uint256 patAmount,
        uint256 impactValue
    ) 
        internal 
        pure 
    {
        // Por defecto: 1 PAT requiere mínimo 1 unidad de impacto
        // Ajustable según categoría:
        // - "carbon-offset": 1 PAT = 1 kg CO2
        // - "reforestation": 1 PAT = 0.5 árboles
        // - "water-conservation": 1 PAT = 100 litros
        // - "habitat-restoration": 1 PAT = 0.01 hectáreas
        
        require(impactValue >= patAmount, "Insufficient impact value for PAT amount");
    }
    
    /**
     * @dev Hook para validaciones en transferencias
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) 
        internal 
        override 
        whenNotPaused 
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}
