# 爪爪筹 · PawLedger

> 透明、可信的动物救助众筹平台 · Transparent animal rescue crowdfunding on-chain

**HerSolidity Mini Hackathon 2025** — 赛道1 生命与共存 + 赛道3 Avalanche 生态

---

## 简介 · About

爪爪筹是一个部署在 Avalanche C-Chain 上的 Web3 DApp，通过智能合约里程碑锁定资金，让每一笔捐款可追溯、每一次拨款有投票。

PawLedger is a Web3 DApp on Avalanche C-Chain. Funds are locked in milestone-based escrow contracts, so every donation is traceable and every disbursement is voted on by donors.

---

## 技术栈 · Stack

| Layer | Tech |
|-------|------|
| Blockchain | Avalanche Fuji Testnet (C-Chain) |
| Smart Contracts | Solidity + Hardhat |
| Frontend | React + Vite + Tailwind CSS |
| Web3 | Ethers.js v6 |
| Storage | IPFS (mock in MVP) |

---

## 快速开始 · Quick Start

### 合约 · Contracts
```bash
cd projects/pawledger/src/contracts
npm install
npx hardhat compile
npx hardhat test
npx hardhat run deploy.js --network fuji
```

### 前端 · Frontend
```bash
cd projects/pawledger/src/ui
npm install
npm run dev
```

---

## 核心机制 · Key Mechanics

- **里程碑锁仓** — 资金按阶段释放，救助者提交证明后触发投票
- **权重投票** — 投票权重与捐款比例挂钩，非一钱一票
- **多签审核** — 3-of-5 多签委员会负责案例上链审批
- **自动退款** — 截止日期未达标则资金退回捐款人

---

## 网络配置 · Network

- Testnet: Avalanche Fuji (`chainId: 43113`)
- RPC: `https://api.avax-test.network/ext/bc/C/rpc`
- Faucet: `faucet.avax.network`
