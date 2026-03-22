# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**PawLedger** — a Web3 DApp on Avalanche C-Chain for transparent animal rescue funding. Built for the Pink HerSolidity Hackathon 2026 (赛道1 Life & Co-existence + 赛道3 Avalanche Ecosystem).

## Repository Layout

```
projects/pawledger/
  src/
    contracts/          # Hardhat project (Solidity)
      PawToken.sol      # ERC-20 governance token ($PAW), minted by PawLedger
      PawLedger.sol     # Core escrow: cases, donations, milestones, reviewer logic
      deploy.js         # Deployment script (PawToken → PawLedger → setMinter)
      hardhat.config.js
    ui/                 # React + Vite frontend
      src/
        pages/
          Home.jsx
          CaseBrowser.jsx
          CaseDetail.jsx
          SubmitCase.jsx
          RescuerDashboard.jsx
          DonorDashboard.jsx
          ReviewerDashboard.jsx
        components/
          layout/       # Navbar, Footer, RoleIndicator, LanguageToggle
          case/         # CaseCard, FundingProgress, StatusBadge
          milestone/    # MilestoneTimeline, VotePanel, ExpenseLedger
          modals/       # DonateModal, TxConfirmation
          review/       # ReviewCard
          wallet/       # WalletConnect
          common/       # Button, Card, Input, Modal, Loading
        hooks/
          useWallet.js
          useContract.js
          useCases.js
          useMilestones.js
          useReviewer.js
          useDonor.js
          useUserRole.js
          useLocale.js
        locales/
          zh.json       # Chinese (default)
          en.json       # English
        config.js       # Contract addresses, network config
      vite.config.js
      package.json
  docs/
    prd.md
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
- **Native currency**: AVAX (for donations/escrow)
- **Governance token**: $PAW (ERC-20, minted by PawLedger for reviewer rewards)

Environment: create `src/contracts/.env` with `PRIVATE_KEY=<deployer_wallet_key>`. After deploy, copy both contract addresses into `src/ui/src/config.js`.

## Smart Contract Architecture

Two contracts (v2 — `ReviewerMultisig.sol` is **deprecated and removed**):

### PawToken.sol
- ERC-20, name: PawToken, symbol: $PAW, decimals: 18
- Single minter address (set to PawLedger after deploy via `setMinter`)
- `mint(address, uint256)` callable only by minter

### PawLedger.sol
Core escrow. Key structs:
- `Case`: rescuer, ipfsMetadata, goalAmount, raisedAmount, deadline, status (`PENDING|ACTIVE|CLOSED|REFUNDED`), milestoneCount, approvalCount
- `Milestone`: evidenceIPFS, description, requestAmount, approveWeight, rejectWeight, submittedAt, status (`PENDING|APPROVED|REJECTED`), fundsReleased

Key mappings: `isReviewer`, `totalDonated`, `donations[caseId][donor]`, `hasVoted[caseId][milestoneIdx][donor]`, `hasReviewed[caseId][reviewer]`

Key functions: `submitCase`, `reviewCase`, `donate`, `becomeReviewer`, `submitMilestone`, `voteMilestone`, `withdrawMilestone`, `claimRefund`

**Reviewer system**: deployer is auto-registered as first reviewer; any donor with `totalDonated >= reviewerThreshold` (default 0.1 AVAX) can call `becomeReviewer()`; each review mints 10 $PAW

**Voting**: weight = `donations[caseId][voter] / raisedAmount`. Release at >50% approve; blocked if >30% reject within 48h of submission

**Deployment order**:
1. Deploy `PawToken(deployer)`
2. Deploy `PawLedger(pawTokenAddr, 0.1 ether, 1)` — deployer auto-becomes first reviewer
3. Call `pawToken.setMinter(pawLedgerAddr)`

## Frontend Architecture

### Tech Stack
- **Framework**: React + Vite
- **Styling**: Tailwind CSS
- **Web3**: Ethers.js v6
- **Wallet**: MetaMask / Core Wallet (Avalanche-native)
- **Storage**: IPFS (mock CID in MVP)
- **i18n**: custom `LocaleContext` + `useLocale()` hook; `locales/zh.json` (default) + `locales/en.json`

### Routes & Role Separation
| Path | Page | Roles |
|---|---|---|
| `/` | Home | all |
| `/cases` | CaseBrowser | all |
| `/case/:id` | CaseDetail | all |
| `/submit` | SubmitCase | rescuer |
| `/dashboard/rescuer` | RescuerDashboard | rescuer |
| `/dashboard/donor` | DonorDashboard | donor |
| `/dashboard/reviewer` | ReviewerDashboard | reviewer |

### Hook Responsibilities
- `useWallet` — wallet connection, Fuji network switch
- `useContract` — ethers Contract instances for PawLedger + PawToken
- `useCases` — case list and detail queries
- `useMilestones` — milestone read/write/vote
- `useReviewer` — reviewer status, pending queue, review actions
- `useDonor` — donate, refund
- `useUserRole` — derives current wallet role (rescuer / donor / reviewer)
- `useLocale` — current lang, toggle, `t(key)` translation

### Key UX Rules
- **Avalanche speed**: `TxConfirmation` component measures and displays "Confirmed in X.Xs" — core demo talking point (target ~0.8s)
- **ExpenseLedger**: chronological on-chain event timeline, not a table/query
- **VotePanel**: live vote percentage updates with each new vote
- **Mobile**: all pages must be responsive
- **Bilingual**: default Chinese; English toggle in top-right; every UI string goes through `t(key)`

## Build Order

1. `PawToken.sol` + tests
2. `PawLedger.sol` + tests
3. Deploy script (`PawToken` → `PawLedger` → `setMinter`)
4. Frontend scaffold (Vite + Tailwind + routing + wallet + i18n skeleton)
5. `useContract`, `useWallet` hooks
6. Home + CaseBrowser + CaseDetail (public flows)
7. SubmitCase + RescuerDashboard (rescuer flow)
8. DonateModal + DonorDashboard (donor flow)
9. ReviewerDashboard (reviewer flow)
10. MilestoneTimeline + VotePanel (milestone voting UX)
11. Polish: TxConfirmation timer, bilingual strings, mobile responsive, demo prep

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

## Standing Rules (always follow these, every task, no exceptions)

After completing every single task:
1. Update TODO.md — mark the completed task as checked, add any newly discovered sub-tasks
2. Stage and commit — git add only the files changed in this task, then git commit with a clear message in this format: `[phase] short description of what was done`
3. State what you just committed and what the next task is before stopping

Never batch multiple tasks into one commit.
Never skip the TODO update even if the task was small.
