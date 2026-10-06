# Phase 2 Data Model: Backup and Restore

The device book is unchanged: accounts, categories, subcategories, and transactions stay in the existing store. Balances stay derived. This phase adds backup settings and backup copies. It does not add a second ledger.

## Backup settings

Stored on the device. One row for this person.

| Field | Meaning | Rules |
|---|---|---|
| Schedule | `off`, `daily`, `weekly`, or `monthly` | Default `off`. Weekly uses Saturday–Friday. Monthly uses the calendar month |
| Last attempt at | Date and time of the latest try, or absent | Set for success, failure, and waiting |
| Last success at | Date and time of the latest successful cloud or export copy, or absent | A failure does not clear it |
| Last status | `succeeded`, `failed`, or `waiting` | Waiting means a due cloud copy has not been sent because there is no connection |
| Last source | `manualCloud`, `automaticCloud`, or `export` | Absent until the first attempt |

Validation: `weekly` and `monthly` are calendar periods, not “every 7 days from an arbitrary hour.” The check runs when the finance shell opens.

## Backup copy

A complete snapshot. Not a row in the money tables.

| Field | Meaning | Rules |
|---|---|---|
| Created at | When the copy was made | Required |
| Source | `manualCloud`, `automaticCloud`, or `export` | Required |
| Status | `succeeded`, `failed`, or `waiting` | Only `succeeded` cloud copies appear in the restore list |
| Format version | `1` | Import rejects any other version |
| Body | Accounts, categories, subcategories, transactions | Same records as a saved device book. No bank password, PIN, CVV, or bank sign-in |

Identity: a cloud copy is the object stored for the signed-in person at that `created at` time. The product keeps at most five successful cloud copies. The sixth success deletes the oldest. Export files are not in that count.

State of a cloud attempt:

1. Started while connected → upload the snapshot → `succeeded`, then trim to five.
2. Started while offline, or the upload fails → `failed` or `waiting`. No new cloud object. Device book unchanged.
3. Chosen for restore and confirmed → device book replaced by the body. Cancel → no transition.

## Book snapshot body

Format version 1, JSON, no passphrase:

- `formatVersion`: 1
- `createdAt`: timestamp
- `source`: `manualCloud`, `automaticCloud`, or `export`
- `accounts`, `categories`, `subcategories`, `transactions`: the saved records, using the existing model JSON for each

Import accepts only this shape. Anything else is rejected and the device book stays as it is.

## Relationships

- Backup settings are about the device, not about one account.
- A cloud copy belongs to the identified person. An export file belongs to whoever holds the file.
- Restore and import replace every account, category, subcategory, and transaction. They do not merge and they do not restore one account.

## What is deliberately absent

- No stored balance inside the copy beyond the opening balance already on each account. After restore, balances are derived again.
- No passphrase, no merge ledger, no per-account restore.
- No category-suggestion or budget fields.
