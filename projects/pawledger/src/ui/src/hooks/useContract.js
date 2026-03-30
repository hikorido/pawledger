import React, { createContext, useContext, useMemo } from "react";
import { Contract, BrowserProvider } from "ethers";
import { CONTRACT_ADDRESSES } from "../config";
import PawLedgerABI from "../abis/PawLedger.json";
import PawTokenABI from "../abis/PawToken.json";
import PawAdoptionABI from "../abis/PawAdoption.json";
import { useWallet } from "./useWallet";

const ContractContext = createContext(null);

export function ContractProvider({ children }) {
  const { signer, provider } = useWallet();

  const contracts = useMemo(() => {
    const runner = signer ?? provider;
    if (
      !runner ||
      !CONTRACT_ADDRESSES.PawLedger ||
      !CONTRACT_ADDRESSES.PawToken ||
      !CONTRACT_ADDRESSES.PawAdoption
    ) {
      return { pawLedger: null, pawToken: null, pawAdoption: null };
    }
    return {
      pawLedger: new Contract(CONTRACT_ADDRESSES.PawLedger, PawLedgerABI, runner),
      pawToken: new Contract(CONTRACT_ADDRESSES.PawToken, PawTokenABI, runner),
      pawAdoption: new Contract(CONTRACT_ADDRESSES.PawAdoption, PawAdoptionABI, runner),
    };
  }, [signer, provider]);

  return <ContractContext.Provider value={contracts}>{children}</ContractContext.Provider>;
}

export function useContract() {
  const ctx = useContext(ContractContext);
  if (!ctx) throw new Error("useContract must be used within ContractProvider");
  return ctx;
}
