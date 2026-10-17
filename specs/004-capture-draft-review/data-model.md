# Data Model: Capture Draft and Review Screen

The draft is not a database row. Accounts, categories, and the saved income or expense stay on the models the app already has. Field rules for a saved record are the transaction contract in [specs/001-phase0-mvp/contracts/transactions.md](../../001-phase0-mvp/contracts/transactions.md). This file describes only the draft.

## CaptureField

A fixed set: `amount`, `date`, `account`, `category`, `subcategory`, `notes`, `commission`.

A hand-started draft uses an empty set. The person cannot insert or remove a value. Editing the matching field does not change the set.

## CaptureDraft

| Field | Required | Rule |
|---|---|---|
| kind | yes | `income` or `expense`. A hand-started draft is `expense`. Never `transfer`. |
| amountMinor | no, until confirm | Integer minor units. Confirm rejects zero, negative, and more than two decimal places through the existing save. |
| date | yes on a hand-started draft | A calendar date. A hand-started draft uses today. Confirm rejects a date before the account’s opening date through the existing save. |
| accountId | no, until confirm | An active account. Inactive accounts are not offered. |
| categoryId | no, until confirm | Must match `kind`. Switching kind clears a category that belongs to the other kind. |
| subcategoryId | no | Must belong to `categoryId`. Cleared with the category when kind changes and it no longer fits. |
| notes | no | Free text. |
| commissionMinor | only for a bank or e-wallet expense | Absent for income, cash, and `other`. When the field applies, it starts as that account’s usual fee. Blank or zero is saved as zero. Negative, or more than two decimal places, is rejected. Changing the account replaces this value with the new account’s usual fee when a fee applies, or clears it when a fee does not. The account’s stored usual fee is not updated. |
| uncertainFields | yes | Set of `CaptureField`. Empty for a hand-started draft. |

Identity: there is no id. The route holds at most one draft. A saved transaction id is created by the existing save, not by the draft.

## State

```text
absent
  → hand-started draft     (route opened with no extra)
  → supplied draft         (route opened with a CaptureDraft extra)
editing
  → editing                (field changes, including fee and kind)
  → absent                 (discard, leave the route, or confirm succeeds)
editing stays editing      (confirm fails; the book is unchanged)
```

A supplied draft is how a test, and later a receipt or voice phase, shows an uncertain mark. This phase’s own entry always opens a hand-started draft.

## Relationships

- `accountId` points at an existing account. The usual fee is read from that account and copied into `commissionMinor`. It is not a live link.
- `categoryId` and `subcategoryId` point at existing categories. Deactivated categories are not offered for a new choice. The draft does not create categories.
- After confirm, the book contains one income or one expense. The draft is gone. The saved row’s commission follows the transaction rules already in the product: the payment and the fee stay separate, and a fee greater than zero increases spending by both.

## Validation owned here

Capture checks only what the existing save cannot see:

- Kind is income or expense.
- A category or subcategory that does not match the kind is cleared before confirm, not sent.
- Commission is omitted unless the draft is an expense from a bank account or an e-wallet.

Amount, date, active account, category presence, and fee numeric rules are the existing save’s `Failure`. The review screen shows that failure and keeps the draft.
