# Phase 2 Research: Backup and Restore

## 1. Where the working book lives

- **Decision**: Keep the on-device Drift book as the only place new records are written. A backup is a snapshot of that book after the last successful save. Restore and import replace the whole book through the existing store save, then later recording continues on the device.
- **Rationale**: The spec says the device book remains the working copy, and a backup must not contain a half-saved change. The current `FinanceStore` already loads and replaces the full set of accounts, categories, subcategories, and transactions.
- **Alternatives considered**: Writing new transactions to the cloud first (rejects the local-first rule). Merging a copy into the current book (the spec forbids merge).

## 2. Cloud transport

- **Decision**: Store each cloud copy as one Firestore document under `backups/{uid}/copies/{id}` for the signed-in person. Add `firebase_auth` and `cloud_firestore`. The app already initializes Firebase and already depends on `google_sign_in`.
- **Rationale**: The phase request names Firebase cloud backup. One document per copy matches export/import and the five-copy limit. Firestore works on the free Spark plan; Firebase Storage requires Blaze billing. Firebase is already initialized for Crashlytics, Analytics, Remote Config, and Messaging.
- **Alternatives considered**: Firebase Storage objects (requires Blaze). Firestore documents per transaction (a second ledger, easy to diverge). Uploading through `DioConsumer` (Firestore is not an HTTP API this app owns). A vendor-neutral interface with a fake in tests, and Firebase only in the data source.

## 3. Who may send or retrieve a cloud copy

- **Decision**: Google sign-in through the existing `google_sign_in` package, linked to Firebase Auth, and only when a cloud send or retrieve starts. Recording, review, and export do not call it. Cancel leaves the device book unchanged.
- **Rationale**: The clarification says identification is required only for the cloud copy. Google sign-in is already a dependency and is one step on Android and iOS.
- **Alternatives considered**: Email and password (extra form, not required). Anonymous auth (a new device cannot retrieve the copy). Requiring sign-in for the whole product (rejected in clarification).

## 4. How many cloud copies

- **Decision**: After each successful upload, keep the five newest successful documents and delete the older ones. Failed and waiting attempts are not stored as copies.
- **Rationale**: Matches the clarification. Five covers a bad latest copy without unbounded storage.
- **Alternatives considered**: Only the latest (one bad backup is the only way back). Keep all until the person deletes one (unbounded). A 30-day window (harder to test than a count of five).

## 5. Export file

- **Decision**: One JSON document, format version 1, with no passphrase. It contains the saved accounts, categories, subcategories, and transactions, plus the time and source. The person saves or shares it with the existing `file_picker` and `share_plus` packages. Import parses that document, rejects anything else, and replaces the book only after confirmation.
- **Rationale**: The clarification says the file has no lock and import does not ask for a passphrase. JSON is readable for support and uses the model `toJson` / `fromJson` methods that already exist.
- **Alternatives considered**: A passphrase-locked file (rejected). A raw SQLite file (ties the copy to the current table layout). CSV (loses transfer endpoints and subcategories).

## 6. When automatic backup runs

- **Decision**: Check on open of the finance shell, which is the product start. If the schedule is daily, weekly (Saturday–Friday), or monthly, and that period has started since the last success, and `NetworkInfo` says the device is connected, upload one copy. If offline, record waiting and retry on a later open. The schedule defaults to off.
- **Rationale**: The spec says the check happens when the person opens the product, not on a hidden clock while it is closed.
- **Alternatives considered**: A background task while the app is closed (contradicts the spec). Checking only on the backup screen (a person who never opens that screen would never get an automatic copy).

## 7. Knowing whether the device is connected

- **Decision**: Use the existing `NetworkInfo` port. Replace the stub that always returns connected with a real connectivity check before any cloud attempt.
- **Rationale**: Manual backup offline must fail visibly, and automatic backup must wait. The current stub would mark those copies successful with no network.
- **Alternatives considered**: A second connectivity type inside the backup feature (duplicates a core port). Treating every Firebase error as offline (hides a bad credential as a missing connection).

## 8. Feature boundary

- **Decision**: A new `backup` feature. It reads and replaces the book through `FinanceStore` in `lib/core/database`. It does not import account, category, or transaction cubits. Screens stay in the backup feature and are registered on the existing app router inside `FeatureScope`.
- **Rationale**: Backup is a separate user goal from recording money. The constitution requires one feature directory, inward dependencies, and one cubit per action. The Phase 0 note that put everything in one `fenzo` feature is not how the app is structured now.
- **Alternatives considered**: Adding backup methods to the accounts repository (mixes two reasons to change). A cloud write inside each save use case (makes recording depend on the network).
