# Contract: Accounts

Screen behavior for creating, editing, listing, and retiring accounts. Rules and fields are in [data-model.md](../data-model.md).

## First launch

- **Given** no account exists, **when** the app opens, **then** the person is asked to add the first account and cannot save a transaction.

## Create

- **Given** a valid name, type, opening balance, and opening date, **when** the person saves, **then** the account is active, included in total money, and its current balance equals the opening balance.
- A usual transfer commission is optional and is either a fixed amount or a percentage. Blank, 0 EGP, or 0% is stored as a fixed zero. It does not change the current balance.
- A negative usual fee, a negative usual rate, or more than two decimal places on either, is rejected and the account is not saved. A rate greater than 100% is allowed.
- **Given** the person chooses a 1% usual fee and an opening balance of 0, **when** they save, **then** the account keeps a 1% usual fee and the balance stays 0.
- **Given** an account that only had a money usual fee before a percentage could be chosen, **when** the person opens it, **then** it shows a fixed usual fee equal to that money and the balance has not changed because of the new choice alone.
- Bank name and account number are optional and only for a bank account.
- Phone number is optional and only for an e-wallet.
- The opening balance is not listed as income.

## Account list and dashboard

- The account list shows active and deactivated accounts.
- The dashboard lists active accounts only, each with its current balance.
- Total money is the sum of included accounts only.
- Excluding an account removes it from the total and leaves its own balance visible on the account.

## Edit

- Name, type-specific labels, opening balance, opening date, usual fee (basis, amount, or rate), and inclusion can be edited without a confirmation dialog.
- **Given** saved records already used an older usual fee, **when** the usual fee changes to another fixed amount or to a percentage, **then** those records keep the fee that was saved and balances do not change from the account edit alone.
- Changing the account type does not clear the usual fee. It still clears identifying labels that do not apply to the new type.
- **Given** the account has no transactions, **when** the type changes, **then** labels that do not apply to the new type are cleared.
- **Given** the account has a transaction, **when** a type change is attempted, **then** the type stays and the person is told it is fixed.
- **Given** a transaction is earlier than a new opening date, **when** the date change is attempted, **then** it is rejected and those transactions are identified.

## Deactivate, reactivate, delete

- Deactivate and delete ask for confirmation. Cancel changes nothing.
- **Given** confirmation of deactivate, **then** the account leaves the dashboard, stays on the account list, rejects new transactions, and is excluded from total money.
- **Given** the person reactivates it, **then** it can be used again and stays out of the total until they include it.
- **Given** confirmation of delete and the account has no transactions, **then** it is removed.
- **Given** the account has transactions, **then** permanent delete is not offered; deactivation is.

## Out of contract

No bank password, PIN, CVV, or login field exists on any account screen.
