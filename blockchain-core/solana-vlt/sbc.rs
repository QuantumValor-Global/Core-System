use anchor_lang::prelude::*;

declare_id!("SBC1111111111111111111111111111111111111111");

#[program]
pub mod sbc_certificates {
    use super::*;

    // ============================================
    // SBC - SOVEREIGN BITCOIN CERTIFICATE
    // Energy-backed Bitcoin Liquidity Layer
    // ============================================

    /// Inicializa el sistema de SBC
    pub fn initialize_sbc(
        ctx: Context<InitializeSBC>,
        sbc_ratio: u8, // Ratio de BTC backing per SBC
    ) -> Result<()> {
        let sbc_config = &mut ctx.accounts.sbc_config;
        
        sbc_config.authority = ctx.accounts.authority.key();
        sbc_config.btc_backing = 0;
        sbc_config.sbc_ratio = sbc_ratio;
        sbc_config.bump = ctx.bumps.sbc_config;
        
        msg!("✓ SBC System initialized");
        msg!("  Bitcoin Backing Ratio: 1 SBC = {} satoshis", sbc_ratio);
        
        Ok(())
    }

    /// Emite SBC respaldado por certificado de energía
    pub fn emit_sbc(
        ctx: Context<EmitSBC>,
        energy_kwh: u64,
        sbc_amount: u64,
    ) -> Result<()> {
        let sbc_config = &mut ctx.accounts.sbc_config;
        
        // Validar proporción: 1 kWh = 1 satoshi de respaldo
        require!(
            energy_kwh >= sbc_amount,
            SBCError::InsufficientEnergyBacking
        );

        sbc_config.btc_backing += sbc_amount;

        msg!("✓ SBC Emission:");
        msg!("  Amount: {} SBC", sbc_amount);
        msg!("  Energy Backing: {} kWh", energy_kwh);
        
        Ok(())
    }
}

#[account]
pub struct SBCConfig {
    pub authority: Pubkey,
    pub btc_backing: u64,
    pub sbc_ratio: u8,
    pub bump: u8,
}

#[derive(Accounts)]
pub struct InitializeSBC<'info> {
    #[account(mut)]
    pub authority: Signer<'info>,
    
    #[account(
        init,
        payer = authority,
        space = 8 + 32 + 8 + 1 + 1,
        seeds = [b"sbc_config"],
        bump
    )]
    pub sbc_config: Account<'info, SBCConfig>,
    
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
}

#[derive(Accounts)]
pub struct EmitSBC<'info> {
    #[account(mut)]
    pub authority: Signer<'info>,
    
    #[account(mut, seeds = [b"sbc_config"], bump = sbc_config.bump)]
    pub sbc_config: Account<'info, SBCConfig>,
}

#[error_code]
pub enum SBCError {
    #[msg("Insuficiente respaldo energético")]
    InsufficientEnergyBacking,
}
