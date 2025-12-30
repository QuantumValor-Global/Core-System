use anchor_lang::prelude::*;
use anchor_spl::token::{self, Mint, Token, TokenAccount, MintTo};

declare_id!("Tu_Direccion_De_Programa_Aqui");

const MAX_ASSET_ID_LEN: usize = 64;

#[program]
pub mod quantum_vlt {
    use super::*;

    // Inicializa el colateral basado en activos (Litio/PVC)
    pub fn initialize_collateral(ctx: Context<Initialize>, amount: u64, asset_id: String) -> Result<()> {
        let collateral = &mut ctx.accounts.collateral_account;
        collateral.asset_id = asset_id;
        collateral.val_backing = amount; // Valor auditado del litio
        collateral.is_verified = true;
        Ok(())
    }

    // Emite VLT si el colateral está verificado
    pub fn mint_vlt(ctx: Context<MintVLT>, amount: u64) -> Result<()> {
        let collateral = &ctx.accounts.collateral_account;
        if !collateral.is_verified {
            return Err(error!(ErrorCode::UnverifiedCollateral));
        }

        let cpi_accounts = MintTo {
            mint: ctx.accounts.mint.to_account_info(),
            to: ctx.accounts.recipient.to_account_info(),
            authority: ctx.accounts.mint_authority.to_account_info(),
        };

        let cpi_program = ctx.accounts.token_program.to_account_info();

        token::mint_to(CpiContext::new(cpi_program, cpi_accounts), amount)?;

        Ok(())
    }
}

#[account]
pub struct CollateralAccount {
    pub asset_id: String,
    pub val_backing: u64,
    pub is_verified: bool,
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, payer = payer, space = 8 + 4 + MAX_ASSET_ID_LEN + 8 + 1)]
    pub collateral_account: Account<'info, CollateralAccount>,
    #[account(mut)]
    pub payer: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct MintVLT<'info> {
    #[account(mut)]
    pub collateral_account: Account<'info, CollateralAccount>,
    #[account(mut)]
    pub mint: Account<'info, Mint>,
    #[account(mut)]
    pub recipient: Account<'info, TokenAccount>,
    pub mint_authority: Signer<'info>,
    pub token_program: Program<'info, Token>,
}

#[error_code]
pub enum ErrorCode {
    #[msg("El colateral de litio no ha sido auditado por el oráculo.")]
    UnverifiedCollateral,
}
