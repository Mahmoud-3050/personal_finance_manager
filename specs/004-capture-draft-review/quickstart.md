# Quickstart: Capture Draft and Review Screen

Prove the review screen against [contracts/review-screen.md](contracts/review-screen.md). Draft rules are in [data-model.md](data-model.md). Saved-record rules stay in [specs/001-phase0-mvp/contracts/transactions.md](../../001-phase0-mvp/contracts/transactions.md).

## Prerequisites

- Flutter SDK matching the app constraint (`>=3.10.0 <4.0.0`).
- One account and one expense category already on the device, plus a second account that is a bank or e-wallet with a usual fee when checking the fee.
- No network is required.

## Run

From the repository root, after the feature’s tests exist:

```bash
flutter test test/features/capture
flutter analyze lib/features/capture
```

`flutter test test/config/language/locale_parity_test.dart` checks that new English and Arabic strings match.

## Device checks

1. Open the transaction list. The existing add action still opens the current form, including transfer. A separate review action opens a blank expense dated today, with no uncertain marks.
2. From a known balance, enter 40.00 as an expense, pick the account and an expense category, confirm, and return to the list. The balance is 40.00 lower and the expense appears once.
3. Open review again, enter 40.00 as income, confirm. The balance is back to the start and the income appears once.
4. Open review, enter 100, discard. The balance and the list match the start. Open review again and the 100 is gone.
5. Enter an amount, leave the screen without confirming, and check the list. Nothing was added.
6. Confirm with the amount empty, with 0, with more than two decimal places, with no account, and with a date before the account’s opening date. Each attempt saves nothing and shows a reason. The draft is still there.
7. On a bank or e-wallet expense, the fee starts as that account’s usual fee. Leave it and confirm: the balance falls by the expense plus the fee, and the fee is separate from the category amount. Clear the fee and confirm another expense: the balance falls by the expense only, and the account’s usual fee is unchanged.
8. Switch that expense to cash, to an account that is neither a bank nor an e-wallet, or to income. The fee field disappears.
9. Switch from an expense category to income. The expense category is cleared.
10. A hand-started draft never shows an uncertain mark and never offers a way to add one. A draft opened with a mark already on the amount shows that mark, and editing the amount leaves the mark in place until confirm or discard.
