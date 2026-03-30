# PawLedger Demo Runbook

> For Pink HerSolidity Hackathon 2026 live demo.

## 1. Demo Goal

Show one complete, trust-minimized rescue funding lifecycle on Avalanche Fuji:

1. Rescuer submits a case
2. Reviewer approves case
3. Donor donates
4. Rescuer submits milestone evidence
5. Donor votes to approve
6. Rescuer withdraws approved milestone funds

## 2. Environment Checklist (T-30 min)

### Contracts

```bash
cd projects/pawledger/src/contracts
npx hardhat test
```

Expected: all tests pass (current baseline: 61 passing).

### Frontend

```bash
cd projects/pawledger/src/ui
npm install
npm run build
npm run dev
```

Expected: dev server starts at `http://localhost:5173` without build errors.

### Wallets / Network

- Wallet A (Rescuer + initial Reviewer/Owner) has Fuji AVAX for gas
- Wallet B (Donor) has Fuji AVAX for donation + gas
- Both wallets on Avalanche Fuji (`chainId 43113`)
- Faucet ready: `https://faucet.avax.network`

### Optional (Image Upload)

- `projects/pawledger/src/ui/.env` contains `VITE_PINATA_JWT=...`
- If unavailable, run demo with text metadata only (still valid core flow)

## 3. Live Demo Script (6-8 min)

## 3.1 Opening (30s)

- Explain problem: donation trust and payout transparency.
- Explain solution: escrow + milestone voting + on-chain ledger.

## 3.2 Submit Case (Wallet A, 1-2 min)

1. Open `/submit`
2. Fill title, description, goal amount, deadline, milestone count
3. Submit transaction
4. Confirm case appears in rescuer dashboard as pending

Talking point: case metadata is persisted on-chain through IPFS reference.

## 3.3 Review Case (Wallet A as initial reviewer, 45s)

1. Open `/dashboard/reviewer`
2. Approve the pending case
3. Confirm case status moves to `ACTIVE`

Talking point: reviewer action is on-chain and mints reviewer incentive token ($PAW).

## 3.4 Donate (Wallet B, 45s)

1. Switch to Wallet B
2. Open `/case/:id`
3. Donate AVAX
4. Confirm funding progress increases

Talking point: Avalanche confirmation speed is shown in transaction confirmation UI.

## 3.5 Milestone + Vote (Wallet A then Wallet B, 2 min)

1. Wallet A submits milestone evidence + requested amount
2. Wallet B opens same case and votes Approve
3. Confirm vote weights/progress update in real time UI

Talking point: vote weight is proportional to donor contribution.

## 3.6 Withdraw Approved Milestone (Wallet A, 45s)

1. Wallet A withdraws approved milestone funds
2. Confirm status and timeline event update

Talking point: funds are released only after milestone governance conditions are met.

## 3.7 Close (30s)

- Recap: submit -> review -> donate -> milestone -> vote -> release
- Emphasize transparent auditability and community-supervised disbursement

## 4. Fallback Paths

- If wallet popup rejected: retry action and highlight explicit error handling in UI.
- If network mismatch: use wallet switch to Fuji and retry.
- If Pinata/JWT missing: skip image upload, proceed with text-only case submission.
- If gas insufficient: faucet both wallets before continuing.

## 5. Demo Operator Notes

- Keep browser tabs ready:
  - Home, Case detail, Rescuer dashboard, Reviewer dashboard, Donor dashboard
- Keep two wallet sessions ready (separate browser profile/incognito if needed)
- Avoid showing private keys/seed phrases on screen
- Keep one pre-created case as backup in case of live RPC hiccups

## 6. Post-Demo Verification

After demo, run this quick confidence check:

1. Case status transitions observed: `PENDING -> ACTIVE`
2. Donation reflected in raised amount
3. Milestone vote changed approval weight
4. Withdraw succeeded only after approval
5. Expense/event timeline captured each key action
