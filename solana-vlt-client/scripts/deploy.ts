import * as anchor from "@coral-xyz/anchor";
import { PublicKey } from "@solana/web3.js";
import { IDL } from "../src/idl/vlt_emission.json";
import { PROGRAM_ID } from "../src/config/constants";

async function main() {
  const provider = anchor.AnchorProvider.local();
  anchor.setProvider(provider);

  const program = new anchor.Program(IDL, PROGRAM_ID, provider);

  console.log("Deploying the VLT program...");

  const tx = await program.rpc.initialize({
    accounts: {
      authority: provider.wallet.publicKey,
      // Add other necessary accounts here
    },
  });

  console.log("Program deployed successfully!");
  console.log(`Transaction ID: ${tx}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });