import { VLTClient } from '../src/client';
import { PublicKey, Keypair, Connection } from '@solana/web3.js';
import { AnchorProvider, Program } from '@coral-xyz/anchor';
import { TOKEN_PROGRAM_ID } from '@solana/spl-token';

describe('VLTClient', () => {
  let vltClient: VLTClient;
  let connection: Connection;
  let wallet: Keypair;
  let program: Program;
  const vltMint = new PublicKey('VLT1111111111111111111111111111111111111111');
  const vltConfig = new PublicKey('CONFIG111111111111111111111111111111111111111');

  beforeAll(async () => {
    connection = new Connection('https://api.devnet.solana.com');
    wallet = Keypair.generate();
    const provider = new AnchorProvider(connection, {
      publicKey: wallet.publicKey,
      signTransaction: async (tx) => {
        tx.sign(wallet);
        return tx;
      },
      signAllTransactions: async (txs) => {
        txs.forEach((tx) => tx.sign(wallet));
        return txs;
      },
    }, { commitment: 'finalized' });

    program = new Program({}, vltMint, provider); // Replace with actual IDL
    vltClient = new VLTClient(program, vltMint, vltConfig);
  });

  test('initialize VLT system', async () => {
    const tx = await vltClient.initialize(1_000_000_000, 1_000_000_000);
    expect(tx).toBeDefined();
  });

  test('emit VLT', async () => {
    const proofHash = VLTClient.generateLithiumProofHash('Atacama-SQM-Mine-001', 50_000, Math.floor(Date.now() / 1000));
    const tx = await vltClient.emitVLT(1_000_000, proofHash);
    expect(tx).toBeDefined();
  });

  test('transfer VLT', async () => {
    const recipientKey = Keypair.generate().publicKey;
    const tx = await vltClient.transferVLT(recipientKey, 1000);
    expect(tx).toBeDefined();
  });

  test('burn VLT for lithium', async () => {
    const tx = await vltClient.burnVLTForLithium(100);
    expect(tx).toBeDefined();
  });

  test('get system status', async () => {
    const status = await vltClient.getSystemStatus();
    expect(status).toHaveProperty('authority');
    expect(status).toHaveProperty('lithiumBacking');
    expect(status).toHaveProperty('maxSupply');
    expect(status).toHaveProperty('currentSupply');
    expect(status).toHaveProperty('reserveRatio');
    expect(status).toHaveProperty('isActive');
  });
});