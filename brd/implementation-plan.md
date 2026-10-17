# Implementation Plan: Finzo Manager BRD v1.0

**Date:** 2026-10-16
**Source of intent:** [brd.md](brd.md) (converted from `brd.html`)
**Code baseline:** the app as it exists today. This plan does not change that code.
**Audience:** the developer who will implement the remaining BRD scope on top of the current feature layout.

This plan merges the BRD roadmap (phases A–F) with work that is already in the repository. Finished slices stay. Remaining Must work is scheduled after them. Should and Could items stay behind the Must line.

## 1. How the two sources fit together

The BRD describes one product from an empty start: financial core, then smart capture, then Safe-to-Spend, then backup and AI, then release.

The repository has already built the financial core and backup, in the same architecture the rest of the app uses:

| BRD phase | BRD intent | Code today |
|---|---|---|
| A | Requirements, data concepts, accounting rules | Done for accounts, transactions, categories, reports, and backup. Still open for capture, obligations, goals, and Safe-to-Spend. |
| B | Accounts, transactions, categories, reports, tests | Done in `lib/features/accounts`, `categories`, `transactions`, `dashboard`, `reports`, plus shared calculators. |
| C | Receipts, voice, review, local categorization | Not started. |
| D | Safe-to-Spend, obligations, savings goals | Not started. |
| E | Backup/restore, and cloud AI where local rules are not enough | Backup, restore, schedule, and file export/import are done in `lib/features/backup`. Cloud AI is not started. |
| F | End-to-end testing and release | Unit and cubit tests exist for accounts, backup, balances, and reports. Device release testing (AC-010) is still a gate. |

Earlier design notes live in `specs/001-phase0-mvp/` and `specs/002-phase2-backup/`. Those folders record decisions already shipped. This plan does not reopen them. New work follows the same feature layout.

## 2. What is already implemented

Local Drift database `FinanceDatabase` (schema version 1) stores:

- `AccountRows` — name, type, bank name, account number, phone, opening balance in minor units, opening date, active flag, include-in-total flag.
- `CategoryRows` and `SubcategoryRows`.
- `TransactionRows` — income, expense, or transfer, with amount, date, account, category, subcategory, transfer endpoints, description, and notes.

Balances are calculated, not stored. `accountBalanceMinor` in `lib/shared/domain/services/balance_calculator.dart` applies BR-002: opening balance + income + incoming transfers − expenses − outgoing transfers. `totalMoneyMinor` sums accounts whose `includeInTotal` flag is true. Transfers are excluded from income and expense in `lib/shared/domain/services/report_calculator.dart` (BR-003).

| Area | Where it lives | BRD coverage |
|---|---|---|
| Multiple accounts, types bank / e-wallet / cash, plus an extra `other` type | `lib/features/accounts/` | FR-001, FR-002 |
| Opening balance and opening date | account entity and form | FR-003 |
| Income, expense, internal transfer, edit, delete | `lib/features/transactions/` | FR-004, FR-006 |
| Categories and subcategories, including deactivate when already used | `lib/features/categories/` | FR-005 |
| Home dashboard: current money, this month’s income and expenses, category shares, recent activity | `lib/features/dashboard/` | FR-011 (month view) |
| Reports for a chosen range, including week and month presets | `lib/features/reports/` | FR-011 |
| Offline local book | Drift via `lib/core/database/` | FR-014, BR-001, NFR-001 |
| Manual cloud backup, restore with confirmation, automatic daily/weekly/monthly copy, export and import of a file | `lib/features/backup/` | FR-015, BR-008, NFR-009, and more than the BRD minimum |
| Arabic and English string tables | `assets/lang/ar.json`, `assets/lang/en.json`, `packages/language` | strategy item for both languages and Arabic RTL |
| No payment execution, no bank login secrets | no such features exist | BR-006, BR-007 |

Routes already registered in `lib/config/routes/app_routes.dart`: home, dashboard, accounts, account form, transaction form, transactions, categories, reports, settings, backup, cloud copies.

Money is stored as integer minor units (two decimal places). Recording does not call the network. Cloud backup asks the user to sign in with Google; export and everyday recording do not.

Tests already cover account use cases and repository, balance and report calculators, money precision, and the backup use cases, repository, and cubits.

## 3. Requirement coverage

Status is against the code, not against a future wish.

| ID | Priority | Status | Evidence |
|---|---|---|---|
| FR-001 | Must | Done | Account list, form, deactivate, reactivate, delete. |
| FR-002 | Must | Done | `AccountType.bank`, `eWallet`, `cash`. `other` is extra and stays. |
| FR-003 | Must | Done | `openingBalanceMinor` and `openingDate`. |
| FR-004 | Must | Done | Save income, expense, and transfer use cases. |
| FR-005 | Must | Done | Category and subcategory list, save, deactivate, delete. |
| FR-006 | Must | Done | Transaction form. |
| FR-007 | Must | Missing | No receipt capture or OCR. `image_picker` is a dependency and is unused in `lib/`. |
| FR-008 | Must | Missing | No speech capture. |
| FR-009 | Must | Missing | No review draft. Manual entry saves directly, which is correct for FR-006. |
| FR-010 | Must | Missing | No local rules, history suggestions, or cloud classifier. |
| FR-011 | Must | Done | Dashboard and report page. |
| FR-012 | Must | Missing | No obligation or savings-goal types or screens. |
| FR-013 | Must | Missing | No Safe-to-Spend figure or explanation. |
| FR-014 | Must | Done | Drift book. Core flows do not require a connection. |
| FR-015 | Must | Done | Firebase Auth + Firestore copies, restore, and status. |
| FR-016 | Should | Missing | Save does not warn on a likely duplicate. |
| FR-017 | Should | Missing | No salary date and no forecast. Deferred until Must work is done. |
| FR-018 | Could | Out of MVP | Listed under BRD section 06 as advanced forecasting and decision simulation. Do not build in this plan. |
| FR-019 | Could | Out of MVP | Listed under BRD section 06 as a comprehensive AI financial coach. Do not build in this plan. |

FR-018 and FR-019 stay in the BRD as Could items. Section 06 also places them outside the MVP. This plan does not schedule them.

## 4. Rules, quality, and acceptance

| ID | Status | Note |
|---|---|---|
| BR-001 | Done | Transactions write to Drift. Backup failure does not block a save. |
| BR-002 | Done | `accountBalanceMinor`. |
| BR-003 | Done | Transfer updates both accounts and is omitted from income and expense totals. |
| BR-004 | Missing | Needs obligations, goals, and an explanation. Formula is still an open decision (section 8). |
| BR-005 | Missing | Applies only after capture and AI exist. Manual entry is the user typing the fields, so it already is the review. |
| BR-006 | Done | No payment or bank-transfer execution. |
| BR-007 | Done | Bank name, account number, and phone are labels only. |
| BR-008 | Done | Restore and import replace the whole book only after the user confirms. There is no silent merge. |
| BR-009 | Holds for current math | Calculators live in domain code. Future AI must call those calculators and must not return a balance of its own. |
| NFR-001 | Done for the core | Capture and cloud AI will need a network and must fail without blocking manual entry. |
| NFR-002 | Done for current tables | New tables must keep the same rule: balances stay derived. |
| NFR-003 | Open for capture | Backup already limits cloud use to an explicit copy. Receipt and voice must say when data leaves the device. |
| NFR-004 | Partial | Cloud copies use Firebase Auth and Firestore. Extra client-side encryption is still an open decision. |
| NFR-005 | Open | Minimum OS versions are not chosen in the BRD. |
| NFR-006 | Partial | Manual entry exists. Uncertain extracted fields do not, because capture does not. |
| NFR-007 | Not started | Local rules must run before any cloud call, with a manual fallback. |
| NFR-008 | Not started | Category suggestion must depend on an interface, not one vendor SDK, in domain code. |
| NFR-009 | Done | Invalid import files are rejected. Restore reports the result. |
| AC-001 | Done in domain tests | `test/shared/domain/balance_calculator_test.dart`. |
| AC-002 | Done in domain tests | Transfer cases in the balance and report calculators. |
| AC-003 | Done by architecture | Local save has no network dependency. |
| AC-004 | Missing | Blocked on capture. |
| AC-005 | Done in domain tests | `test/shared/domain/report_calculator_test.dart`. |
| AC-006 | Missing | Blocked on Safe-to-Spend. |
| AC-007 | Done in backup tests | Restore and import tests under `test/features/backup/`. |
| AC-008 | Missing | Should, not Must. |
| AC-009 | Holds | No AI or OCR key is in the client today. New providers must not embed secret keys in the app. |
| AC-010 | Release gate | Automated tests exist. A pass on Android and iOS devices is still required before release. |

## 5. Keep this behavior

The code already does more than the BRD’s minimum. Later work must leave it in place.

- Search and filters on the transaction list.
- Account deactivate, reactivate, and delete. An account with history is deactivated instead of erased. Type can change only while the account has no transactions.
- `includeInTotal`. Accounts with the flag off are omitted from `totalMoneyMinor`. Safe-to-Spend must treat that flag as an excluded balance and explain it (BR-004).
- Account type `other`, in addition to bank, e-wallet, and cash.
- Ready-made categories, including Arabic seed names.
- Automatic backup on daily, weekly (Saturday–Friday), or monthly, keeping the five newest successful cloud copies.
- File export and import that replace the book only after confirmation, with no passphrase.
- Integer minor units and rejection of more than two decimal places.
- Settings as the entry to categories and backup. The home screen leads with current money, not a net row, and does not list accounts.

## 6. Remaining roadmap

Estimates below are the BRD’s one-developer ranges, counted only for work that is not already in the app. They are still rough.

### Phase C — Smart capture (about 4 weeks)

New feature: `lib/features/capture/`.

One user action is one cubit and one use case, same as accounts and backup.

1. **Receipt draft.** The user takes or picks a photo. A data source returns proposed amount, date, and merchant text. Nothing is written to `TransactionRows` yet.
2. **Voice draft.** The user speaks. A data source returns text and proposed fields. Nothing is written yet.
3. **Review screen.** One screen for both sources. The user edits account, amount, date, category, and notes. Uncertain fields are marked. Confirm calls the existing income or expense save use case. Cancel discards the draft (BR-005, AC-004).
4. **Local category suggestion.** Before any cloud call, match the merchant or spoken text against the user’s past transactions and a small on-device rule list (FR-010, NFR-007). The suggestion is a field on the draft, not a saved transaction.
5. **Cloud suggestion, only if local matching is empty and the device is online.** Domain depends on an interface. The first implementation can be a no-op that leaves the category blank, so the review screen still works offline (NFR-008). A real provider is a later data-source swap after section 8 is answered.
6. **Privacy default until the product owner decides otherwise:** do not keep the image or the recording after the user leaves the review screen. Tell the user when a cloud suggestion would send text off the device, and let them skip it.

Capture must not add a second transaction repository. Confirm goes through the transactions feature’s existing save use cases.

`image_picker` is already in `pubspec.yaml`. Speech recognition is not. Add a speech dependency only when the voice data source is built, behind the capture data source so domain code never imports it.

### Phase D — Obligations, goals, and Safe-to-Spend (about 3 weeks)

Two new features, because each is its own user-facing operation:

- `lib/features/obligations/` — name, amount, cadence, next due date, active flag.
- `lib/features/savings_goals/` — name, target amount, amount already set aside, optional linked account.

Both store rows in the same Drift database, with a schema bump. They do not import each other’s data layer. If the dashboard and Safe-to-Spend both need the entities, those entities move to `lib/shared/domain/entities/` when the second feature reads them.

**Safe-to-Spend** is a calculation, not a stored balance (BR-009). Put it next to the existing calculators in `lib/shared/domain/services/`, and show it from the dashboard with a short explanation (AC-006).

Proposed lines, pending the open decision in section 8:

- Start from `totalMoneyMinor` (accounts included in the total).
- List accounts left out because `includeInTotal` is false. Do not subtract them again.
- Subtract obligations that are due and not already recorded as expenses, so a paid bill is not counted twice.
- Subtract the still-unfilled part of a savings goal only when that money is not already sitting in an account that was excluded as a reserve.
- Show each line: starting total, each deduction, each exclusion. Estimates and unpaid items are labeled as such.

Do not start this calculator until the product owner accepts or edits those lines. Building the obligation and goal screens can proceed with a simpler MVP shape from section 8 (fixed amount, monthly due date, no reminders).

### Phase E remainder — Cloud AI only where phase C needs it

Backup is finished. Do not rebuild it.

The only leftover E work is the cloud half of FR-010, and only after a provider is chosen. The client calls a backend or a Firebase function. Secret keys stay off the device (AC-009). If the call fails, the review screen stays usable with the local suggestion or an empty category (NFR-007).

### Phase F — Release checks (about 2–4 weeks, overlapping the end of C and D)

- Use-case, repository, and cubit tests for capture, obligations, goals, and Safe-to-Spend, including the offline and cancel paths.
- One test that a receipt or voice draft is absent from balances until confirm (AC-004).
- One test that Safe-to-Spend’s explanation lists every included and excluded amount (AC-006).
- Manual pass of the existing core and the new flows on Android and iOS (AC-010).
- Strings for every new screen in both `assets/lang/en.json` and `assets/lang/ar.json`.

### After the MVP, if still wanted

| ID | When | Rule |
|---|---|---|
| FR-016 duplicate warning | After phase C, if time remains | On save, warn when the same account, amount, and calendar date already exist. The user chooses keep or cancel. Never delete or merge automatically (AC-008). |
| FR-017 forecast to next salary | Separate decision | Needs a salary date the BRD does not define. Label every figure as an estimate. |
| FR-018, FR-019 | Not in this plan | Out of MVP scope. |

## 7. Where new code should go

Follow `lib/features/profile/`’s layering, the same way accounts and backup already do. Do not register feature types in `ServiceLocator.init()`. Each new route uses `FeatureScope` and `BlocProvider`.

```text
lib/features/capture/
├── capture_injection.dart
├── data/datasources/          # image, speech, optional cloud suggestion
├── data/models/
├── data/repositories/
├── domain/entities/           # capture draft, review status
├── domain/repositories/
├── domain/usecases/
└── presentation/controller/   # one cubit per action
    pages/
    widgets/

lib/features/obligations/     # same three layers
lib/features/savings_goals/   # same three layers

lib/shared/domain/services/safe_to_spend_calculator.dart
lib/shared/domain/entities/   # only if a second feature reads the entity
```

Drift tables to add when those features are built: obligations, savings goals, and capture drafts if a draft must survive leaving the screen. Backup’s book snapshot must include the new tables, or a restore would drop them. That is an extension of `lib/features/backup/data/models/book_snapshot_model.dart`, done when the new tables exist, not before.

Category suggestion rules can live in the capture feature until a second feature needs them. Then move the entity to `lib/shared/domain/entities/`.

New screens register on the existing `AppRouter`. Likely routes: receipt capture, voice capture, review draft, obligation list and form, savings-goal list and form. Safe-to-Spend is a block on the current dashboard, not a new app.

## 8. Decisions: already settled by the code, and still open

Settled by what shipped. Do not reopen unless the product owner asks.

| BRD question | Current behavior to keep |
|---|---|
| Currency | One currency, integer minor units, at most two decimal places. No exchange rates. |
| Restore over existing data | Replace the whole book after the user sees the impact and confirms. No merge. |
| Backup authentication | Google sign-in only for cloud backup and restore. Recording and file export do not require it. |
| Week boundaries | Saturday through Friday, already used by reports and the backup schedule. |

Still open. Defaults below let phase C and the obligation screens start. Safe-to-Spend math and the cloud provider wait for an explicit answer.

| Question | Working default for the next build | Blocks |
|---|---|---|
| Multiple currencies | Stay on one currency. | Nothing, if this default holds. |
| Receipt languages | Arabic and English printed receipts. Highlight fields the extractor is unsure about. | Provider choice, not the review screen. |
| Keep images and recordings | Delete when the user leaves review, unless they opt in. | Capture storage. |
| Extra backup encryption | Keep Firebase Auth and Firestore rules. No second passphrase. | Nothing further in backup. |
| Obligation types and reminders | Monthly fixed amount and a due day. No push reminder in the MVP. | Obligation screens can use this default. |
| Safe-to-Spend lines | Use the proposal in phase D. Do not code it until confirmed. | Safe-to-Spend calculator. |
| Minimum OS versions | Whatever the current Flutter project already targets. Record the numbers at release. | AC-010, not feature design. |
| OCR and AI providers | None in the first capture slice. Local text match only. Pick a provider before the cloud data source. | Cloud half of FR-010 only. |

## 9. Constitution check for the remaining work

The project constitution (version 2.2.0) still governs every new feature.

| Gate | How remaining work complies |
|---|---|
| Feature-first layers | `capture`, `obligations`, and `savings_goals` each have data, domain, and presentation. Domain does not import Flutter, Dio, or a vendor SDK. |
| GetIt and `FeatureScope` | `register*` functions live in each feature’s injection file. Cubits are factories. Use cases, repositories, and data sources are lazy singletons. Widgets do not construct them. |
| Cubit and `ApiCallState` | One cubit per action, `f` prefix, sealed `ApiCallState`. The review screen dispatches confirm; it does not call OCR. |
| `Either` and `RepositoryGuard` | Data sources throw `AppException`. Repositories return `Either<Failure, T>`. |
| Entities vs models | JSON and vendor payloads stay on models. Drafts and goals in domain are pure Dart. |
| Shared app code | New copy goes through `assets/lang` and `Strings`. Colors come from the existing theme. Safe-to-Spend reuses the balance calculator instead of a second formula. |
| No extra layers | No service between cubit and use case. AI is a data source behind an interface, not a new framework. |

## 10. Order of work

1. Leave accounts, categories, transactions, dashboard, reports, and backup as they are.
2. Build capture drafts and the review screen with a local suggestion and no cloud provider.
3. Build obligations and savings goals with the simple monthly default.
4. Confirm the Safe-to-Spend lines, then add the calculator and the dashboard explanation.
5. Extend the backup snapshot so restore still round-trips the new records.
6. Add tests and both languages, then run the core flows on Android and iOS.
7. Add the cloud suggestion provider only after it is chosen.
8. Add duplicate warnings only if Must work is finished.

Out of scope for every step above: payments, bank connections, SMS reading, multi-device sync, a custom-trained model, investments, shared business books, decision simulation, and an AI coach.
