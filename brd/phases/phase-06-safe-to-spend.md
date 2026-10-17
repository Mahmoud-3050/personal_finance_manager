# Phase 6 — Safe-to-Spend

## Goal

Show a Safe-to-Spend figure on the dashboard, with one line for each amount included or left out, calculated by the accounting code and never by a model.

## BRD coverage

| ID | Statement |
|---|---|
| FR-013 | Calculate Safe-to-Spend and explain the result. |
| BR-004 | Show the starting balance and account for obligations, planned savings, and reserves without double-counting. Explain excluded or uncertain balances. |
| BR-009 | The accounting engine is the source of truth. |
| AC-006 | Safe-to-Spend explains which amounts were included or excluded. |

## Depends on

- [Phase 5](phase-05-obligations-and-goals.md) — obligations and savings goals to subtract.
- `totalMoneyMinor` in `lib/shared/domain/services/balance_calculator.dart`. Accounts with `includeInTotal == false` are already omitted there. This phase lists those accounts as exclusions and does not subtract them again.
- Dashboard presentation in `lib/features/dashboard/`. The figure is a block on the current dashboard, not a new app section.

## Decisions needed

| Decision | Working default | Blocks this phase? |
|---|---|---|
| Safe-to-Spend lines | The proposal below. Do not write the calculator until the product owner accepts or edits it. | Yes. Screens and entities from phase 5 can exist before this confirmation. The calculator cannot. |

Proposed lines, matching the implementation plan:

- Start from `totalMoneyMinor` (accounts included in the total).
- List accounts left out because `includeInTotal` is false. Do not subtract them again.
- Subtract obligations that are due and not already recorded as expenses, so a paid bill is not counted twice.
- Subtract the still-unfilled part of a savings goal only when that money is not already sitting in an account excluded as a reserve.
- Show each line: starting total, each deduction, each exclusion. Unpaid items are labeled as such.

“Due” for this phase means the obligation’s next due date is today or earlier, and no expense with the same amount and a note or category match has been recorded on or after the previous due date. The exact match rule is part of the confirmation, because a weak match would double-count.

## In scope

- A pure-Dart calculator that returns the figure plus an ordered list of explanation lines.
- A dashboard block that renders those lines in minor-unit money, formatted like the other totals.
- A get use case and cubit on the dashboard feature that loads accounts, transactions, obligations, and goals, then calls the calculator. The widget does not do the arithmetic.

## Out of scope

- Editing obligations or goals from this block. Those stay in phase 5.
- Forecasting to the next salary (phase 8). That screen may reuse the figure later.
- AI-written explanations. The lines come from the calculator (BR-009).
- Changing `totalMoneyMinor` or the meaning of `includeInTotal`.

## Layers and files

```text
lib/shared/domain/entities/safe_to_spend.dart          # figure + explanation lines
lib/shared/domain/services/safe_to_spend_calculator.dart

lib/features/dashboard/
├── domain/usecases/get_safe_to_spend_use_case.dart
└── presentation/
    ├── controller/get_safe_to_spend/
    └── widgets/dashboard_safe_to_spend.dart
```

`Obligation` and `SavingsGoal` move to `lib/shared/domain/entities/` in this phase, because the calculator and the dashboard both read them.

- `registerGetSafeToSpend` is added to `lib/features/dashboard/dashboard_injection.dart`. The cubit is a factory. The use case is a lazy singleton.
- No new route. `GetSafeToSpendCubit.fGetSafeToSpend` uses `ApiCallState`. `DashboardLoaded` shows the widget from that state.
- The calculator is a function or a small class in `lib/shared/domain/services/`. It does not import Flutter, Drift, or a feature data layer.

## Data changes

No new table and no schema bump. The result is derived on read, the same way balances are.

Backup snapshot is unchanged beyond what phase 5 already added.

## Strings

Add keys in `assets/lang/en.json` and `assets/lang/ar.json` for the Safe-to-Spend title, starting total, obligation deduction, savings deduction, excluded account, and the unpaid label. Wire them through `lib/config/language/strings.dart`.

## Tests

- Calculator: starting total equals `totalMoneyMinor`.
- Calculator: an excluded account appears as an exclusion line and is not subtracted a second time (BR-004).
- Calculator: a due unpaid obligation is subtracted once. An obligation already matched by an expense is not subtracted (no double-count).
- Calculator: the unfilled part of a goal linked to an excluded reserve account is not subtracted again.
- The explanation list contains every included and excluded amount (AC-006).
- Cubit success and error.
- The calculator has no Flutter import and returns minor units only (BR-009).

## Done when

- [ ] The product owner has confirmed the lines above, or a written replacement of them.
- [ ] The dashboard shows the figure and every line (FR-013, AC-006).
- [ ] Exclusions and deductions are not applied twice (BR-004).
- [ ] The number comes from the calculator, not from a suggestion (BR-009).
- [ ] Tests above pass, and both language files contain the new keys.

## Estimate

1 week after the formula is confirmed. The rest of the BRD window for this area (weeks 11–13) is phase 5.
