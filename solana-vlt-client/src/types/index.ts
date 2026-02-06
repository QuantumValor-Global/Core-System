export interface VLTConfig {
  authority: string;
  lithiumBacking: number;
  maxSupply: number;
  currentSupply: number;
  reserveRatio: number;
  isActive: boolean;
}

export interface TokenAccount {
  pubkey: string;
  amount: number;
}

export interface TransactionResponse {
  tx: string;
  status: string;
}

export interface EmitVLTParams {
  amount: number;
  lithiumProofHash: string;
}

export interface TransferVLTParams {
  toOwner: string;
  amount: number;
}

export interface BurnVLTParams {
  amount: number;
}

export interface SystemStatus {
  authority: string;
  lithiumBacking: number;
  maxSupply: number;
  currentSupply: number;
  reserveRatio: number;
  isActive: boolean;
}