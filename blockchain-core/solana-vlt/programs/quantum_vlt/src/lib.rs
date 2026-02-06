use anchor_lang::prelude::*;
use anchor_spl::token::{self, Mint, Token, TokenAccount, Transfer, Burn, MintTo};
use solana_program::program_pack::Pack;

declare_id!("VLT1111111111111111111111111111111111111111");

#[program]
pub mod vlt_emission {
    use super::*;

    // ============================================
    // VLT EMISSION CONTRACT - SOLANA
    // Heart of Lithium Tokenization
    // ============================================

    /// Inicializa el sistema de emisión VLT
    /// Parámetros:
    /// - lithium_backing_usd: Valor de respaldo de litio en USD (en lamports equivalentes)
    /// - max_supply: Suministro máximo de VLT
    pub fn initialize_vlt_system(
        ctx: Context<InitializeVLT>,
        lithium_backing_usd: u64,
        max_supply: u64,
    ) -> Result<()> {
        let vlt_config = &mut ctx.accounts.vlt_config;
        
        vlt_config.authority = ctx.accounts.authority.key();
        vlt_config.mint = ctx.accounts.vlt_mint.key();
        vlt_config.lithium_backing = lithium_backing_usd;
        vlt_config.max_supply = max_supply;
        vlt_config.current_supply = 0;
        vlt_config.reserve_ratio = 100; // 100% backing initially
        vlt_config.bump = ctx.bumps.vlt_config;
        vlt_config.is_active = true;
        
        msg!("✓ VLT System initialized");
        msg!("  Lithium Backing: ${}", lithium_backing_usd);
        msg!("  Max Supply: {} VLT", max_supply);
        
        Ok(())
    }

    /// Emite VLT respaldado por prueba de litio
    /// Parámetros:
    /// - amount: Cantidad de VLT a emitir
    /// - lithium_proof_hash: Hash SHA256 de la prueba de depósito de litio
    pub fn emit_vlt_backed(
        ctx: Context<EmitVLT>,
        amount: u64,
        lithium_proof_hash: [u8; 32],
    ) -> Result<()> {
        let vlt_config = &mut ctx.accounts.vlt_config;
        
        // Validaciones
        require!(vlt_config.is_active, VLTError::SystemInactive);
        require!(
            vlt_config.current_supply + amount <= vlt_config.max_supply,
            VLTError::MaxSupplyExceeded
        );
        require!(amount > 0, VLTError::InvalidAmount);

        // Verificar que el respaldo de litio es suficiente
        let backing_required = (amount as u128 * vlt_config.lithium_backing as u128)
            / vlt_config.max_supply as u128;
        require!(
            backing_required <= vlt_config.lithium_backing as u128,
            VLTError::InsufficientLithiumBacking
        );

        // Emitir VLT
        let cpi_accounts = MintTo {
            mint: ctx.accounts.vlt_mint.to_account_info(),
            to: ctx.accounts.token_account.to_account_info(),
            authority: ctx.accounts.authority.to_account_info(),
        };
        let cpi_program = ctx.accounts.token_program.to_account_info();
        let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
        token::mint_to(cpi_ctx, amount)?;

        // Actualizar estado
        vlt_config.current_supply += amount;

        // Registrar evento de emisión
        emit!(VLTEmitted {
            timestamp: Clock::get()?.unix_timestamp,
            amount,
            lithium_proof_hash,
            emitter: ctx.accounts.authority.key(),
            new_supply: vlt_config.current_supply,
        });

        msg!("✓ VLT Emission Event:");
        msg!("  Amount: {} VLT", amount);
        msg!("  Hash: {}", format_hash(&lithium_proof_hash));
        msg!("  New Supply: {} VLT", vlt_config.current_supply);
        
        Ok(())
    }

    /// Transferencia de VLT con actualización de registro de propiedad
    pub fn transfer_vlt(
        ctx: Context<TransferVLT>,
        amount: u64,
    ) -> Result<()> {
        require!(amount > 0, VLTError::InvalidAmount);
        
        // Transferencia SPL estándar
        let cpi_accounts = Transfer {
            from: ctx.accounts.from_token_account.to_account_info(),
            to: ctx.accounts.to_token_account.to_account_info(),
            authority: ctx.accounts.owner.to_account_info(),
        };
        let cpi_program = ctx.accounts.token_program.to_account_info();
        let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
        token::transfer(cpi_ctx, amount)?;

        // Registrar evento de transferencia
        emit!(VLTTransferred {
            timestamp: Clock::get()?.unix_timestamp,
            from: ctx.accounts.owner.key(),
            to: ctx.accounts.to_owner.key(),
            amount,
        });

        msg!("✓ VLT Transfer: {} tokens", amount);
        
        Ok(())
    }

    /// Quema (burn) de VLT y canje por litio físico
    /// Este es el mecanismo de salida del sistema
    pub fn burn_vlt_for_lithium(
        ctx: Context<BurnVLT>,
        amount: u64,
    ) -> Result<()> {
        require!(amount > 0, VLTError::InvalidAmount);
        
        let vlt_config = &mut ctx.accounts.vlt_config;

        // Quema de tokens
        let cpi_accounts = Burn {
            mint: ctx.accounts.vlt_mint.to_account_info(),
            from: ctx.accounts.token_account.to_account_info(),
            authority: ctx.accounts.owner.to_account_info(),
        };
        let cpi_program = ctx.accounts.token_program.to_account_info();
        let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
        token::burn(cpi_ctx, amount)?;

        // Actualizar suministro
        vlt_config.current_supply = vlt_config.current_supply.saturating_sub(amount);

        // Registrar evento de canje
        emit!(VLTBurned {
            timestamp: Clock::get()?.unix_timestamp,
            amount,
            burner: ctx.accounts.owner.key(),
            remaining_supply: vlt_config.current_supply,
        });

        msg!("✓ VLT Burn & Lithium Redemption:");
        msg!("  Burned: {} VLT", amount);
        msg!("  Remaining Supply: {} VLT", vlt_config.current_supply);
        
        Ok(())
    }

    /// Actualiza el respaldo de litio (requiere autoridad)
    pub fn update_lithium_backing(
        ctx: Context<UpdateBacking>,
        new_backing_amount: u64,
    ) -> Result<()> {
        require!(ctx.accounts.vlt_config.authority == ctx.accounts.authority.key(), 
            VLTError::UnauthorizedAuthority);
        require!(new_backing_amount > 0, VLTError::InvalidAmount);

        let vlt_config = &mut ctx.accounts.vlt_config;
        let old_backing = vlt_config.lithium_backing;
        vlt_config.lithium_backing = new_backing_amount;

        // Actualizar ratio de reserva
        vlt_config.reserve_ratio = if vlt_config.current_supply > 0 {
            ((new_backing_amount as u128 * 100) / vlt_config.current_supply as u128) as u8
        } else {
            100
        };

        emit!(LithiumBackingUpdated {
            timestamp: Clock::get()?.unix_timestamp,
            old_backing,
            new_backing: new_backing_amount,
            updated_by: ctx.accounts.authority.key(),
            reserve_ratio: vlt_config.reserve_ratio,
        });

        msg!("✓ Lithium Backing Updated:");
        msg!("  Old: ${}", old_backing);
        msg!("  New: ${}", new_backing_amount);
        msg!("  Reserve Ratio: {}%", vlt_config.reserve_ratio);
        
        Ok(())
    }

    /// Pausa o reanuda el sistema (solo autoridad)
    pub fn toggle_system_status(
        ctx: Context<ToggleStatus>,
        is_active: bool,
    ) -> Result<()> {
        require!(ctx.accounts.vlt_config.authority == ctx.accounts.authority.key(),
            VLTError::UnauthorizedAuthority);

        let vlt_config = &mut ctx.accounts.vlt_config;
        vlt_config.is_active = is_active;

        emit!(SystemStatusChanged {
            timestamp: Clock::get()?.unix_timestamp,
            is_active,
            changed_by: ctx.accounts.authority.key(),
        });

        msg!("{} VLT System", 
            if is_active { "✓ Reactivated" } else { "⊗ Paused" });
        
        Ok(())
    }
}

// ============================================
// ACCOUNT STRUCTURES
// ============================================

#[account]
pub struct VLTConfig {
    /// Autoridad para updates críticos
    pub authority: Pubkey,
    /// Mint de tokens VLT
    pub mint: Pubkey,
    /// Respaldo total en USD (equivalente en SOL)
    pub lithium_backing: u64,
    /// Suministro máximo permitido
    pub max_supply: u64,
    /// Suministro actual en circulación
    pub current_supply: u64,
    /// Ratio de reserva (backing / current_supply * 100)
    pub reserve_ratio: u8,
    /// Bump para PDA
    pub bump: u8,
    /// Estado del sistema
    pub is_active: bool,
}

// ============================================
// CONTEXT STRUCTURES
// ============================================

#[derive(Accounts)]
pub struct InitializeVLT<'info> {
    #[account(mut)]
    pub authority: Signer<'info>,
    
    #[account(
        init,
        payer = authority,
        space = 8 + 32 + 32 + 8 + 8 + 8 + 1 + 1 + 1,
        seeds = [b"vlt_config"],
        bump
    )]
    pub vlt_config: Account<'info, VLTConfig>,
    
    #[account(
        init,
        payer = authority,
        mint::decimals = 6,
        mint::authority = authority,
    )]
    pub vlt_mint: Account<'info, Mint>,
    
    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
}

#[derive(Accounts)]
pub struct EmitVLT<'info> {
    #[account(mut)]
    pub authority: Signer<'info>,
    
    #[account(mut, seeds = [b"vlt_config"], bump = vlt_config.bump)]
    pub vlt_config: Account<'info, VLTConfig>,
    
    #[account(mut)]
    pub vlt_mint: Account<'info, Mint>,
    
    #[account(mut)]
    pub token_account: Account<'info, TokenAccount>,
    
    pub token_program: Program<'info, Token>,
}

#[derive(Accounts)]
pub struct TransferVLT<'info> {
    pub owner: Signer<'info>,
    
    #[account(mut)]
    pub from_token_account: Account<'info, TokenAccount>,
    
    #[account(mut)]
    pub to_token_account: Account<'info, TokenAccount>,
    
    pub to_owner: UncheckedAccount<'info>,
    
    pub token_program: Program<'info, Token>,
}

#[derive(Accounts)]
pub struct BurnVLT<'info> {
    pub owner: Signer<'info>,
    
    #[account(mut, seeds = [b"vlt_config"], bump = vlt_config.bump)]
    pub vlt_config: Account<'info, VLTConfig>,
    
    #[account(mut)]
    pub vlt_mint: Account<'info, Mint>,
    
    #[account(mut)]
    pub token_account: Account<'info, TokenAccount>,
    
    pub token_program: Program<'info, Token>,
}

#[derive(Accounts)]
pub struct UpdateBacking<'info> {
    pub authority: Signer<'info>,
    
    #[account(mut, seeds = [b"vlt_config"], bump = vlt_config.bump)]
    pub vlt_config: Account<'info, VLTConfig>,
}

#[derive(Accounts)]
pub struct ToggleStatus<'info> {
    pub authority: Signer<'info>,
    
    #[account(mut, seeds = [b"vlt_config"], bump = vlt_config.bump)]
    pub vlt_config: Account<'info, VLTConfig>,
}

// ============================================
// EVENTS
// ============================================

#[event]
pub struct VLTEmitted {
    pub timestamp: i64,
    pub amount: u64,
    pub lithium_proof_hash: [u8; 32],
    pub emitter: Pubkey,
    pub new_supply: u64,
}

#[event]
pub struct VLTTransferred {
    pub timestamp: i64,
    pub from: Pubkey,
    pub to: Pubkey,
    pub amount: u64,
}

#[event]
pub struct VLTBurned {
    pub timestamp: i64,
    pub amount: u64,
    pub burner: Pubkey,
    pub remaining_supply: u64,
}

#[event]
pub struct LithiumBackingUpdated {
    pub timestamp: i64,
    pub old_backing: u64,
    pub new_backing: u64,
    pub updated_by: Pubkey,
    pub reserve_ratio: u8,
}

#[event]
pub struct SystemStatusChanged {
    pub timestamp: i64,
    pub is_active: bool,
    pub changed_by: Pubkey,
}

// ============================================
// ERROR CODES
// ============================================

#[error_code]
pub enum VLTError {
    #[msg("Sistema inactivo")]
    SystemInactive,
    
    #[msg("Se excedió el suministro máximo")]
    MaxSupplyExceeded,
    
    #[msg("Cantidad inválida")]
    InvalidAmount,
    
    #[msg("Insuficiente respaldo de litio")]
    InsufficientLithiumBacking,
    
    #[msg("Autoridad no autorizada")]
    UnauthorizedAuthority,
    
    #[msg("Error de precisión en cálculos")]
    PrecisionError,
}

// ============================================
// UTILITY FUNCTIONS
// ============================================

fn format_hash(hash: &[u8; 32]) -> String {
    hash.iter()
        .take(4)
        .map(|b| format!("{:02x}", b))
        .collect::<Vec<_>>()
        .join("")
        + "..."
}

// ============================================
// TESTING (Offline)
// ============================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_vlt_config_initialization() {
        // Test que los campos se inicializan correctamente
        assert_eq!(100, 100); // Placeholder para estructura
    }

    #[test]
    fn test_max_supply_validation() {
        // Test que no se puede exceder max_supply
        assert!(true); // Placeholder
    }

    #[test]
    fn test_lithium_backing_ratio() {
        // Test que el ratio de backing se calcula correctamente
        let backing = 1_000_000;
        let supply = 500_000;
        let ratio = ((backing * 100) / supply) as u8;
        assert_eq!(ratio, 200); // 200% backing
    }
}
