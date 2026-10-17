# Contract: Transactions and Categories

Screen behavior for income, expense, transfer, and categories. Amount and date rules are in [data-model.md](../data-model.md).

## Record

- Income requires amount, active account, income category, and date. Subcategory, description, and notes are optional.
- Expense requires amount, active account, expense category, and date. Subcategory, description, and notes are optional.
- Transfer requires amount, two different active accounts, and date. Notes are optional. No category on the moved amount. An optional transfer commission applies to every transfer, whatever the account types.
- Expense from a bank account or e-wallet may include an optional transfer commission. Expense from cash or `other`, and every income, must not.
- The person chooses the category for income and for the payment amount. The commission is not a category they pick. It is always `رسوم تحويل`, and that category is not offered in the expense picker.
- A blank commission is saved as zero. Zero does not change the balance beyond the principal. A negative commission, or more than two decimal places, is rejected and not saved. A commission larger than the principal is allowed.
- On a new bank or e-wallet expense, the fee starts as that paying account’s usual fee. On a new transfer, the fee starts as the source account’s usual fee only. Changing that account before save replaces the starting fee when a fee is allowed. The person can change or clear it before saving. The saved row keeps the fee they left.
- Opening a saved row shows the fee already saved, not the account’s current usual fee.
- **Given** a cash or `other` expense, **when** that account has a usual fee, **then** the commission field is still absent and saving does not add a fee. Switching that payment onto a bank or e-wallet starts the fee as that account’s usual fee.
- Saving 12.50 changes the balance by exactly 12.50 EGP.
- Zero, a negative transaction amount, or more than two decimal places is rejected and not saved.
- A date before the account’s opening date is rejected. For a transfer, the date must be on or after both opening dates.
- An expense or transfer larger than the balance is saved, and the balance is shown as negative.
- Income categories are not offered for an expense, and expense categories are not offered for income.
- Deactivated accounts are not offered.

## Edit and delete

- Edit of amount, account, category, subcategory, date, notes, or commission does not ask for confirmation. Balances and reports follow the saved row.
- **Given** a bank or e-wallet expense still has a commission greater than zero, **when** the paying account changes to cash or `other`, **then** the save is rejected and the previous row stays.
- Delete asks for confirmation.
- **Given** delete is confirmed, **then** the row no longer affects balances or reports.
- **Given** delete is cancelled, **then** the row and balances stay as they were.

## Transfer outcomes

- With no commission, the source decreases and the destination increases by the same amount.
- The moved amount appears as a transfer, not as income or expense. A commission on that row appears as spending under `رسوم تحويل`, separate from the moved amount.
- **Given** both accounts are included in total money and the commission is zero, **then** total money is unchanged and expenses do not increase.
- **Given** both accounts are included and the commission is greater than zero, **then** the destination increases by the moved amount, the source decreases by the moved amount plus the commission, total money decreases by the commission, and expenses increase by the commission.
- **Given** only the source is included, **then** total money decreases by the moved amount plus the commission, and the moved amount is still not an expense.
- The saved transfer shows the moved amount and the commission as separate figures. A zero commission is not shown as a fee.

## Payment commission

- **Given** a bank account or e-wallet expense, **when** a commission is saved, **then** that account decreases by the payment plus the commission, spending increases by both, and the chosen category increases by the payment only.
- **Given** cash or `other`, **when** the expense form is open, **then** the commission field is absent.

## Categories

- First use offers the Arabic seed set, including مواصلات / وقود and رسوم تحويل, before any custom category is added.
- An existing book that already has categories gains رسوم تحويل when that seed id is missing. Other category names are left as the person saved them.
- The person can add and rename categories and subcategories.
- A used category or subcategory is disabled rather than erased. Old transactions still show its name. New transactions cannot select it.
- An unused category or subcategory can be removed.
- Disabling or removing a category does not use the transaction-delete confirmation. That confirmation is only for deleting a transaction, deleting an empty account, or deactivating an account.

## Find

- Search and filters do not change stored rows.
- Combined filters keep a row only when it matches every selected filter.
- No matches shows an empty list, not an error.
- Clearing search and filters restores the list for the current screen.
