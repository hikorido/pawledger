# PawLedger — TODO

> Ordered by dependency. Nothing in a later phase depends on an earlier phase being incomplete.
> Status key: `[ ]` not started · `[x]` done

---

## Phase 1: Smart Contracts

### 1.1 PawToken.sol
- [x] Inherit OpenZeppelin `ERC20`
- [x] Add `address public minter` state variable
- [x] `constructor(address _owner)` — set owner, no initial supply
- [x] `setMinter(address)` — `onlyOwner`, callable once, sets minter
- [x] `mint(address, uint256)` — `onlyMinter`

### 1.2 PawToken Tests (`test/PawToken.test.js`)
- [x] Deploy and verify name/symbol/decimals
- [x] `setMinter` works for owner, reverts for non-owner
- [x] `mint` works for minter, reverts for non-minter
- [x] Double-`setMinter` reverts

### 1.3 PawLedger.sol — Data Structures
- [x] `CaseStatus` enum: `PENDING | ACTIVE | CLOSED | REFUNDED`
- [x] `MilestoneStatus` enum: `PENDING | APPROVED | REJECTED`
- [x] `Case` struct (rescuer, ipfsMetadata, goalAmount, raisedAmount, deadline, status, milestoneCount, approvalCount)
- [x] `Milestone` struct (evidenceIPFS, description, requestAmount, approveWeight, rejectWeight, submittedAt, status, fundsReleased)
- [x] Mappings: `isReviewer`, `totalDonated`, `donations[caseId][donor]`, `hasVoted[caseId][milestoneIdx][donor]`, `hasReviewed[caseId][reviewer]`
- [x] State vars: `pawToken`, `reviewerThreshold`, `requiredApprovals`, `cases[]`, `milestones[caseId][]`

### 1.4 PawLedger.sol — Constructor & Owner Functions
- [x] `constructor(address pawTokenAddr, uint256 threshold, uint256 approvals)` — stores config, registers deployer as first reviewer
- [x] `updateRequiredApprovals(uint256)` — `onlyOwner`
- [x] `updateReviewerThreshold(uint256)` — `onlyOwner`

### 1.5 PawLedger.sol — Core Functions
- [ ] `submitCase(string ipfs, uint256 goal, uint256 durationDays, uint256 milestoneCount)` — creates PENDING case
- [ ] `reviewCase(uint256 caseId, bool approve)` — reviewer only; mints 10 PAW; activates when approvalCount >= requiredApprovals; `hasReviewed` guard
- [ ] `donate(uint256 caseId)` — payable; ACTIVE cases only; updates `donations` + `totalDonated`
- [ ] `becomeReviewer()` — requires `totalDonated >= reviewerThreshold`; sets `isReviewer`
- [ ] `submitMilestone(uint256 caseId, uint256 idx, string ipfs, string desc, uint256 amount)` — rescuer only; ACTIVE case; sets milestone PENDING
- [ ] `voteMilestone(uint256 caseId, uint256 idx, bool approve)` — donor only; `hasVoted` guard; updates weights; auto-approve at >50%; auto-reject at >30% within 48h
- [ ] `withdrawMilestone(uint256 caseId, uint256 idx)` — rescuer only; APPROVED + not released; transfers funds; marks `fundsReleased`
- [ ] `claimRefund(uint256 caseId)` — donor; deadline passed + case not CLOSED; proportional refund; marks case REFUNDED

### 1.6 PawLedger Tests (`test/PawLedger.test.js`)
- [ ] Deploy both contracts and call `setMinter`
- [ ] `submitCase` creates PENDING case with correct fields
- [ ] `reviewCase`: approve activates case when threshold met; mints PAW; double-review reverts
- [ ] `donate`: records donation; reverts on non-ACTIVE case
- [ ] `becomeReviewer`: works at threshold; reverts below threshold
- [ ] `submitMilestone`: rescuer submits; non-rescuer reverts
- [ ] `voteMilestone`: weight-based vote; auto-approve >50%; auto-reject >30% within 48h; `hasVoted` guard
- [ ] `withdrawMilestone`: releases funds to rescuer; double-withdraw reverts
- [ ] `claimRefund`: refunds proportionally after deadline; reverts before deadline
- [ ] `updateRequiredApprovals` / `updateReviewerThreshold`: owner succeeds; non-owner reverts

### 1.7 Deploy Script (`deploy.js`)
- [ ] Deploy `PawToken(deployer)`
- [ ] Deploy `PawLedger(pawTokenAddr, 0.1 ether, 1)`
- [ ] Call `pawToken.setMinter(pawLedgerAddr)`
- [ ] Print both contract addresses
- [ ] Verify deploys work: `npx hardhat run deploy.js --network fuji`

---

## Phase 2: Frontend Scaffold

> Prerequisite: Phase 1 contracts compiled (ABI needed for config.js)

- [x] Vite + React + Tailwind CSS project initialized
- [x] `App.jsx` routing skeleton (react-router-dom)
- [x] `locales/zh.json` + `locales/en.json` skeleton files
- [x] `useLocale` hook + `LocaleContext`
- [ ] Copy deployed contract addresses into `src/ui/src/config.js`
- [ ] Copy contract ABIs into `src/ui/src/config.js` (or separate `abis/` files)
- [ ] Confirm `npm run dev` boots without errors

---

## Phase 3: Web3 Hooks

> Prerequisite: Phase 2 scaffold running, config.js has addresses + ABIs

- [ ] **`useWallet`** — connect MetaMask/Core, read `account` + `chainId`, auto-switch to Fuji (chainId 43113), expose `connect()` / `disconnect()`
- [ ] **`useContract`** — return `pawLedger` + `pawToken` ethers v6 `Contract` instances (signer when connected, provider otherwise)
- [ ] **`useCases`** — `getCases()` fetch all cases; `getCase(id)` single case; loading/error state
- [ ] **`useMilestones`** — `getMilestones(caseId)`; `submitMilestone()`; `voteMilestone()`; `withdrawMilestone()`
- [ ] **`useReviewer`** — `isReviewer` bool; `pendingCases` list; `reviewCase(id, approve)`
- [ ] **`useDonor`** — `donate(caseId, amount)`; `claimRefund(caseId)`; `donationsByCase`
- [ ] **`useUserRole`** — derives role: `reviewer` > `donor` > `rescuer` > `visitor` based on wallet state
- [ ] Unit-smoke-test each hook against a local Hardhat node

---

## Phase 4: Public Pages

> Prerequisite: Phase 3 hooks working

- [ ] **`WalletConnect`** component — button + address display + network badge
- [ ] **`Navbar`** — role-aware links, language toggle, wallet button
- [ ] **`Footer`** — static
- [ ] **`RoleIndicator`** — shows current role badge
- [ ] **`LanguageToggle`** — zh ↔ en switch wired to `useLocale`
- [ ] **`StatusBadge`** — PENDING / ACTIVE / CLOSED / REFUNDED colors
- [ ] **`FundingProgress`** — progress bar (raisedAmount / goalAmount)
- [ ] **`CaseCard`** — thumbnail, title, progress bar, deadline, status badge
- [ ] **`Home`** page — platform stats (total cases, total raised), featured active cases grid, CTA buttons
- [ ] **`CaseBrowser`** page — filter by status, paginated CaseCard grid
- [ ] **`CaseDetail`** page — full case info, donate button, milestone timeline, expense ledger

---

## Phase 5: Rescuer Flow

> Prerequisite: Phase 4 public pages, `useCases` + `useMilestones` hooks

- [ ] **`SubmitCase`** page — form: title, description, IPFS image (mock CID in MVP), goal amount, duration days, milestone count; calls `submitCase()`; shows TxConfirmation
- [ ] **`RescuerDashboard`** page — list my cases by status; per-case: submit milestone form, withdraw button for approved milestones; pending milestone status display

---

## Phase 6: Donor Flow

> Prerequisite: Phase 4 public pages, `useDonor` hook

- [ ] **`DonateModal`** — amount input, AVAX balance display, confirm button; shows TxConfirmation with Avalanche speed timer
- [ ] **`DonorDashboard`** page — my donations list; pending votes per milestone; "Become Reviewer" button (visible when threshold met)

---

## Phase 7: Reviewer Flow

> Prerequisite: Phase 3 `useReviewer` hook, common components

- [ ] **`ReviewCard`** component — case summary, approve/reject buttons, PAW reward note
- [ ] **`ReviewerDashboard`** page — pending cases queue (ReviewCard list); reviewed history; $PAW balance display

---

## Phase 8: Milestone UX

> Prerequisite: Phase 5 rescuer + Phase 6 donor flows complete

- [ ] **`MilestoneTimeline`** — chronological list of milestone events (submitted, voted, approved/rejected, withdrawn); event-driven from on-chain logs
- [ ] **`VotePanel`** — vote buttons (approve/reject); live approve% / reject% bars that update with each vote; disable if already voted or milestone resolved
- [ ] **`ExpenseLedger`** — timeline of on-chain `Donation` + `MilestoneWithdrawn` events for a case; no table, event-list style

---

## Phase 9: i18n — Bilingual Strings

> Prerequisite: All pages exist (Phases 4–8)

- [ ] Audit all hardcoded strings in every component and page
- [ ] Add every string key to `locales/zh.json` (Chinese, default)
- [ ] Add corresponding keys to `locales/en.json` (English)
- [ ] Replace all hardcoded strings with `t('key')` calls
- [ ] Verify language toggle works on every page without missing-key fallbacks

---

## Phase 10: Polish & Demo Prep

> Prerequisite: All flows functional (Phases 4–8) and bilingual (Phase 9)

- [ ] **`TxConfirmation`** component — start timer on tx submit, stop on `receipt`, display "Confirmed in X.Xs"; target ≈0.8s on Fuji
- [ ] Mobile responsive audit — all pages usable on 375px viewport
- [ ] End-to-end manual test: submit case → review → donate → submit milestone → vote → withdraw
- [ ] End-to-end refund path: donate → deadline passes → claimRefund
- [ ] `npx hardhat test` — all tests green
- [ ] `npm run build` — no build errors
- [ ] Deploy to Fuji, update `config.js` with live addresses
- [ ] Demo script: walk through all three roles in sequence

---

## Acceptance Checklist

- [ ] `npx hardhat test` passes (all contracts)
- [ ] `npm run dev` starts; wallet connects to Fuji
- [ ] Full E2E flow works on Fuji testnet
- [ ] Language toggle works on all pages
- [ ] Mobile layout correct on all pages
- [ ] Avalanche confirmation speed displayed in UI
