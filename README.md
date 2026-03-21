# 爪爪筹 · PawLedger

> 透明、可信的动物救助众筹平台 · Transparent animal rescue crowdfunding on-chain

**HerSolidity Mini Hackathon 2025** — 赛道1 生命与共存 + 赛道3 Avalanche 生态

---

## 简介 · About

爪爪筹是一个部署在 Avalanche C-Chain 上的 Web3 DApp。通过智能合约里程碑锁仓 + 捐助者投票机制，让每一笔捐款可追溯、每一次拨款有投票，彻底解决传统动物救助筹款中的信任问题。

PawLedger is a Web3 DApp on Avalanche C-Chain. Milestone-locked escrow + donor voting makes every donation traceable and every disbursement accountable.

---

## 用户角色 · User Roles

| 角色 | 说明 |
|------|------|
| 🐾 **救助者 (Rescuer)** | 提交救助申请 → 等待审核 → 公开募捐 → 按里程碑提取资金 |
| 💙 **捐助者 (Donor)** | 浏览案例 → 捐款 AVAX → 对里程碑投票 → 累计达标可晋升审核者 |
| ✅ **审核者 (Reviewer)** | 由捐助者晋升，审核新案例，获得 $PAW 代币奖励 |

审核者由捐助者自愿晋升（累计捐款 ≥ 0.1 AVAX），产品 Owner 为初始审核者，随平台生长动态扩容审核池。

---

## 核心机制 · Key Mechanics

- **里程碑锁仓** — 资金按阶段释放，救助者提交证明后触发投票
- **权重投票** — 投票权重与捐款比例挂钩，防 Sybil 攻击
- **动态审核池** — 捐助者晋升审核者，审核案例获 $PAW 奖励
- **$PAW 代币** — ERC-20 治理代币，审核行为的链上激励
- **自动退款** — 截止日期未达标则资金按比例退回捐款人

---

## 技术栈 · Stack

| Layer | Tech |
|-------|------|
| Blockchain | Avalanche Fuji Testnet (C-Chain) |
| Smart Contracts | Solidity + Hardhat |
| Frontend | React + Vite + Tailwind CSS |
| Web3 | Ethers.js v6 |
| Storage | IPFS (mock in MVP) |
| i18n | 中文默认，支持英文切换 |

---

## 快速开始 · Quick Start

### 合约 · Contracts
```bash
cd projects/pawledger/src/contracts
npm install
npx hardhat compile
npx hardhat test
npx hardhat run scripts/deploy.js --network fuji
```

### 前端 · Frontend
```bash
cd projects/pawledger/src/ui
npm install
npm run dev
```

---

## 合约架构 · Contract Architecture

| 合约 | 用途 |
|---|---|
| `PawLedger.sol` | 核心托管合约：案例、捐款、里程碑、审核逻辑 |
| `PawToken.sol` | $PAW ERC-20 治理代币，由 PawLedger 合约铸造 |

---

## 网络配置 · Network

- Testnet: Avalanche Fuji (`chainId: 43113`)
- RPC: `https://api.avax-test.network/ext/bc/C/rpc`
- Faucet: `faucet.avax.network`
- Native currency: AVAX

---

## 文档 · Docs

- [`docs/prd.md`](projects/pawledger/docs/prd.md) — 完整产品需求文档
- [`docs/architecture.md`](projects/pawledger/docs/architecture.md) — 技术架构详解
- [`docs/demo-script.md`](projects/pawledger/docs/demo-script.md) — 演示脚本
