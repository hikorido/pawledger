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
- [ ] Demo prep

## Phase 9: Image Upload
- [x] `ImageUpload` component — drag-and-drop, preview grid, 5 photos / 5MB each
- [x] `uploadToIPFS.js` utility — Pinata IPFS upload, reads `VITE_PINATA_JWT`
- [x] Wire image upload into SubmitCase — uploads CIDs, stores in case metadata
- [x] Bilingual locale strings for all upload states
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

## Phase 11: PawAdoption Integration
- [x] Move PawAdoption assets into PawLedger project structure
- [x] Implement PawAdoption contract and test baseline
- [x] Cleanup legacy root PowAdoption directory and generated noise
- [x] Update deployment script to include PawAdoption ([5/5])
- [x] Add PawAdoption address slot in UI config
- [x] Compile contracts and sync PawAdoption ABI to UI
- [x] Extend useContract with PawAdoption contract instance
- [x] Add useAdoption hook (browse/detail/register/apply flows)
- [x] Add usePublisher hook (publish/audit workflows)
- [x] Add adoption components (PetCard, RealNameRegistration, ApplicationCard, AuditPanel, ApplicationForm)
- [x] Add adoption pages (AdoptionBrowser, AdoptionDetail, PublishPet, PublisherDashboard, AdopterDashboard)
- [x] Integrate new adoption routes in App
- [x] Add adoption entry in Navbar and adoption section on Home
- [x] Add complete adoption bilingual locale keys (zh/en)
- [ ] Run manual adoption flow verification (automated checks passed: Hardhat tests + UI build)

## Phase 11d: Documentation Consolidation
- [x] Combine `projects/pawledger/docs/prd.md` + `projects/pawledger/docs/Adoption-spec.md` into one unified PRD source

## Phase 11b: Adoption Hardening (Review Fixes)
- [x] Fix tx error visibility on adoption actions
	- [x] AdoptionDetail: catch and display errors for register/apply/audit handlers
	- [x] ApplicationForm: add user-facing submit error feedback (wallet reject/revert/RPC)
	- [x] RealNameRegistration: add user-facing submit error feedback (wallet reject/revert/RPC)
- [x] Fix PublisherDashboard initial loading UX
	- [x] Add dedicated read-loading state for getMyPets/getPetApplications refresh flow
	- [x] Prevent empty-state flicker before first successful fetch
	- [x] Add read error message + retry action in dashboard
- [x] Fix AdopterDashboard account switch/disconnect stale state
	- [x] Clear applications, realName, and error state when wallet disconnects
	- [x] Ensure account switch does not temporarily show previous account data
- [x] Add Web Crypto guard for real-name hashing
	- [x] Check crypto.subtle availability before hashing
	- [x] Show clear fallback error message when environment is unsupported

## Phase 11c: Local Verification Checklist (Adoption)
- [ ] Contracts: install deps and run tests
	- [ ] `cd projects/pawledger/src/contracts && npm install`
	- [ ] `npx hardhat test` (expect all suites pass, including PawAdoption)
- [x] UI: install deps and run production build
	- [x] `cd projects/pawledger/src/ui && npm install`
	- [x] `npm run build` (build success; chunk warning acceptable)
- [ ] Manual adoption E2E flow
	- [ ] Wallet A publishes pet on PublishPet page
	- [ ] Wallet B registers real name on pet detail page
	- [ ] Wallet B submits application on same pet
	- [ ] Wallet A audits application from PublisherDashboard (approve path)
	- [ ] Verify pet status becomes adopted and blocks new applications
	- [ ] Repeat with reject path and verify status shown as rejected
- [ ] Runtime/UX edge-case verification
	- [ ] Reject wallet signature and verify visible error feedback (register/apply/audit)
	- [ ] Force contract revert and verify visible error feedback (register/apply/audit)
	- [ ] Disconnect wallet on AdopterDashboard and verify state resets immediately
	- [ ] Hard refresh dashboards and verify no incorrect empty-state flash

## Issues Found & Resolved
- Contract source was in `contracts/contracts/` (Hardhat source dir), not root — stubs at root were dead files
- ABI files pre-generated from the working implementation — still valid
- Re-submission of rejected milestones not supported by contract (PRD mentions it, contract uses sequential-only approach)
- useCases.js calls `getCasesCount()` which IS in the contract ABI — no fix needed
- Adoption PRD is now merged into `docs/prd.md` (v3 unified); standalone `docs/Adoption-spec.md` removed.
