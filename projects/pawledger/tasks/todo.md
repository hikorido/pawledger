# PawLedger — Task List

## Phase 1: Contracts
- [x] PawToken.sol — ERC-20 with single minter
- [x] PawToken tests — 11/11 passing
- [x] PawLedger.sol — core escrow
- [x] PawLedger tests — 43/43 passing
- [x] deploy.js — PawToken → PawLedger → setMinter

## Phase 2: Frontend Scaffold
- [x] Vite + Tailwind + React project structure
- [x] Routing skeleton (App.jsx)
- [x] i18n skeleton (locales + useLocale)
- [x] useWallet hook
- [x] useContract hook

## Phase 3: Public Flows
- [x] Home page
- [x] CaseBrowser page
- [x] CaseDetail page

## Phase 4: Rescuer Flow
- [x] SubmitCase page
- [x] RescuerDashboard page

## Phase 5: Donor Flow
- [x] DonateModal
- [x] DonorDashboard page

## Phase 6: Reviewer Flow
- [x] ReviewerDashboard page

## Phase 7: Milestone UX
- [x] MilestoneTimeline
- [x] VotePanel
- [x] ExpenseLedger (on-chain event timeline)

## Phase 7b: Hooks (wiring)
- [x] useMilestones — submitMilestone, voteMilestone, withdrawMilestone, getMilestone
- [x] useReviewer — reviewCase, $PAW balance
- [x] useDonor — donate, claimRefund, becomeReviewer

## Phase 7c: Components (wiring)
- [x] ReviewCard
- [x] TxConfirmation (Avalanche speed timer)

## Phase 8: Integration & Polish
- [x] Integration tests — 7/7 passing (61 total)
- [x] Mismatches audited: re-submission not supported in contract (documented in test E)
- [ ] Full bilingual strings audit
- [ ] Mobile responsive check
- [ ] Deploy to Fuji via REMIX, fill config.js addresses
- [ ] Demo prep

## Issues Found & Resolved
- Contract source was in `contracts/contracts/` (Hardhat source dir), not root — stubs at root were dead files
- ABI files pre-generated from the working implementation — still valid
- Re-submission of rejected milestones not supported by contract (PRD mentions it, contract uses sequential-only approach)
- useCases.js calls `getCasesCount()` which IS in the contract ABI — no fix needed
