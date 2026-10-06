# Phase 0 Data Model

Logical model for the on-device fenzo. Physical tables follow this model in the data layer. Domain code sees the entities below and does not see SQL.

Amounts are piastres (`int`). Display divides by 100 and always shows two decimal places. See [research.md](research.md).

## Money

Value object, not a table.

| Rule | Detail |
|---|---|
| Scale | 100 piastres = 1 EGP |
| Transaction amount | Integer > 0 |
| Opening balance | Integer, may be negative, zero, or positive |
| Input | At most two decimal places; a third place is rejected and not rounded |
| Currency column | None. Phase 0 is EGP only |

## CalendarDate

Value object, not a table. A local calendar day `YYYY-MM-DD` with no time.

| Preset | Range |
|---|---|
| Today | The device’s local date |
| This week | Saturday through Friday that contains today, both ends included |
| This month | First through last day of the local calendar month |
| Custom | Start and end inclusive. End before start is invalid |

## Account

A place that holds money.

| Field | Required | Notes |
|---|---|---|
| id | yes | Stable identity. Display name is not unique |
| name | yes | Non-empty after trim. Duplicates allowed |
| type | yes | `bank`, `eWallet`, `cash`, `other` |
| bankName | no | Bank type only. Cleared when the type changes away from bank |
| accountNumber | no | Bank type only. Identifying label, never a secret |
| phoneNumber | no | E-wallet type only. Cleared when the type changes away from e-wallet |
| openingBalanceMinor | yes | Piastres. Not income |
| openingDate | yes | First day this account can have transactions |
| isActive | yes | New accounts start active |
| includeInTotal | yes | New accounts start included |
| createdAt | yes | Used only as a tie-break, not as a money date |
| updatedAt | yes | |

### Relationships

- An account has many transactions as the income/expense account, the transfer source, or the transfer destination.
- Opening balance is part of the account, not a transaction.

### State

```text
active + included        (default after create)
active + excluded        (person turns inclusion off)
inactive + excluded      (deactivate; this is the automatic result)
inactive + included      (person later includes a deactivated account)
```

| Action | Allowed when | Result |
|---|---|---|
| Create | Name, type, opening balance, and opening date are valid | Active, included in total |
| Edit name, labels, opening balance, opening date, inclusion | Always, except the opening-date rule below | Labels that do not match the type are not kept |
| Change type | Account has zero transactions | Type changes; labels that do not apply to the new type are cleared |
| Change type | Account has any transaction | Rejected; type unchanged |
| Change opening date | New date is on or before every existing transaction on this account | Balances recalculate because they are derived |
| Change opening date | Any transaction is earlier than the new date | Rejected |
| Deactivate | Person confirms | `isActive = false`, `includeInTotal = false`. History remains |
| Reactivate | Account is inactive | `isActive = true`. `includeInTotal` stays false until the person includes it |
| Delete | Zero transactions, person confirms | Account removed |
| Delete | Any transaction exists | Not offered. Deactivation is the retirement path |

Deactivated accounts do not appear on the dashboard and cannot be chosen for a new income, expense, or transfer. They remain in the account list and in historical reports.

### Derived balance

For one account:

```text
openingBalanceMinor
+ income amounts where accountId = this account
− expense amounts where accountId = this account
+ transfer amounts where toAccountId = this account
− transfer amounts where fromAccountId = this account
```

Total money is the sum of those balances for accounts with `includeInTotal = true`, including a deactivated account only if the person included it again.

There is no stored balance column.

## Category

Classifies income or expense. Ready-made rows are seeded once, when the category store is empty. The person may rename or disable them.

| Field | Required | Notes |
|---|---|---|
| id | yes | |
| name | yes | Non-empty. Arabic for the seed set |
| kind | yes | `income` or `expense`. Never both |
| isActive | yes | |

Seed, income: راتب، عمل حر، نشاط تجاري، هدايا، أخرى.

Seed, expense: طعام، مواصلات، تسوق، فواتير، صحة، تعليم، ترفيه، أسرة، أخرى.

### Subcategory

| Field | Required | Notes |
|---|---|---|
| id | yes | |
| categoryId | yes | Exactly one parent. Parent kind applies to the subcategory |
| name | yes | Non-empty |
| isActive | yes | |

Seed: وقود under مواصلات.

| Action | Allowed when | Result |
|---|---|---|
| Add or rename | Name non-empty; parent exists for a subcategory | Selectable on matching transaction types |
| Deactivate | Category or subcategory has been used | Hidden from new choices. Historical transactions still show the name |
| Delete | Never referenced by a transaction, and (for a category) no child subcategory is referenced | Row removed |
| Delete | Referenced, or a child is referenced | Rejected. Deactivate instead |
| Use on a transaction | Category kind matches income or expense, and subcategory belongs to that category | Both must be active for a new or edited choice |

A disabled category stays readable on old transactions. The product never rewrites a transaction’s category on its own.

## Transaction

One recorded movement. Types: `income`, `expense`, `transfer`.

| Field | Income | Expense | Transfer |
|---|---|---|---|
| id | yes | yes | yes |
| amountMinor | > 0 | > 0 | > 0 |
| date | yes | yes | yes |
| accountId | yes, active | yes, active | no |
| categoryId | yes, income kind | yes, expense kind | no |
| subcategoryId | optional | optional | no |
| fromAccountId | no | no | yes, active, different from destination |
| toAccountId | no | no | yes, active |
| description | optional | optional | no |
| notes | optional | optional | optional |
| createdAt | yes | yes | yes |
| updatedAt | yes | yes | yes |

### Validation

- Date is on or after the opening date of every account the row touches.
- Future dates are allowed. They affect balances immediately and appear only in ranges that contain that date.
- Source and destination of a transfer are different active accounts.
- Amounts larger than the current balance are allowed. The derived balance may be negative.
- Edit and delete are allowed. After a confirmed delete, the row is gone and derived balances change. Cancel does not call delete.
- A transfer is excluded from income totals, expense totals, and net result.
- When both accounts are included in total money, a transfer does not change total money.
- When only one side is included, total money changes by the amount and the transfer is still not income or expense.

### List order

Date descending, then `createdAt` descending. The dashboard’s recent list is the first 10 in that order, across all accounts.

### Search and filters

Search matches a trimmed, case-insensitive substring in description, notes, account name, category name, or subcategory name.

Filters (all optional, combined with AND): date range, account, type (`income`, `expense`, `transfer`), category, subcategory.

No matches is an empty list and zero totals, not an error.

## Report figures

Computed for a valid inclusive date range. Not stored.

| Figure | Definition |
|---|---|
| Period income | Sum of income with `date` inside the range |
| Period expenses | Sum of expenses with `date` inside the range |
| Net result | Period income − period expenses. Transfers excluded |
| Category share | Amount and percentage of the period total for that kind. One decimal place, half up. `0%` when the period total is 0 |
| Account starting balance | Balance from the opening balance plus movements dated before the range. If `openingDate` falls inside the range, starting balance is the opening balance |
| Account ending balance | Starting balance + period income − period expenses + transfers in − transfers out, for that account |
| Total money | Current derived total of included accounts. Not limited to the report range |

An account whose opening date is after the range has no activity in that range.

## What is intentionally absent

No user, session, password, PIN, CVV, or bank login. No payment card. No currency table. No backup snapshot. No category-suggestion record. No budget.
