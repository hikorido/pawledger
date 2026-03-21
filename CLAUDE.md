# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**PawLedger** — a Web3 DApp on Avalanche C-Chain for transparent animal rescue funding. Built for the HerSolidity Mini Hackathon 2025 (赛道1 Life & Co-existence + 赛道3 Avalanche Ecosystem).

## Repository Layout

```
projects/pawledger/
  src/
    contracts/          # Hardhat project (Solidity)
      PawLedger.sol
      ReviewerMultisig.sol
      deploy.js
      hardhat.config.js
    ui/                 # React + Vite frontend
      src/
        pages/          # Home, CaseDetail, SubmitCase, MilestoneFeed
        components/     # CaseCard, ExpenseLedger, VotePanel, WalletConnect
        hooks/          # useContract.js, useWallet.js
      vite.config.js
      package.json
  docs/
    architecture.md
    demo-script.md
  README.md
```

## Commands

### Contracts (Hardhat)
```bash
cd src/contracts
npm install
npx hardhat compile
npx hardhat test
npx hardhat test --grep "function name"    # run a single test
npx hardhat run deploy.js --network fuji   # deploy to Avalanche Fuji testnet
```

### Frontend (React + Vite)
```bash
cd src/ui
npm install
npm run dev      # local dev server
npm run build
npm run preview
```

## Network Config

- **Testnet**: Avalanche Fuji (chainId `43113`)
- **RPC**: `https://api.avax-test.network/ext/bc/C/rpc`
- **Faucet**: `faucet.avax.network`
- **Native currency**: AVAX (no ERC-20 needed for MVP)

Environment: create `src/contracts/.env` with `PRIVATE_KEY=<deployer_wallet_key>`. After deploy, copy the contract address into `src/ui/src/config.js`.

## Smart Contract Architecture

`PawLedger.sol` is a milestone-locked escrow contract. Key state:
- `Case` struct: rescuer, ipfsMetadata, goalAmount, raisedAmount, deadline, status (`PENDING | ACTIVE | CLOSED | REFUNDED`), milestonesCount
- `Milestone` struct: evidenceIPFS, description, requestAmount, approveVotes, rejectVotes, released

**Voting**: vote weight ∝ donation proportion (not 1-wallet-1-vote). Release triggers at >50% approval; milestone is blocked if >30% rejects within 48h.

`ReviewerMultisig.sol`: fixed 3-of-5 multisig set at deploy time; approves cases from PENDING → ACTIVE.

## Frontend Architecture

- **Framework**: React (Vite)
- **Web3**: Ethers.js v6
- **Styling**: Tailwind CSS
- **Wallet**: MetaMask / Core Wallet (Avalanche-native)
- **Storage**: IPFS (mock hash in MVP)

All contract interactions go through `hooks/useContract.js`. Wallet state lives in `hooks/useWallet.js`.

## Key UX Constraints

- Display Avalanche confirmation time in UI (target: ~0.8s) — this is a core demo talking point
- Expense ledger is a chronological on-chain timeline, not a database query
- Donor vote percentages must update live as votes arrive
- Mobile-friendly layout required

## Working Style

### 1. Plan Node Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

---

### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

---

### 3. Self-Improvement Loop
- After ANY correction from the user: update `tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

---

### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

---

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer
- Challenge your own work before presenting it

---

### 6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests - then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

---

## Task Management
1. **Plan First**: Write plan to `tasks/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `tasks/todo.md`
6. **Capture Lessons**: Update `tasks/lessons.md` after corrections

---

## Core Principles
- **Simplicity First**: Make every change as simple as possible. Impact minimal code
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards

## Language
- **Frontend**: Must support both Chinese (zh) and English (en) — all UI text should be bilingual; Chinese is the default language
- **Documents**: Before writing any README or other documentation, ask the user which language to use
