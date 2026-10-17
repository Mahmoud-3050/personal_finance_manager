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
| Domain tests for balances | Opening balance is not income. Income, expense, transfer in, and transfer out match [data-model.md](data-model.md). A transfer between two included accounts with no commission does not change total money. With a commission, the destination changes by the moved amount only, the source changes by the moved amount plus the commission, and total money and expenses change by the commission only |
| Domain tests for the commission | A fee on income, cash, or `other` is rejected and the book is unchanged. A bank or e-wallet expense decreases that account by payment plus fee, and the chosen category changes by the payment only. `رسوم تحويل` receives the fee. A missing fee on an older row is 0 |
| Domain tests for the usual fee | A blank usual fee is 0 and does not change the account balance. A negative usual fee is rejected. Changing the usual fee does not change a fee already saved. An account JSON object without `default_commission_minor` reads as 0 |
| Domain tests for ranges | Week is Saturday–Friday. End before start is invalid. A period that contains the opening date uses that opening balance as the start |
| Repository tests | Confirmed delete removes the row. Cancel is not a repository call. A used category cannot be hard-deleted. Restarting the database keeps the rows |
| Cubit tests | Success and failure paths for save account, save expense, save transfer, and delete. Failure emits an error state and does not claim success |
| Widget test | Delete and deactivate dialogs: confirm continues, cancel leaves the previous figures |

## Manual pass

Use Arabic, right to left. Airplane mode on. Record the figures with a calculator as you go.

1. **Empty start.** Open the app. Confirm there is no way to save a transaction. Add Bank ABC, bank account, opening balance 25,000.00 EGP, usual fee 3.00, start date today. Balance is 25,000.00 and income is 0. The 3.00 is not spending.
2. **Second account.** Add Vodafone Cash as an e-wallet with opening balance 0. Total money is 25,000.00. Exclude Vodafone Cash. Total money stays 25,000.00 and the wallet still shows 0.
3. **Expense.** Record 12.50 EGP under مواصلات / وقود on Bank ABC. Balance is 24,987.50. Try 12.505 and confirm it is rejected.
4. **Overspend.** Record an expense larger than the balance. The balance is negative and the row is kept.
5. **Transfer.** Include both accounts. Transfer 1,000.00 from Bank ABC to Vodafone Cash with the commission left blank. Bank decreases by 1,000.00, wallet increases by 1,000.00, total money is unchanged, and expenses do not include 1,000.00.
5a. **Transfer fee.** Transfer 1,000.00 from Bank ABC to Vodafone Cash with a commission of 5.00. Bank decreases by 1,005.00, the wallet increases by 1,000.00, total money decreases by 5.00, and expenses increase by 5.00 under رسوم تحويل. The moved amount and the fee are both visible on the row. Change the fee to 0 and confirm the 5.00 comes back.
5b. **Payment fee.** Record a 200.00 expense from Bank ABC. The fee starts at the usual 3.00. Leave it and save. The bank decreases by 203.00. The chosen category increases by 200.00 only. Clear the starting fee on a second payment and confirm the bank decreases by the payment only while the usual fee stays 3.00. Repeat a 200.00 expense from a cash account and confirm there is no commission field and the cash account decreases by 200.00.
5c. **Usual fee on a move.** Set Vodafone Cash’s usual fee to 2.00. Start a transfer from Bank ABC to Vodafone Cash. The fee starts at 3.00, not 2.00 and not 5.00. Change Bank ABC’s usual fee to 8.00 and reopen the saved row from step 5a or 5b. That row still shows the fee that was saved.
6. **Cancel.** Start deleting that transfer and cancel. Balances stay put. Confirm the delete. Balances return to the pre-transfer figures.
7. **Type lock.** Add a transaction on an account, then try to change its type. The type stays. On a new account with no transactions, changing type clears labels that do not fit.
8. **Deactivate.** Deactivate an account that has history and confirm. It disappears from the dashboard, remains in the account list, and is excluded from total money. Cancel a second deactivate attempt and confirm nothing changes.
9. **Dashboard.** With rows in this month and an earlier month, the dashboard totals include only this month. The moved amount of a transfer is outside income and expenses. A commission dated this month is inside expenses. Open رسوم تحويل and see the fee, not the moved amount. At most ten recent rows are shown.
10. **Reports.** Run 1–30 September, or any range you seeded, and match income, expenses, net result, category shares, and the account starting and ending balances by hand. Choose “this week” and confirm it is Saturday through Friday. Set the end date before the start and confirm the report does not run.
11. **Search.** Filter by account and category together. A row must match both. Clear the filters and the wider list returns.
12. **Relaunch.** Force-close the app, turn the network off if it was on, and open it again. The same balances are there. No screen asks for a bank password, PIN, CVV, or login.

## Not part of this pass

Cloud backup, restore, category suggestions, budgets, and a money assistant are out of Phase 0.
