# Contract: Transactions and Categories

Screen behavior for income, expense, transfer, and categories. Amount and date rules are in [data-model.md](../data-model.md).

## Record

- Income requires amount, active account, income category, and date. Subcategory, description, and notes are optional.
- Expense requires amount, active account, expense category, and date. Subcategory, description, and notes are optional.
- Transfer requires amount, two different active accounts, and date. Notes are optional. No category on the moved amount. An optional transfer commission applies to every transfer, whatever the account types.
- Expense from a bank account or e-wallet may include an optional transfer commission. Expense from cash or `other`, and every income, must not.
- The person chooses the category for income and for the payment amount. The commission is not a category they pick. It is always `رسوم تحويل`, and that category is not offered in the expense picker.
- A blank commission is saved as zero. Zero does not change the balance beyond the principal. A negative commission, or more than two decimal places, is rejected and not saved. A commission larger than the principal is allowed.
- On a new bank or e-wallet expense, the fee starts from that paying account’s usual fee: a fixed usual fee starts that money amount, and a percentage usual fee starts the money amount that rate produces from the payment amount. The saved payment keeps a money fee only. On a new transfer, the fee starts from the source account’s usual fee only: a fixed usual fee starts a fixed commission, and a percentage usual fee starts that percentage of the moved amount. Changing that account before save replaces the starting fee with the new account’s usual fee and basis while the commission is still following that auto-filled start. A hand-set transfer rate is left unchanged. The person can change or clear it before saving. The saved row keeps the fee they left.
- On a transfer, the person chooses a fixed amount or a percentage of the moved amount, one at a time. The percentage field is absent on income and on every expense.
- Opening a saved row shows the fee already saved, not the account’s current usual fee.
- **Given** a cash or `other` expense, **when** that account has a usual fee of 5 EGP or 1%, **then** the commission field is still absent and saving does not add a fee. Switching that payment onto a bank or e-wallet starts the fee as that account’s usual fee.
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

## Transfer commission basis

- **Given** a new transfer whose source has a fixed usual fee, **when** the form opens, **then** the commission is a fixed amount equal to that usual fee.
- **Given** a new transfer of 1,000.00 EGP whose source has a 1% usual fee, **when** the form opens and the person leaves the start unchanged, **then** the commission is 1% showing 10.00 EGP, not the destination’s usual fee and not the sum of both.
- **Given** a move of 1,000.00 EGP, **when** the person chooses 1%, **then** the form shows a commission of 10.00 EGP before save. After save, the source decreases by 1,010.00 EGP and the destination increases by 1,000.00 EGP.
- **Given** a percentage is selected, **when** the moved amount changes from 1,000.00 EGP to 2,000.00 EGP, **then** the rate stays 1% and the commission shown becomes 20.00 EGP.
- **Given** a new payment of 200.00 EGP from a bank whose usual fee is 1%, **when** the person leaves the start unchanged, **then** the fee shown is 2.00 EGP and the saved payment stores a money fee of 2.00 EGP, not a percentage.
- **Given** a new transfer still following a 1% usual fee, **when** the source changes to an account with a fixed usual fee of 5.00 EGP, **then** the commission becomes a fixed 5.00 EGP.
- **Given** a transfer percentage the person set by hand, **when** the source changes, **then** that hand-set rate stays.
- **Given** a fixed commission of 5.00 EGP, **when** the moved amount changes, **then** the commission stays 5.00 EGP.
- **Given** a fixed usual fee of 5.00 EGP, **when** the person switches to 1% of 1,000.00 EGP, **then** the commission is 10.00 EGP and the 5.00 EGP is not added.
- **Given** a percentage the person set by hand is selected, **when** the source account changes, **then** the rate stays and is not replaced by the new source’s usual fee.
- **Given** a percentage showing 10.00 EGP is selected and the source’s usual fee is a fixed 5.00 EGP, **when** the person switches back to a fixed amount, **then** the commission becomes 5.00 EGP. **Given** instead the source’s usual fee is 1%, **when** they switch to fixed, **then** the commission becomes a fixed 10.00 EGP.
- A blank percentage is saved as zero. A negative percentage, or one with more than two decimal places, is rejected and not saved. A percentage greater than 100% is allowed. 150% of 1,000.00 EGP is a commission of 1,500.00 EGP.
- A percentage that does not land on a whole 0.01 EGP is rounded half up. 1% of 333.33 EGP is 3.33 EGP. 0.50% of 1.00 EGP is 0.01 EGP. 1% of 0.49 EGP is 0.00 EGP and is not shown as a fee. The saved rate remains.
- **Given** a saved move of 1,000.00 EGP at 1%, **when** the person changes the moved amount to 500.00 EGP and saves, **then** the rate stays 1% and the commission becomes 5.00 EGP.
- **Given** a move saved before a percentage could be chosen, **when** the person opens it, **then** it shows a fixed commission equal to the fee already saved, and neither balance has changed because of the new choice alone.
- A saved percentage row shows the rate and the money fee as separate from the moved amount. A money fee of zero is not shown as a fee.

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
