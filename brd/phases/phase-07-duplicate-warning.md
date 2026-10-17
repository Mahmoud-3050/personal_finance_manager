# Phase 7 — Duplicate warning

## Goal

Warn the user when a new transaction matches one already saved for the same account, amount, and calendar date. The user chooses to keep the new one or cancel. The app never deletes or merges on its own.

## BRD coverage

| ID | Statement |
|---|---|
| FR-016 | Detect and warn about potentially duplicate transactions. Priority: Should. |
| AC-008 | Potential duplicates trigger a warning without unauthorized automatic deletion or merging. |

## Depends on

- Existing income, expense, and transfer save use cases in `lib/features/transactions/domain/usecases/`.
- [Phase 1](phase-01-capture-review.md), so a transaction confirmed from a receipt or voice draft uses the same check. The check belongs on the save path, which both the transaction form and capture confirm call.

Phase 5 and phase 6 are not required.

## Decisions needed

| Decision | Working default | Blocks this phase? |
|---|---|---|
| What counts as a duplicate | Same account, same amount in minor units, and the same calendar date. Category is not part of the match. Transfers match on source account, amount, and date. | No, if this default holds. |

## In scope

- A domain check that returns the existing transaction ids that match, or an empty list.
- The save cubits surface that list before writing, when the caller has not set an explicit “save anyway” flag.
- A confirm dialog. Keep saves the new transaction and leaves the old one. Cancel writes nothing.
- The same dialog for manual entry and for capture confirm.

## Out of scope

- Automatic delete, merge, or edit of the older transaction (AC-008).
- Fuzzy amount matching or merchant-name matching.
- A background scan of the whole book outside of save.

## Layers and files

Extend `lib/features/transactions/`. No new feature.

```text
lib/features/transactions/
├── domain/usecases/find_duplicate_transactions_use_case.dart
└── presentation/widgets/duplicate_transaction_dialog.dart
```

- `registerFindDuplicateTransactions` in `lib/features/transactions/transactions_injection.dart`. The use case is a lazy singleton. No new cubit: the existing save cubits call the use case, then emit a state the page can show the dialog from. If that state does not fit `ApiCallState`, add a small sealed result on the save params (`proceedDespiteDuplicate`) rather than a second state hierarchy.
- The dialog lives in the widget. It does not write. Keep dispatches the existing `fSave…` again with `proceedDespiteDuplicate: true`. Cancel dispatches nothing.
- Capture confirm in phase 1 passes through the same flag.

## Data changes

No new table and no schema bump. The check reads `TransactionRows`.

Backup snapshot is unchanged.

## Strings

Add keys in `assets/lang/en.json` and `assets/lang/ar.json` for the warning title, the short explanation (same account, amount, and date), keep, and cancel. Wire them through `lib/config/language/strings.dart`.

## Tests

- Use case: same account, amount, and date returns the existing id. A different day or amount returns an empty list.
- Save use case: a match without `proceedDespiteDuplicate` does not insert a row.
- Save use case: the same input with `proceedDespiteDuplicate: true` inserts the row and leaves the original row in place (AC-008).
- Cubit: the warning path and the success path.
- Widget or cubit test: cancel leaves the book unchanged.

## Done when

- [ ] Saving a likely duplicate shows a warning (FR-016).
- [ ] Keep stores the new transaction and does not change the old one (AC-008).
- [ ] Cancel stores nothing.
- [ ] Manual save and capture confirm share the check.
- [ ] Tests above pass, and both language files contain the new keys.

## Estimate

0.5 week. A Should item, after the Must capture review path exists.
