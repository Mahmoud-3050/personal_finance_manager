# Phase 5 — Obligations and savings goals

## Goal

Let the user keep basic recurring obligations and savings goals on the device, with a monthly fixed amount and a due day, and no reminders.

## BRD coverage

| ID | Statement |
|---|---|
| FR-012 | Manage basic obligations and savings goals. |

Safe-to-Spend (FR-013) reads these records in [phase 6](phase-06-safe-to-spend.md). This phase only stores and edits them.

## Depends on

No earlier remaining phase. Can start in parallel with [phase 1](phase-01-capture-review.md).

Reuses:

- `lib/core/database/finance_database.dart` for the new tables
- `lib/features/backup/data/models/book_snapshot_model.dart` so a restore keeps the new rows
- Account list, only as an optional link on a savings goal
- `lib/config/routes/app_routes.dart` and `FeatureScope`

## Decisions needed

| Decision | Working default | Blocks this phase? |
|---|---|---|
| Obligation types and reminders | Monthly fixed amount and a due day. No push reminder. | No, if this default holds. |
| Multiple currencies | One currency, integer minor units, same as transactions. | No |

## In scope

Two features. They do not import each other’s data layer.

**Obligations** — name, amount in minor units, monthly due day (1–28), next due date, active flag.

**Savings goals** — name, target amount in minor units, amount already set aside, optional linked account id, active flag.

List, create, edit, and deactivate for each. Deactivate keeps the row. Delete is only for a row that nothing else references.

## Out of scope

- Push or local notifications.
- Weekly, yearly, or variable amounts.
- Marking an obligation paid by creating an expense automatically. Paying stays a normal expense in the transactions feature, so phase 6 can avoid counting it twice.
- Safe-to-Spend math (phase 6).
- Transfers into a goal account. The user records those with the existing transfer form.

## Layers and files

```text
lib/features/obligations/
├── obligations_injection.dart
├── domain/entities/obligation.dart
├── domain/repositories/obligations_repository.dart
├── domain/usecases/
│   ├── get_obligations_use_case.dart
│   ├── save_obligation_use_case.dart
│   └── deactivate_obligation_use_case.dart
├── data/...
└── presentation/controller/   # one cubit per use case
    pages/obligation_list_page.dart
    pages/obligation_form_page.dart

lib/features/savings_goals/
├── savings_goals_injection.dart
├── domain/entities/savings_goal.dart
├── domain/repositories/savings_goals_repository.dart
├── domain/usecases/
│   ├── get_savings_goals_use_case.dart
│   ├── save_savings_goal_use_case.dart
│   └── deactivate_savings_goal_use_case.dart
├── data/...
└── presentation/...
```

- Each `*_injection.dart` exposes `register*DataLayer` plus one `register*` per action. Cubits are `registerFactory`. Use cases, repositories, and data sources are `registerLazySingleton`. Nothing is registered in `ServiceLocator.init()`.
- Routes `/obligations`, `/obligations/form`, `/savings-goals`, and `/savings-goals/form` in `lib/config/routes/app_routes.dart`. Each route uses `FeatureScope` and `BlocProvider`.
- Cubit actions use the `f` prefix and `ApiCallState`. Widgets dispatch with `context.read`.
- If the dashboard later reads these entities, move `Obligation` and `SavingsGoal` to `lib/shared/domain/entities/` at that time. Until then they stay inside their features.

## Data changes

Add `ObligationRows` and `SavingsGoalRows` to `lib/core/database/finance_database.dart` and bump `schemaVersion`.

Amounts are integers in minor units. Due day is an integer from 1 to 28 so every month has that day.

Extend `lib/features/backup/data/models/book_snapshot_model.dart` in the same change. Export, cloud backup, and restore must round-trip both tables. Restore still replaces the whole book after confirmation. It does not merge.

## Strings

Add list titles, form labels, validation messages (amount greater than zero, due day 1–28, set-aside not above target), and deactivate confirmation to `assets/lang/en.json` and `assets/lang/ar.json`. Wire them through `lib/config/language/strings.dart`.

## Tests

- Save use case: rejects amount of zero or less, and a due day outside 1–28.
- Save use case: a valid monthly obligation and a valid goal persist and reload.
- Deactivate use case: the row remains and `isActive` is false.
- Repository: `AppException` maps to `Left` for both features.
- Cubit success and error for get, save, and deactivate.
- Snapshot test: a book with one obligation and one goal survives export and import.

## Done when

- [ ] The user can add, edit, and deactivate a monthly obligation (FR-012).
- [ ] The user can add, edit, and deactivate a savings goal with a target and an amount set aside (FR-012).
- [ ] Records stay on the device and do not need a connection.
- [ ] Backup and restore include the new rows.
- [ ] Tests above pass, and both language files contain the new keys.

## Estimate

2 weeks. The larger part of the BRD window for Safe-to-Spend, obligations, and goals (weeks 11–13).
