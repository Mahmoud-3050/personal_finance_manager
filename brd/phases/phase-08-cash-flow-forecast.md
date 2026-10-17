# Phase 8 — Cash-flow forecast to next salary

## Goal

Show an estimate of money from today until the next salary date, using the current Safe-to-Spend rules plus the obligations due in that window. Every figure is labeled as an estimate.

## BRD coverage

| ID | Statement |
|---|---|
| FR-017 | Forecast cash flow until the next salary date. Priority: Should. |

The BRD risk note applies: forecasts must explain their assumptions and must stay distinct from actual balances.

## Depends on

- [Phase 5](phase-05-obligations-and-goals.md) — obligations due inside the window.
- [Phase 6](phase-06-safe-to-spend.md) — `safe_to_spend_calculator.dart` and its confirmed lines. The forecast starts from that figure so the two screens do not use two formulas (BR-009).
- `lib/shared/domain/services/balance_calculator.dart` for actual balances. Those stay unlabeled as estimates.

## Decisions needed

| Decision | Working default | Blocks this phase? |
|---|---|---|
| Salary date | The BRD does not define it. Default: the user sets one day of the month (1–28) as payday, stored on the device. The next salary date is that day this month, or next month if today is past it. | Yes, until this default is accepted. |
| What the forecast includes | Starting Safe-to-Spend, minus obligations with a next due date on or before the next payday that were not already subtracted by Safe-to-Spend. No guessed income other than the fact of a payday. The payday itself does not add an amount unless the user has recorded a recurring income, which this phase does not invent. | Yes. The screen can be designed before the amounts are coded. |

## In scope

- A payday setting: one day of the month, edited from Settings.
- A forecast calculator that returns the next salary date, the estimated remaining amount, and one line per assumption.
- A report or dashboard block titled as an estimate, visually separate from the actual balance.
- Empty state when payday is not set: explain that, and do not show a number.

## Out of scope

- Predicting variable income or spending from history.
- Decision simulation (FR-018) and an AI coach (FR-019).
- Changing stored balances.
- Reminders on payday.

## Layers and files

```text
lib/shared/domain/services/cash_flow_forecast_calculator.dart
lib/shared/domain/entities/cash_flow_forecast.dart

lib/features/reports/   or dashboard, one place only
├── domain/usecases/get_cash_flow_forecast_use_case.dart
├── domain/usecases/save_payday_use_case.dart
└── presentation/controller/
    ├── get_cash_flow_forecast/
    └── save_payday/
```

Put the screen on the reports page if it is period-like, or under the Safe-to-Spend block if it should be seen daily. Pick one. Do not show it in both.

- Register both actions from that feature’s injection file. Cubits are factories. Use cases are lazy singletons. Not registered in `ServiceLocator.init()`.
- `GetCashFlowForecastCubit.fGetCashFlowForecast` and `SavePaydayCubit.fSavePayday` use `ApiCallState`.
- The calculator is pure Dart and calls the Safe-to-Spend calculator rather than reimplementing deductions.

## Data changes

Store the payday day on the device. A single integer does not need a finance table. Use the existing preferences storage under `lib/core/services/` if that already holds app settings. If it is part of the book the user would want restored, add one field to the backup snapshot in `lib/features/backup/data/models/book_snapshot_model.dart`.

No change to transaction or account tables. `schemaVersion` bumps only if the payday moves into Drift.

## Strings

Add keys in `assets/lang/en.json` and `assets/lang/ar.json` for the estimate title, the assumption that this is not an actual balance, payday label, missing-payday empty state, and each forecast line. Wire them through `lib/config/language/strings.dart`.

## Tests

- Next salary date: payday 25 when today is the 10th is the 25th of this month. When today is the 26th, it is the 25th of next month.
- Missing payday returns no amount.
- An obligation already subtracted by Safe-to-Spend is not subtracted again.
- Every returned line is marked as an estimate.
- Cubit success, the empty state, and error.
- Actual `totalMoneyMinor` is unchanged by loading the forecast.

## Done when

- [ ] The user can set a payday (FR-017).
- [ ] The screen shows an estimate through that date, or an empty state when payday is unset.
- [ ] The estimate is labeled as an estimate and does not replace the real balance.
- [ ] Obligations are not double-counted against Safe-to-Spend.
- [ ] Tests above pass, and both language files contain the new keys.

## Estimate

1.5 weeks after phases 5 and 6 and after the payday default is accepted. A Should item, outside the Must windows.
