import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { QuantumVlt } from "../target/types/quantum_vlt";

// Program ID sincronizado desde anchor build
const PROGRAM_ID = "VLT3QuantumValorLithiumBacking1111111111111";

async function main() {
  // Configuración del Proveedor (Conectando al Orden Mundial)
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.QuantumVlt as Program<QuantumVlt>;

  console.log("-----------------------------------------");
  console.log("SISTEMA QUANTUM-VALOR ACTIVADO");
  console.log("ARQUITECTO: INTO el 3");
  console.log("CONECTADO A LA RED: ", provider.connection.rpcEndpoint);
  console.log("-----------------------------------------");

  // Llamada al estado global de la Bóveda de Atacama
  try {
    const state = await program.account.globalState.all();
    console.log(
      "Reservas de Litio Verificadas:",
      state[0].account.lithiumReserve.toString(),
      "TN"
    );
  } catch (e) {
    console.log("⚠️ Bóveda aún no inicializada. Esperando comando de INTO el 3...");
  }
}

main();
