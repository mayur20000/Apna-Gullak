# Apna Gullak — Code Review + Existing Feature Implementation Plan

This repository currently contains project documentation but does not include the Flutter source files listed in the README (`lib/`, `pubspec.yaml`, etc.).

Because of that, this review focuses on:
- how to structure the implementation of the **existing documented features**, and
- what to verify once the actual code is added.

## 1) Recommended Architecture for Existing Features

## Layers
- **UI layer (screens/widgets)**: rendering, form validation, user interactions.
- **State layer (provider/bloc/riverpod)**: manages loading/success/error and combines streams.
- **Data layer (services/repositories)**: Firebase Auth, Firestore, Razorpay SDK wrappers.
- **Model layer**: `Goal`, `Wallet`, `Transaction` with `toJson/fromJson` and validation.

Keep SDK-specific code (Firebase/Razorpay) out of widgets; route it through services/repositories.

## Suggested folder structure
```text
lib/
  core/
    errors/
    utils/
    constants/
  models/
    goal.dart
    wallet.dart
    transaction.dart
    app_user.dart
  services/
    auth_service.dart
    firestore_service.dart
    payment_service.dart
  repositories/
    auth_repository.dart
    goal_repository.dart
    wallet_repository.dart
    transaction_repository.dart
  state/
    auth/
    goals/
    wallet/
    transactions/
  screens/
  widgets/
```

## 2) Feature-by-Feature Implementation Notes

### A) Authentication
- Use FirebaseAuth for sign-up/sign-in/sign-out/reset password.
- On first sign-up, create `/users/{uid}` document with profile metadata and defaults.
- Add guarded routes: if auth state is null, redirect to auth flow.
- Validation:
  - Email format + non-empty password.
  - Minimum password policy.

### B) Goal Creation & Tracking
- Store goals under `/users/{uid}/goals/{goalId}`.
- Required fields:
  - `title`, `targetAmount`, `savedAmount`, `createdAt`, `updatedAt`, `status`.
- Enforce invariants:
  - `targetAmount > 0`
  - `savedAmount >= 0`
  - `savedAmount <= targetAmount` (unless overfunding is intentionally supported)

### C) Wallet Balance
- Store in `/users/{uid}` as `walletBalance`.
- Prefer integer paise/cents in storage to avoid floating-point drift.
- Initialize balance to 0 at onboarding.

### D) Add Funds (Razorpay UPI)
- Flow:
  1. User enters amount.
  2. Create payment order/session.
  3. Open Razorpay checkout.
  4. On success: atomically update wallet/goal and write transaction record.
  5. On failure: write failed transaction record for audit.
- Validate webhooks/signatures server-side where possible.

### E) Transactions
- Store under `/users/{uid}/transactions/{txnId}`.
- Suggested fields:
  - `type` (credit/debit), `amount`, `status`, `source`, `goalId`, `createdAt`, `paymentId`, `orderId`.
- Index by timestamp descending for recent-first UI.

### F) Real-time updates
- Use stream listeners for goals, wallet, transactions.
- Debounce high-frequency UI recalculations and handle empty/error states consistently.

## 3) Data Consistency and Security

### Firestore rules
- Restrict access to `request.auth.uid == userId`.
- Block invalid writes:
  - Prevent client writes that set impossible states (negative balances).
- Keep critical mutation logic in trusted backend/cloud functions where feasible.

### Atomic operations
- Use Firestore transactions/batch writes for:
  - adding funds,
  - wallet and goal updates,
  - transaction history writes.

### Idempotency
- Guard against duplicate payment callbacks by storing unique payment IDs and checking existence before write.

## 4) Observability and Error Handling
- Centralize error mapping (FirebaseAuthException, FirebaseException, Razorpay errors).
- Show user-friendly messages; log full technical error details for debugging.
- Add structured event logging for key user actions and payment lifecycle.

## 5) Testing Checklist for Existing Features

## Unit tests
- Model serialization/parsing.
- Amount formatting and parsing.
- Validation logic for forms and domain rules.

## Widget tests
- Auth screens form validation and loading states.
- Goal creation/edit forms.
- Transaction list empty/loading/populated states.

## Integration tests
- Sign-up -> create goal -> add funds -> transaction appears.
- Payment failure path records failed transaction.
- Sign-out/sign-in persistence behavior.

## Security validation
- Attempt read/write cross-user documents (should fail).
- Attempt invalid negative amount writes (should fail).

## 6) Priority Order to Implement Existing Features
1. Authentication + user bootstrap document.
2. Goal CRUD + real-time list.
3. Wallet balance and transaction model.
4. Razorpay payment integration with robust success/failure handling.
5. Transaction history UI + filtering.
6. Harden security rules + add tests.

## 7) Gaps Found in Current Repository
- Missing source code referenced by README (`lib/`, `pubspec.yaml`, screens/services/models).
- Missing CI/test setup for Flutter quality checks.
- No documented environment sample (`.env.example`) for secrets and keys.

## 8) Next Actions
- Add actual Flutter app source directories.
- Add `analysis_options.yaml`, lints, and baseline tests.
- Add CI: `flutter analyze`, `flutter test`, and formatting checks.
- Add backend/webhook verification strategy for Razorpay.
