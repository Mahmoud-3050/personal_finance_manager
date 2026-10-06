# Contract: Accounts

Screen behavior for creating, editing, listing, and retiring accounts. Rules and fields are in [data-model.md](../data-model.md).

## First launch

- **Given** no account exists, **when** the app opens, **then** the person is asked to add the first account and cannot save a transaction.

## Create

- **Given** a valid name, type, opening balance, and opening date, **when** the person saves, **then** the account is active, included in total money, and its current balance equals the opening balance.
- Bank name and account number are optional and only for a bank account.
- Phone number is optional and only for an e-wallet.
- The opening balance is not listed as income.

## Account list and dashboard

- The account list shows active and deactivated accounts.
- The dashboard lists active accounts only, each with its current balance.
- Total money is the sum of included accounts only.
- Excluding an account removes it from the total and leaves its own balance visible on the account.

## Edit

- Name, type-specific labels, opening balance, opening date, and inclusion can be edited without a confirmation dialog.
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
