// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ImpactCredits
 * @dev Sistema de comercio de créditos de impacto ambiental
 */
contract ImpactCredits is ERC20, Ownable {
    
    uint256 public constant MAX_SUPPLY = 100_000_000 * 10 ** 18;
    
    // Categorías de impacto
    enum ImpactCategory {
        CARBON_OFFSET,
        REFORESTATION,
        WATER_CONSERVATION,
        HABITAT_RESTORATION,
        RENEWABLE_ENERGY
    }
    
    struct CreditMetadata {
        ImpactCategory category;
        uint256 verificationLevel; // 1-5, donde 5 es máxima verificación
        address verifier;
        uint256 issueDate;
    }
    
    mapping(uint256 => CreditMetadata) public credits;
    uint256 public creditCount;
    
    event CreditIssued(
        uint256 indexed creditId,
        ImpactCategory category,
        uint256 amount,
        address verifier
    );
    
    event CreditRetired(uint256 indexed creditId, address burner);
    
    constructor() ERC20("Impact Credits", "CRED") {}
    
    function issueCreditBatch(
        ImpactCategory category,
        uint256 amount,
        address recipient,
        uint256 verificationLevel
    ) 
        public 
        onlyOwner 
    {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        require(verificationLevel >= 1 && verificationLevel <= 5, "Invalid verification level");
        
        _mint(recipient, amount);
        
        credits[creditCount] = CreditMetadata({
            category: category,
            verificationLevel: verificationLevel,
            verifier: msg.sender,
            issueDate: block.timestamp
        });
        
        emit CreditIssued(creditCount, category, amount, msg.sender);
        creditCount++;
    }
    
    function retireCredit(uint256 amount) 
        public 
    {
        burn(amount);
        emit CreditRetired(creditCount - 1, msg.sender);
    }
}
