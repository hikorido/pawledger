# Adoption E2E Checklist

## Scope

Manual validation for Phase 11c adoption flow in local dev environment.

## Prerequisites

1. Two wallets on Avalanche Fuji with enough AVAX for gas.
2. Frontend running at local dev URL.
3. Contracts deployed and `src/ui/src/config.js` populated with current addresses.

## Flow A: Approve Path

1. Wallet A opens `PublishPet` and publishes one pet.
2. Wallet B opens pet detail page and completes real-name registration.
3. Wallet B submits an adoption application.
4. Wallet A opens `PublisherDashboard` and approves that application.
5. Verify pet status changed to adopted.
6. Verify new applications are blocked for that pet.

Expected:
- Publish tx, register tx, apply tx, audit tx all succeed.
- Application status becomes approved.
- Pet status becomes adopted and cannot accept new applications.

## Flow B: Reject Path

1. Wallet A publishes another pet.
2. Wallet B (or another wallet) registers and submits application.
3. Wallet A rejects the application in `PublisherDashboard`.
4. Verify application status shows rejected.
5. Verify pet remains open (not adopted) and still allows other applications.

Expected:
- Rejected application cannot be re-audited.
- Pet remains available for future applicants.

## Runtime Edge Cases

1. Reject wallet signature in register/apply/audit and verify user-facing error is shown.
2. Trigger known revert paths (duplicate registration, duplicate apply, non-publisher audit) and verify user-facing error is shown.
3. Disconnect wallet on `AdopterDashboard` and verify stale state clears immediately.
4. Hard refresh `PublisherDashboard` and `AdopterDashboard` and verify no incorrect empty-state flash before data load.

## Record Results

For each check, record:

- Pass/fail
- Tx hash (if applicable)
- Screenshot or note for any issue

Update `tasks/todo.md` checkboxes after completion.
