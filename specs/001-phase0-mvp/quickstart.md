# Phase 0 Quickstart

Validation guide for the fenzo MVP. Behavior contracts:

- [accounts.md](contracts/accounts.md)
- [transactions.md](contracts/transactions.md)
- [dashboard-and-reports.md](contracts/dashboard-and-reports.md)

Field rules and derived figures: [data-model.md](data-model.md).

## Prerequisites

- Flutter stable with Dart `^3.13.4` (see `pubspec.yaml`)
- An Android or iOS device or emulator for the manual pass
- No network, bank account, or sign-in

## Setup

From the repository root, after dependencies and code generation are added by implementation:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

`flutter analyze` must report no issues. `flutter test` must pass.

## Automated checks

Run from the repository root. These tests are the proof for the money rules; do not treat a screenshot as proof.

| Check | What it proves |
|---|---|
| Domain tests for money parsing | 12.50 is exact; a third decimal place is rejected; transaction amounts must be > 0; opening balances may be negative or zero |
| Domain tests for balances | Opening balance is not income. Income, expense, transfer in, and transfer out match [data-model.md](data-model.md). A transfer between two included accounts does not change total money |
| Domain tests for ranges | Week is Saturday–Friday. End before start is invalid. A period that contains the opening date uses that opening balance as the start |
| Repository tests | Confirmed delete removes the row. Cancel is not a repository call. A used category cannot be hard-deleted. Restarting the database keeps the rows |
| Cubit tests | Success and failure paths for save account, save expense, save transfer, and delete. Failure emits an error state and does not claim success |
| Widget test | Delete and deactivate dialogs: confirm continues, cancel leaves the previous figures |

## Manual pass

Use Arabic, right to left. Airplane mode on. Record the figures with a calculator as you go.

1. **Empty start.** Open the app. Confirm there is no way to save a transaction. Add Bank ABC, bank account, opening balance 25,000.00 EGP, start date today. Balance is 25,000.00 and income is 0.
2. **Second account.** Add Vodafone Cash as an e-wallet with opening balance 0. Total money is 25,000.00. Exclude Vodafone Cash. Total money stays 25,000.00 and the wallet still shows 0.
3. **Expense.** Record 12.50 EGP under مواصلات / وقود on Bank ABC. Balance is 24,987.50. Try 12.505 and confirm it is rejected.
4. **Overspend.** Record an expense larger than the balance. The balance is negative and the row is kept.
5. **Transfer.** Include both accounts. Transfer 1,000.00 from Bank ABC to Vodafone Cash. Bank decreases by 1,000.00, wallet increases by 1,000.00, total money is unchanged, and expenses do not include 1,000.00.
6. **Cancel.** Start deleting that transfer and cancel. Balances stay put. Confirm the delete. Balances return to the pre-transfer figures.
7. **Type lock.** Add a transaction on an account, then try to change its type. The type stays. On a new account with no transactions, changing type clears labels that do not fit.
8. **Deactivate.** Deactivate an account that has history and confirm. It disappears from the dashboard, remains in the account list, and is excluded from total money. Cancel a second deactivate attempt and confirm nothing changes.
9. **Dashboard.** With rows in this month and an earlier month, the dashboard totals include only this month. Transfers are outside income, expenses, and net result. Open one category and see only its transactions. At most ten recent rows are shown.
10. **Reports.** Run 1–30 September, or any range you seeded, and match income, expenses, net result, category shares, and the account starting and ending balances by hand. Choose “this week” and confirm it is Saturday through Friday. Set the end date before the start and confirm the report does not run.
11. **Search.** Filter by account and category together. A row must match both. Clear the filters and the wider list returns.
12. **Relaunch.** Force-close the app, turn the network off if it was on, and open it again. The same balances are there. No screen asks for a bank password, PIN, CVV, or login.

## Not part of this pass

Cloud backup, restore, category suggestions, budgets, and a money assistant are out of Phase 0.
