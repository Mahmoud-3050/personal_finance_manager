# Contract: Transactions and Categories

Screen behavior for income, expense, transfer, and categories. Amount and date rules are in [data-model.md](../data-model.md).

## Record

- Income requires amount, active account, income category, and date. Subcategory, description, and notes are optional.
- Expense requires amount, active account, expense category, and date. Subcategory, description, and notes are optional.
- Transfer requires amount, two different active accounts, and date. Notes are optional. No category.
- The person chooses the category. Nothing assigns or rewrites one.
- Saving 12.50 changes the balance by exactly 12.50 EGP.
- Zero, a negative transaction amount, or more than two decimal places is rejected and not saved.
- A date before the account’s opening date is rejected. For a transfer, the date must be on or after both opening dates.
- An expense or transfer larger than the balance is saved, and the balance is shown as negative.
- Income categories are not offered for an expense, and expense categories are not offered for income.
- Deactivated accounts are not offered.

## Edit and delete

- Edit of amount, account, category, subcategory, date, or notes does not ask for confirmation. Balances and reports follow the saved row.
- Delete asks for confirmation.
- **Given** delete is confirmed, **then** the row no longer affects balances or reports.
- **Given** delete is cancelled, **then** the row and balances stay as they were.

## Transfer outcomes

- The source decreases and the destination increases by the same amount.
- The transfer appears as a transfer, not as income or expense.
- **Given** both accounts are included in total money, **then** total money is unchanged and expenses do not increase.
- **Given** only the source is included, **then** total money decreases by the amount and the row is still not an expense.

## Categories

- First use offers the Arabic seed set, including مواصلات / وقود, before any custom category is added.
- The person can add and rename categories and subcategories.
- A used category or subcategory is disabled rather than erased. Old transactions still show its name. New transactions cannot select it.
- An unused category or subcategory can be removed.
- Disabling or removing a category does not use the transaction-delete confirmation. That confirmation is only for deleting a transaction, deleting an empty account, or deactivating an account.

## Find

- Search and filters do not change stored rows.
- Combined filters keep a row only when it matches every selected filter.
- No matches shows an empty list, not an error.
- Clearing search and filters restores the list for the current screen.
