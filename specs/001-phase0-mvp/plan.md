# Implementation Plan: Phase 0 MVP — Personal Money Tracking

**Branch**: `001-phase0-mvp` | **Date**: 2026-10-06, amended 2026-10-16, amended 2026-10-17, amended 2026-10-20 (transfer % and usual-fee %) | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-phase0-mvp/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Phase 0 is an Arabic, right-to-left, offline fenzo for one person. They keep accounts with opening balances, record income, expenses, and internal transfers, classify them, and read a current-month dashboard plus date-range reports. Nothing connects to a bank.

The technical approach is one `fenzo` feature in the existing Flutter app. Domain code owns money (integer piastres), the balance formula, and date ranges. Drift stores the facts on device. Cubits call one use case each and never calculate balances in widgets. Decisions are in [research.md](research.md).

### Amendment 2026-10-16 — Transfer commission

The person can type a fee on an internal transfer, and on an expense paid from a bank account or an e-wallet. The fee is stored on that same transaction as integer piastres. It is not a second transaction. A blank or zero fee leaves today’s balances unchanged.

Shipped code no longer lives in one `fenzo` feature. This amendment touches the current layout:

- `lib/shared/domain/entities/money_transaction.dart` — `commissionMinor`, default 0
- `lib/shared/domain/finance_records.dart` — reject a fee that is not allowed, and ensure the seed category `رسوم تحويل` exists even when other categories are already present
- `lib/shared/domain/services/balance_calculator.dart` and `report_calculator.dart` — the fee leaves the source or paying account and counts as spending; transfer in and transfer out stay the moved amount
- `lib/features/transactions/` — the existing save and update use cases, cubits, and transaction form pass the fee through. No new feature and no new cubit
- `lib/core/database/finance_database.dart` — schema version 2 adds `commission_minor` with default 0
- `lib/features/backup/data/models/book_snapshot_model.dart` via the transaction model — the fee is in the book copy; a copy that omits it restores as 0

The transaction form shows the fee field for every transfer, and for an expense only while the paying account is `bank` or `eWallet`. Income, cash, and `other` do not show it. Saving a fee greater than zero on a disallowed row is rejected in `saveMovement` and does not change the book.

### Amendment 2026-10-17 — Usual fee on each account

Each account stores an optional usual fee as integer piastres. Blank or zero means no usual fee. The amount is not spending and is not part of any balance. Changing it does not rewrite saved transactions.

`saveMovement` still stores only the fee the caller sends. It does not copy the account’s usual fee, because the person must be able to clear a starting fee and save zero. The account form and the transaction form own the starting value.

- `lib/shared/domain/entities/account.dart` — `defaultCommissionMinor`, default 0
- `lib/shared/domain/finance_records.dart` — `saveAccount` rejects a negative usual fee and leaves the book unchanged
- `lib/core/database/finance_database.dart` — schema version 3 adds `default_commission_minor` on `account_rows` with default 0. The version 2 upgrade that adds `commission_minor` stays in place
- `lib/features/accounts/` — the existing save-account use case, repository, model, and account form pass the field through. No new feature and no new cubit
- `lib/features/transactions/presentation/pages/transaction_form_page.dart` — a new bank or e-wallet expense starts with the paying account’s usual fee. A new transfer starts with the source account’s usual fee only. Changing that account before save replaces the starting fee when a fee is allowed. Opening a saved row shows the fee already saved. Cash and `other` expenses still hide the field
- Account JSON in `lib/features/accounts/data/models/account_model.dart` writes `default_commission_minor`. A copy that omits the key restores as 0

The usual fee stays when the account type changes. Type change still clears only the identifying labels that do not apply.

### Amendment 2026-10-20 — Fixed or percentage commission on a transfer

On a transfer, the person chooses one basis: a fixed amount, or a percentage of the moved amount. One percent of 1,000.00 EGP is a commission of 10.00 EGP. The destination still receives the moved amount. Balances and reports keep using the resulting piastres in `commissionMinor`. They do not apply the rate a second time.

`saveMovement` is the check. When the basis is `percentage` and the row is a transfer, it stores the rate and writes `commissionMinor` from that rate and `amountMinor`, using integer half-up rounding. It does not trust a money amount sent beside the rate. A percentage on income or an expense is rejected and does not write. Rows already saved, and JSON that omits the new keys, are a fixed commission equal to the piastres already stored.

- `lib/shared/domain/entities/money_transaction.dart` — `commissionBasis` (`fixed` or `percentage`, default `fixed`) and `commissionRateMinor` (default 0). `100` means 1.00%. This is not piastres
- `lib/shared/domain/services/percentage_commission.dart` — one pure function turns an amount and a rate into piastres. The transaction form calls that function for the preview. It does not keep a second rounding rule
- `lib/shared/domain/finance_records.dart` — `saveMovement` applies the function for a percentage transfer, forces rate 0 on a fixed basis, and rejects a percentage on any other type
- `lib/core/database/finance_database.dart` — schema version 4 adds `commission_basis` with default `fixed` and `commission_rate_minor` with default 0. The version 2 and version 3 upgrades stay in place
- `lib/features/transactions/` — the existing save-transfer and update-transaction use cases, cubits, and the transfer form pass the basis and the rate. No new feature and no new cubit. The expense form still sends a fixed amount only
- `lib/features/transactions/data/models/money_transaction_model.dart` — JSON writes `commission_basis` and `commission_rate_minor`. A copy that omits either key restores as `fixed` and 0
- List and dashboard rows show the money fee when it is greater than zero. A percentage row also shows the rate. A result of 0.00 is not shown as a fee. The transfer form still shows a saved rate when its current result is 0.00

The rate is parsed with the same two-decimal rule as money: a third decimal place is rejected, not rounded. Only the calculated commission is rounded, half up, to the nearest piastre. Receipt capture stays a fixed payment fee. It does not gain a percentage control.

How a new transfer or payment starts from the account’s usual fee is updated in the next amendment.

### Amendment 2026-10-20 — Fixed or percentage usual fee on each account

Each account’s usual fee is fixed or a percentage, the same `CommissionBasis` choice as on a transfer. Storing it still does not change balances. Changing it still does not rewrite saved rows.

A new transfer starts from the source account’s usual fee: a fixed usual fee starts a fixed commission of that amount, and a percentage usual fee starts that percentage of the moved amount. A new bank or e-wallet expense starts from the paying account’s usual fee: a fixed usual fee starts that money amount, and a percentage usual fee starts the money amount that rate produces from the payment amount. The saved expense stays a fixed `commissionMinor` only. Switching the source or paying account before save replaces the starting fee with the newly chosen account’s usual fee while the commission is still following that auto-filled start. A hand-set transfer rate is left alone.

- `lib/shared/domain/entities/account.dart` — `defaultCommissionBasis` (`fixed` or `percentage`, default `fixed`) and `defaultCommissionRateMinor` (default 0, same scale as the transfer rate). `defaultCommissionMinor` stays the fixed usual fee in piastres and is 0 when the basis is `percentage`
- `lib/shared/domain/finance_records.dart` — `saveAccount` rejects a negative usual fee or rate and forces rate 0 on a fixed basis. `saveMovement` still does not copy the usual fee; the form still owns the start value
- `lib/core/database/finance_database.dart` — schema version 5 adds `default_commission_basis` with default `fixed` and `default_commission_rate_minor` with default 0 on `account_rows`. Versions 2 through 4 stay in place. Older accounts become `fixed` with rate 0 and keep `default_commission_minor`
- `lib/features/accounts/` — the existing save-account path and account form pass the basis and the rate. No new feature and no new cubit. The form reuses the same fixed-or-percentage control pattern as the transfer form
- `lib/features/accounts/data/models/account_model.dart` — JSON writes `default_commission_basis` and `default_commission_rate_minor`. A copy that omits either key restores as `fixed` and 0
- `lib/features/transactions/presentation/pages/transaction_form_page.dart` — prefills from the account’s basis. For a percentage usual fee on a payment, it calls `percentageCommissionMinor` once and fills a fixed money fee. Receipt capture still copies a fixed money start only when the account’s usual fee is fixed; when it is a percentage, it starts from the computed money for the draft amount
- Reuse `percentageCommissionMinor` from `percentage_commission.dart`. Do not add a second rounding function

## Technical Context

**Language/Version**: Dart `^3.13.4` / Flutter stable (app already created)

**Primary Dependencies**: `flutter_bloc`, `get_it`, `go_router`, `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`, `path`, `intl`, `flutter_localizations`; path packages `packages/either`, `packages/themes`, `packages/language`, `packages/screen_util`, `packages/field_validator`; dev: `bloc_test`, `drift_dev`, `build_runner`

**Storage**: On-device SQLite through Drift. No network database

**Testing**: `flutter_test` and `bloc_test`. Domain tests for money and balances. Repository tests against an in-memory database. Cubit tests for success and error. One widget test for confirm versus cancel

**Target Platform**: Android and iOS (the Flutter project also has desktop and web shells; Phase 0 is specified and checked as a mobile app)

**Project Type**: Mobile app

**Performance Goals**: A report over a personal history of up to 5,000 transactions appears within 2 seconds. Recording an expense takes the person under 30 seconds

**Constraints**: Offline for every Phase 0 story. Arabic RTL only. EGP with at most two decimal places. Amounts the person types are never rounded. A commission calculated from a percentage (on a transfer, or when a payment starts from a percentage usual fee) is rounded half up to the nearest piastre. No bank secrets, no sign-in, no real payments. Balances are derived, not stored. Destructive delete and deactivate ask for confirmation. A transfer commission is optional piastres on the same row, from a fixed amount or a percentage the person enters, never a looked-up tariff. A usual fee on an account is optional fixed piastres or an optional percentage and is not itself a balance change

**Scale/Scope**: One person, one device, dozens of accounts and categories, up to 5,000 transactions. Seven user stories. No backup, suggestions, or budgets in the original Phase 0 plan. The 2026-10-16 amendment adds one optional fee field to transfers and to bank or e-wallet expenses. The 2026-10-17 amendment adds one optional usual fee on the account and prefills the existing fee field. The 2026-10-20 amendments add a fixed-or-percentage choice on a transfer and the same choice on the account’s usual fee. None of these amendments adds a screen

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Gates below are `.specify/memory/constitution.md` version 2.2.0, the same text as `.cursor/rules/00-project-constitution.mdc`.

| Gate | Result |
|---|---|
| I. Feature-first layers: presentation → domain ← data. Domain has no Flutter, Dio, or data imports | Pass. One `fenzo` feature. `lib/features/profile/` is not in this repo; `fenzo` uses the prescribed tree |
| II. GetIt through `ServiceLocator`. Feature types registered on the route via `FeatureScope`, not in `ServiceLocator.init()`. Cubits `registerFactory`. Use cases, repository, data source `registerLazySingleton` | Pass. Database registration lives in the fenzo scope |
| III. Cubit per user action, `f` prefix, immutable `ApiCallState<T>`, widgets dispatch with `context.read` and do not call the data source | Pass. Confirm dialogs stay in the widget and only then call `f…` |
| IV. `Either<Failure, T>` from `package:either/either.dart`, not `dartz`. Data source throws `AppException`. Repository maps to `Failure` | Pass. `either` is the path package `packages/either` |
| V. Models map to entities. `fromJson` stays in data. Domain stays pure Dart | Pass. Drift rows map in the data layer. No separate mapper class |
| Use cases extend `UseCase<Type, Params>` | Pass. One use case per repository method |
| Tests for use cases, repository, and cubit success/error. `flutter analyze` clean | Pass. Required before the feature is done |
| No service between cubit and use case, no `BaseCubit` / `BaseRepository` | Pass |
| Local packages `either`, `themes`, `language`, `screen_util`, `field_validator` | Pass. Root `pubspec.yaml` path-depends on `packages/<name>`. Presentation uses those packages instead of pub.dev duplicates |
| VI. Shared app codebase | Pass. Fenzo reuses `lib/core`, `lib/config`, and `lib/shared`. It does not add a second `Failure`, `UseCase`, `ApiCallState`, `FeatureScope`, router, or string table. Local fenzo data does not call Dio |
| HTTP / Dio remote data source | Not applicable. The constitution allows local I/O in the data source. Phase 0 must work offline, so the fenzo data source is local only |

## Project Structure

### Documentation (this feature)

```text
specs/001-phase0-mvp/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── accounts.md
│   ├── transactions.md
│   └── dashboard-and-reports.md
└── tasks.md             # /speckit-tasks — not created here
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── injection_container.dart          # ServiceLocator.init(); no fenzo types
├── core/
│   ├── error/                        # Failure, AppException
│   ├── usecase/usecase.dart
│   └── presentation/                 # ApiCallState, FeatureScope
├── features/fenzo/
│   ├── fenzo_injection.dart
│   ├── data/
│   │   ├── datasources/              # Drift local data source + seed
│   │   ├── models/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/                 # Account, Category, Transaction, Money, CalendarDate
│   │   ├── repositories/
│   │   └── usecases/
│   └── presentation/
│       ├── controller/<operation>/   # one cubit + part-file state
│       ├── navigation/
│       ├── pages/
│       └── widgets/
packages/either/                      # package:either/either.dart
test/
├── features/fenzo/domain/
├── features/fenzo/data/
├── features/fenzo/presentation/
└── widget_test.dart
```

**Structure Decision**: Single Flutter app. Phase 0 is the `fenzo` feature plus the small core types the constitution requires (`ServiceLocator`, `UseCase`, `ApiCallState`, `FeatureScope`, `Failure`). Operations, each with its own cubit and use case:

- Save, deactivate, reactivate, and delete account; get accounts
- Save income, save expense, save transfer, update transaction, delete transaction
- Save, deactivate, and delete category; get categories
- Get dashboard, get report, search transactions

Screens follow [contracts/](contracts/). The balance formula lives in the domain and is the only implementation of [data-model.md](data-model.md) derived figures. Widgets format those results; they do not recompute them.

## Post-Design Constitution Check

Re-checked after [research.md](research.md), [data-model.md](data-model.md), and [contracts/](contracts/).

| Gate | Result |
|---|---|
| Domain purity | Pass. Entities and the balance formula have no Drift, Flutter, or JSON |
| Dependency direction | Pass. Cubits depend on use cases. The repository implementation depends on the local data source. Contracts describe screens, not SQL |
| Either and exceptions | Pass. Validation failures (third decimal place, locked account type, end before start, used category delete) are `Failure` values, not raw database errors |
| Scope | Pass. No backup, sync, AI, or budget types in the model |
| Unresolved clarifications | None |
| 2026-10-16 commission | Pass. The fee is a field on the existing transaction entity. `saveMovement` returns `ValidationFailure`. Existing save cubits keep calling their use cases. Reports stay derived in `report_calculator.dart`. No second repository, no Dio, no tariff service |
| 2026-10-17 usual fee | Pass. The usual fee is a field on the existing account entity. `saveAccount` returns `ValidationFailure` for a negative amount. The existing save-account cubit keeps calling its use case. The transaction form only prefills `commissionMinor`. Balances stay derived and ignore the usual fee until a saved row carries it |
| 2026-10-20 percentage transfer fee | Pass. The basis and the rate are fields on the existing transaction entity. `saveMovement` returns `ValidationFailure` for a percentage on a non-transfer and writes the rounded piastres itself. Existing save and update cubits keep calling their use cases. Reports still sum `commissionMinor`. No second calculator, no new cubit, no Dio, no tariff lookup |
| 2026-10-20 percentage usual fee | Pass. The basis and the rate are fields on the existing account entity. `saveAccount` returns `ValidationFailure` for a negative rate. Prefill still lives in the transaction and account forms. Expenses stay fixed when saved. One shared `percentageCommissionMinor` function. No new cubit, no Dio, no tariff lookup |

## Complexity Tracking

No constitution violations require justification.
