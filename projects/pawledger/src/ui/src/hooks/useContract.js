import React, { createContext, useContext, useMemo } from "react";
import { Contract, BrowserProvider } from "ethers";
import { CONTRACT_ADDRESSES } from "../config";
import PawLedgerABI from "../abis/PawLedger.json";
import PawTokenABI from "../abis/PawToken.json";
import { useWallet } from "./useWallet";

const ContractContext = createContext(null);

export function ContractProvider({ children }) {
  const { signer, provider } = useWallet();

  const contracts = useMemo(() => {
    const runner = signer ?? provider;
    if (!runner || !CONTRACT_ADDRESSES.PawLedger || !CONTRACT_ADDRESSES.PawToken) {
      return { pawLedger: null, pawToken: null };
    }
    return {
      pawLedger: new Contract(CONTRACT_ADDRESSES.PawLedger, PawLedgerABI, runner),
      pawToken: new Contract(CONTRACT_ADDRESSES.PawToken, PawTokenABI, runner),
    };
  }, [signer, provider]);

  return <ContractContext.Provider value={contracts}>{children}</ContractContext.Provider>;
}

export function useContract() {
  const ctx = useContext(ContractContext);
  if (!ctx) throw new Error("useContract must be used within ContractProvider");
  return ctx;
}
