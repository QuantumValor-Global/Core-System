import * as anchor from "@coral-xyz/anchor";
import { Program, AnchorProvider, utils, BN } from "@coral-xyz/anchor";
import {
  PublicKey,
  Keypair,
  Connection,
  AccountInfo,
  Transaction,
  sendAndConfirmTransaction,
} from "@solana/web3.js";
import {
  TOKEN_PROGRAM_ID,
  createMint,
  createAccount,
  mintTo,
} from "@solana/spl-token";
import * as crypto from "crypto";

// ============================================
// VLT CLIENT - TypeScript Integration
// ============================================

export class VLTClient {
  program: Program;
  provider: AnchorProvider;
  vltMint: PublicKey;
  vltConfig: PublicKey;

  constructor(
    program: Program,
    vltMint: PublicKey,
    vltConfig: PublicKey
  ) {
    this.program = program;
    this.provider = program.provider as AnchorProvider;
    this.vltMint = vltMint;
    this.vltConfig = vltConfig;
  }

  /**
   * Inicializa el sistema VLT
   */
  async initialize(
    lithiumBackingUsd: number,
    maxSupply: number
  ): Promise<string> {
    try {
      const authority = (this.provider.wallet as any).publicKey;

      // Crear mint de VLT
      const vltMint = await createMint(
        this.provider.connection,
        (this.provider.wallet as any).payer,
        authority,
        null,
        6 // 6 decimales para VLT
      );

      this.vltMint = vltMint;

      // Obtener/crear PDA para vlt_config
      const [vltConfigPda] = PublicKey.findProgramAddressSync(
        [Buffer.from("vlt_config")],
        this.program.programId
      );

      const tx = await this.program.methods
        .initializeVltSystem(
          new BN(lithiumBackingUsd),
          new BN(maxSupply)
        )
        .accounts({
          authority,
          vltConfig: vltConfigPda,
          vltMint,
          tokenProgram: TOKEN_PROGRAM_ID,
          systemProgram: anchor.web3.SystemProgram.programId,
          rent: anchor.web3.SYSVAR_RENT_PUBKEY,
        })
        .rpc();

      this.vltConfig = vltConfigPda;

      console.log("✓ VLT System initialized");
      console.log(`  Tx: ${tx}`);
      console.log(`  Mint: ${vltMint.toString()}`);

      return tx;
    } catch (error) {
      console.error("Initialization error:", error);
      throw error;
    }
  }

  /**
   * Emite VLT respaldado por prueba de litio
   */
  async emitVLT(
    amount: number,
    lithiumProofHash: string
  ): Promise<string> {
    try {
      const authority = (this.provider.wallet as any).publicKey;

      // Crear o obtener token account del authority
      const tokenAccount = await createAccount(
        this.provider.connection,
        (this.provider.wallet as any).payer,
        this.vltMint,
        authority
      );

      // Convertir hash a array de bytes
      const hashBytes = new Uint8Array(32);
      const hashHex = lithiumProofHash.replace("0x", "");
      for (let i = 0; i < 32; i++) {
        hashBytes[i] = parseInt(hashHex.substr(i * 2, 2), 16);
      }

      const tx = await this.program.methods
        .emitVltBacked(
          new BN(amount * 1_000_000), // Convertir a lamports (6 decimales)
          Array.from(hashBytes)
        )
        .accounts({
          authority,
          vltConfig: this.vltConfig,
          vltMint: this.vltMint,
          tokenAccount,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .rpc();

      console.log("✓ VLT Emission executed");
      console.log(`  Amount: ${amount} VLT`);
      console.log(`  Proof Hash: ${lithiumProofHash}`);
      console.log(`  Tx: ${tx}`);

      return tx;
    } catch (error) {
      console.error("Emission error:", error);
      throw error;
    }
  }

  /**
   * Transfiere VLT entre cuentas
   */
  async transferVLT(
    toOwner: PublicKey,
    amount: number
  ): Promise<string> {
    try {
      const fromOwner = (this.provider.wallet as any).publicKey;

      // Obtener token accounts
      const fromTokenAccount = await this.provider.connection.getTokenAccountsByOwner(
        fromOwner,
        { mint: this.vltMint }
      );

      const toTokenAccounts = await this.provider.connection.getTokenAccountsByOwner(
        toOwner,
        { mint: this.vltMint }
      );

      if (fromTokenAccount.value.length === 0 || toTokenAccounts.value.length === 0) {
        throw new Error("Token account not found");
      }

      const tx = await this.program.methods
        .transferVlt(new BN(amount * 1_000_000))
        .accounts({
          owner: fromOwner,
          fromTokenAccount: fromTokenAccount.value[0].pubkey,
          toTokenAccount: toTokenAccounts.value[0].pubkey,
          toOwner,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .rpc();

      console.log("✓ VLT Transfer executed");
      console.log(`  To: ${toOwner.toString()}`);
      console.log(`  Amount: ${amount} VLT`);
      console.log(`  Tx: ${tx}`);

      return tx;
    } catch (error) {
      console.error("Transfer error:", error);
      throw error;
    }
  }

  /**
   * Quema VLT y canjea por litio
   */
  async burnVLTForLithium(amount: number): Promise<string> {
    try {
      const owner = (this.provider.wallet as any).publicKey;

      const tokenAccounts = await this.provider.connection.getTokenAccountsByOwner(
        owner,
        { mint: this.vltMint }
      );

      if (tokenAccounts.value.length === 0) {
        throw new Error("Token account not found");
      }

      const tx = await this.program.methods
        .burnVltForLithium(new BN(amount * 1_000_000))
        .accounts({
          owner,
          vltConfig: this.vltConfig,
          vltMint: this.vltMint,
          tokenAccount: tokenAccounts.value[0].pubkey,
          tokenProgram: TOKEN_PROGRAM_ID,
        })
        .rpc();

      console.log("✓ VLT Burned & Lithium Redeemed");
      console.log(`  Amount: ${amount} VLT`);
      console.log(`  Tx: ${tx}`);

      return tx;
    } catch (error) {
      console.error("Burn error:", error);
      throw error;
    }
  }

  /**
   * Obtiene información del estado actual
   */
  async getSystemStatus(): Promise<any> {
    try {
      const config = await this.program.account.vltConfig.fetch(
        this.vltConfig
      );

      return {
        authority: config.authority.toString(),
        lithiumBacking: config.lithiumBacking.toNumber(),
        maxSupply: config.maxSupply.toNumber(),
        currentSupply: config.currentSupply.toNumber(),
        reserveRatio: config.reserveRatio,
        isActive: config.isActive,
      };
    } catch (error) {
      console.error("Status fetch error:", error);
      throw error;
    }
  }

  /**
   * Genera hash SHA256 de prueba de litio
   */
  static generateLithiumProofHash(
    location: string,
    weight: number,
    timestamp: number
  ): string {
    const data = `${location}:${weight}:${timestamp}`;
    const hash = crypto.createHash("sha256").update(data).digest("hex");
    return `0x${hash}`;
  }
}

// ============================================
// EXAMPLE USAGE
// ============================================

export async function exampleUsage() {
  // Conexión a Solana (usar testnet para desarrollo)
  const connection = new Connection("https://api.devnet.solana.com");
  const wallet = new Keypair(); // En producción, usar wallet real

  const provider = new AnchorProvider(
    connection,
    {
      publicKey: wallet.publicKey,
      signTransaction: async (tx: Transaction) => {
        tx.sign(wallet);
        return tx;
      },
      signAllTransactions: async (txs: Transaction[]) => {
        txs.forEach((tx) => tx.sign(wallet));
        return txs;
      },
    },
    { commitment: "finalized" }
  );

  // En una aplicación real, cargar el IDL del programa
  const program = new Program(IDL, PROGRAM_ID, provider);

  // Crear cliente VLT
  const vltClient = new VLTClient(program, new PublicKey(""), new PublicKey(""));

  // 1. Inicializar sistema
  console.log("\n=== Initializing VLT System ===");
  await vltClient.initialize(
    1_000_000_000, // $1 billón de respaldo en litio
    1_000_000_000 // 1 billón de suministro máximo
  );

  // 2. Emitir VLT
  console.log("\n=== Emitting VLT ===");
  const proofHash = VLTClient.generateLithiumProofHash(
    "Atacama-SQM-Mine-001",
    50_000, // 50,000 toneladas de litio
    Math.floor(Date.now() / 1000)
  );

  await vltClient.emitVLT(1_000_000, proofHash);

  // 3. Obtener estado
  console.log("\n=== System Status ===");
  const status = await vltClient.getSystemStatus();
  console.log(status);

  // 4. Transferir VLT
  console.log("\n=== Transferring VLT ===");
  const recipientKey = new PublicKey(
    "11111111111111111111111111111111"
  );
  await vltClient.transferVLT(recipientKey, 1000);

  // 5. Quemar VLT
  console.log("\n=== Burning VLT ===");
  await vltClient.burnVLTForLithium(100);
}

// IDL (copiar desde el contrato compilado)
const IDL = {
  version: "0.1.0",
  name: "vlt_emission",
  // ... resto del IDL
};

// Program ID (actualizar con el ID real después del despliegue)
const PROGRAM_ID = new PublicKey(
  "VLT1111111111111111111111111111111111111111"
);
