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
- [x] Full bilingual strings audit
- [x] Mobile responsive check
- [x] Deploy to Fuji via Hardhat, fill config.js addresses (PawToken: 0xd0C668c6A144c46823a412971E641aAd7eae2968, PawLedger: 0xf14aBf43A36500a2Cc10aEfC2d3F334f4c9ef1af)
- [x] Demo prep — added `docs/demo-runbook.md` with 2-wallet script, fallback paths, and verification checklist

## Phase 9: Image Upload
- [x] `ImageUpload` component — drag-and-drop, preview grid, 5 photos / 5MB each
- [x] `uploadToIPFS.js` utility — Pinata IPFS upload, reads `VITE_PINATA_JWT`
- [x] Wire image upload into SubmitCase — uploads CIDs, stores in case metadata
- [x] Bilingual locale strings for all upload states
- [x] Add `src/ui/.env.example` with `VITE_PINATA_JWT` template for setup onboarding
- [x] Align frontend upload limit/hints to 5MB each to match PRD/task spec
- [ ] **User action**: Create free Pinata account at pinata.cloud → get API JWT
- [ ] **User action**: Add `VITE_PINATA_JWT=<jwt>` to `projects/pawledger/src/ui/.env`
- [ ] Test end-to-end: upload photo → submit case → verify CID in contract metadata

## Phase 10: Deployment
- [x] `gh-pages` package installed, `build:gh` + `deploy` scripts added to package.json
- [x] `vite.config.js`: `VITE_BASE_PATH` support for GitHub Pages base path
- [x] `App.jsx`: `BrowserRouter` uses `import.meta.env.BASE_URL` as basename
- [x] `public/404.html` + `index.html` redirect script for SPA client-side routing on GH Pages
- [ ] **User action (GitHub Pages)**: run `npm run deploy` from `src/ui/` → then enable Pages in repo Settings → Source: `gh-pages` branch → URL: https://hikorido.github.io/pawledger/
- [ ] **User action (Vercel, easier)**: vercel.com → New Project → import `hikorido/pawledger` → root dir: `projects/pawledger/src/ui` → Deploy

## Phase 11: Documentation
- [x] Update root README.md — accurate contract names, deployed addresses, UUPS proxy details, corrected deploy path, Pinata env var, removed broken doc links

## Issues Found & Resolved
- Contract source was in `contracts/contracts/` (Hardhat source dir), not root — stubs at root were dead files
- ABI files pre-generated from the working implementation — still valid
- Re-submission of rejected milestones not supported by contract (PRD mentions it, contract uses sequential-only approach)
- useCases.js calls `getCasesCount()` which IS in the contract ABI — no fix needed
