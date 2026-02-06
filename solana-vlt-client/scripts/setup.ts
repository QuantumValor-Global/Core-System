import { Keypair, Connection } from "@solana/web3.js";
import { TOKEN_PROGRAM_ID, createAccount } from "@solana/spl-token";
import * as anchor from "@coral-xyz/anchor";
import { VLTClient } from "../src/client";
import { PROGRAM_ID } from "../src/config/constants";

async function setup() {
  // Conexión a Solana (usar testnet para desarrollo)
  const connection = new Connection("https://api.devnet.solana.com");
  const wallet = Keypair.generate(); // Generar una nueva clave para el wallet

  // Crear el cliente VLT
  const provider = new anchor.AnchorProvider(
    connection,
    {
      publicKey: wallet.publicKey,
      signTransaction: async (tx) => {
        tx.sign(wallet);
        return tx;
      },
      signAllTransactions: async (txs) => {
        txs.forEach((tx) => tx.sign(wallet));
        return txs;
      },
    },
    { commitment: "finalized" }
  );

  const vltClient = new VLTClient(new anchor.Program(IDL, PROGRAM_ID, provider), new PublicKey(""), new PublicKey(""));

  // Crear cuenta de token para el wallet
  const tokenAccount = await createAccount(
    connection,
    wallet,
    vltClient.vltMint,
    wallet.publicKey
  );

  console.log("Setup complete");
  console.log(`Wallet Public Key: ${wallet.publicKey.toString()}`);
  console.log(`Token Account: ${tokenAccount.toString()}`);
}

setup().catch((error) => {
  console.error("Setup error:", error);
});