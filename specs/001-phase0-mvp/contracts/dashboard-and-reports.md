# Contract: Dashboard and Reports

Read-only behavior. Figure definitions are in [data-model.md](../data-model.md).

## Dashboard

The dashboard period is the current local calendar month.

- Shows that month’s income, expenses, and net result. Transfers are outside all three.
- Shows total money (current, not limited to the month) and each active account’s current balance.
- Does not list deactivated accounts.
- Shows the month’s expenses by category, with amount and share.
- Shows the ten newest transactions across accounts.
- Opening a total, category, or account shows the transactions that make up that figure.
- A month with no transactions shows zero income, expenses, and net result. Account balances still include opening balances and older transactions.

## Report presets

- Today, this week (Saturday through Friday containing today), this calendar month, or a custom inclusive range.
- A custom range can replace any preset.
- End before start is rejected and does not show a report.
- A range with no transactions shows zero totals and empty lists, without an error.

## Report contents

- Financial summary: period income, period expenses, net result. Transfers excluded.
- Expenses by category and subcategory: amount and percentage of period expenses. Income by category: amount and percentage of period income.
- When the relevant total is zero, every share is `0%`. Otherwise shares use one decimal place, half up.
- Account report: starting balance, income, expenses, transfers in, transfers out, ending balance.
- **Given** the account’s opening date falls inside the range, **then** the starting balance is that opening balance and it is still not income.
- Transaction list: income, expenses, and transfers in the range, narrowed by the active search and filters from [transactions.md](transactions.md).
- Total money on the report is the same current included-account total as the dashboard. Changing the range does not change it.

## Offline

Adding an account, recording a transaction, and reading the dashboard and a monthly report complete with no network. Closing and reopening the app shows the same accounts, transactions, categories, and balances.
