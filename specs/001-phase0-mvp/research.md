# Phase 0 Research: Personal Money Tracking

## 1. Local storage

- **Decision**: Persist the fenzo with Drift on SQLite, in a single on-device database file.
- **Rationale**: Accounts, categories, and transactions are relational. Reports filter by date, account, type, and category, and a used category must not be erasable. SQLite keeps that integrity on device with no network, and a few thousand rows stay well inside the two-second report goal.
- **Alternatives considered**: Raw `sqflite` (same engine, more hand-written schema risk). Hive or Isar (weaker foreign keys for “disable instead of delete”). Memory only (fails the requirement that records survive a restart).

## 2. Money representation

- **Decision**: Store every amount as a 64-bit integer of piastres (1 EGP = 100 piastres). Parse user input in the domain. Reject more than two decimal places. Never round to fit.
- **Rationale**: The spec requires exact pounds and piastres, including 12.50, and forbids silent rounding. Binary floating point cannot represent tenths exactly, so balances would drift.
- **Alternatives considered**: `double` (rejected). A decimal package (extra dependency for a scale the integer already enforces).

## 3. Where balances are calculated

- **Decision**: Do not store current balance or total money. One domain calculator derives them from the opening balance and the transaction list. The local database stores facts only.
- **Rationale**: The spec requires that every add, edit, and delete leaves balances equal to opening balance + income − expenses + transfers in − transfers out. A stored balance is a second source of truth and is the main way those figures drift.
- **Alternatives considered**: Stored balance updated on every write (faster reads, easy to desync). Stored balance plus a rebuild job (two mechanisms for one rule).

## 4. How a transfer is stored

- **Decision**: One transaction row with a source account and a destination account. It has no category.
- **Rationale**: A transfer is one user action. Two linked rows can save one side and fail the other, which would change total money by accident.
- **Alternatives considered**: A pair of expense and income rows (would pollute income and expense totals). Two transfer rows kept in sync (partial-write risk).

## 5. Opening balance

- **Decision**: Opening balance and opening date are fields of the account. They are never inserted as a transaction.
- **Rationale**: The spec says the opening balance is not income and must not appear in income totals. Keeping it off the transaction list makes that rule structural.
- **Alternatives considered**: A special transaction type excluded by every report query (one missed filter treats it as income).

## 6. Feature boundaries

- **Decision**: One feature, `fenzo`, with one repository and one use case per repository method. Cubits stay one per user action.
- **Rationale**: Accounts, categories, transactions, the dashboard, and reports share one consistency model. Splitting them into features would force those features to import each other. The constitution still gets granular cubits and use cases inside the one feature.
- **Alternatives considered**: Separate account, transaction, category, and report features (cross-feature coupling). One god cubit for the whole fenzo (forbidden by the constitution).

## 7. Either and other shared packages

- **Decision**: Path-depend on `packages/either`, `packages/themes`, `packages/language`, `packages/screen_util`, and `packages/field_validator`. Do not add `dartz` or pub.dev copies of those packages.
- **Rationale**: Constitution 2.1.0 requires those path dependencies. `either` is the failure type. Theme, locale, responsive spacing, and form-field checks come from the matching local package. Domain money parsing still rejects a third decimal place; `field_validator` checks form input, it does not replace `Money`.
- **Alternatives considered**: `dartz` (explicitly forbidden). Leaving theme, locale, spacing, and validation inside the app (duplicates packages that already exist under `packages/`).

## 8. Remote access

- **Decision**: Phase 0 has a local data source only. No HTTP client, no sign-in, no cloud backup.
- **Rationale**: The spec requires every Phase 0 story to work offline, and backup, sync, and bank connections are later phases.
- **Alternatives considered**: A remote API behind the same repository (adds a network dependency the MVP must not need).

## 9. Navigation and state

- **Decision**: `go_router` for routes. Each fenzo route is wrapped in `FeatureScope`, which registers that route’s cubits and the shared fenzo data layer. `ServiceLocator.init()` does not register feature types. Cubit states for loads and saves are `ApiCallState<T>`. Public cubit methods use the `f` prefix. Confirmation dialogs stay in the widget; the cubit runs only after the person confirms.
- **Rationale**: Matches the constitution’s injection, cubit, and route-scope rules. A dialog is a UI decision, not a domain rule.
- **Alternatives considered**: Registering the database in `ServiceLocator.init()` (leaves a feature singleton for the whole process). Imperative `Navigator` only (harder to keep each route’s scope explicit).

## 10. Language and dates

- **Decision**: The only locale is Arabic (`ar`), which lays the interface out right to left. Calendar dates are local dates with no time of day, stored as `YYYY-MM-DD`. “Today”, “this month”, and “this week” use the device’s local calendar. A week is the Saturday–Friday span that contains today.
- **Rationale**: The spec fixes Arabic RTL and Saturday–Friday. A date-only value avoids timezone shifts moving a transaction into the wrong day.
- **Alternatives considered**: Storing UTC timestamps (a late-evening entry can land on the next day). Monday–Sunday weeks (rejected in clarification).

## 11. Ordering, search, percentages, and invalid ranges

- **Decision**:
  - Newest-first order is transaction date descending, then time saved descending.
  - Search trims the query and matches a case-insensitive substring of the description, notes, account name, category name, or subcategory name. There is no stemming.
  - A non-zero share is shown to one decimal place, half up. A zero denominator is shown as `0%`.
  - A custom range whose end is before its start is rejected and does not run a report.
- **Rationale**: These were left open because they do not change scope. They do change tests, so the plan fixes them here.
- **Alternatives considered**: Whole-word search (misses Arabic prefixes and partial notes). Nearest whole percent only (hides a 1-out-of-3 split as 33% or 33.3% inconsistently). Swapping a reversed range silently (the person would not see the mistake).

## 12. Deactivation and inclusion in the total

- **Decision**: Deactivating an account sets it inactive and removes it from total money. Reactivating it makes it active again and does not put it back into the total until the person includes it. Changing type is allowed only when the account has no transactions; inapplicable labels are cleared in the same save.
- **Rationale**: Matches the clarified dashboard rule and the “include it again” rule without a second hidden flag.
- **Alternatives considered**: Leaving a deactivated account inside the total (the dashboard total would include an account the dashboard does not list, unless the person had opted in). Auto-including an account on reactivate (contradicts “unless the person includes it again”).

## 13. Where a transfer commission is stored

- **Decision**: Add `commissionMinor` to the existing transaction. It is an integer of piastres, zero or greater, default 0. The moved or paid amount stays in `amountMinor`. One save writes both. Drift schema moves from version 1 to version 2 with `commission_minor INTEGER NOT NULL DEFAULT 0`, so rows already on the device become zero.
- **Rationale**: The spec requires one sitting, separate figures, and a delete that removes both the principal and the fee. A second row can be saved without the other and would change balances halfway. A default of 0 keeps every existing balance identical until the person edits a row.
- **Alternatives considered**: A paired expense row under رسوم تحويل (partial-write risk, and a transfer would no longer be one action). A percentage or bank tariff table (the spec says the person types the fee). Storing the fee only in notes (reports could not add it exactly).

## 14. Which rows may carry a fee

- **Decision**: `saveMovement` accepts a commission on every transfer, and on an expense whose account type is `bank` or `eWallet`. Income, cash, and `other` reject a commission greater than zero with `ValidationFailure` and do not write. A blank field is sent as 0. A negative commission is rejected. More than two decimal places is rejected by the existing money parser before it becomes piastres. A commission larger than the principal is allowed.
- **Rationale**: This matches the 2026-10-16 clarification. The widget hides the field in the disallowed cases, but the book is the check, so a cubit test can prove the rejection without the screen.
- **Alternatives considered**: Enforcing the rule only in the form (a caller could still save a fee on cash). Treating cash transfers as fee-free (the spec allows a fee on every move between the person’s accounts).

## 15. How the fee changes balances and reports

- **Decision**: Keep balances derived. For an expense, the paying account decreases by `amountMinor + commissionMinor`. For a transfer, the destination increases by `amountMinor` only, and the source decreases by `amountMinor + commissionMinor`. Transfer in and transfer out on the account report use `amountMinor` only. Period expenses, the net result, and that account’s expenses include `commissionMinor`. The payment’s own category total includes `amountMinor` only. Every `commissionMinor` in the period is added to the seed category `رسوم تحويل` (`id`: `seed-expense-رسوم تحويل`), even though the transaction’s `categoryId` is unchanged. A transfer’s `categoryId` stays null. Total money changes by the fee only when the charged account is included; an excluded account follows the inclusion rule already in `totalMoneyMinor`.
- **Rationale**: The destination is not shorted. The moved amount stays out of income and expenses. The fee is the only new spending. Putting the fee in `categoryId` would replace the category the person chose for the purchase.
- **Alternatives considered**: Subtracting the fee from the amount the destination receives (rejected in clarification). Adding the fee to transfers out (the account report would no longer match the moved amount). A stored balance column (still rejected; the calculator is the only formula).

## 16. The fee category and older book copies

- **Decision**: If categories already exist, do not rerun the full seed. Insert `رسوم تحويل` only when that stable id is missing. The expense picker does not offer it, and a normal expense cannot be saved with that id. The person may rename it; commissions keep using the id and reports show the current name. A backup or export writes `commission_minor`. A copy that has no such key restores as 0.
- **Rationale**: Existing books already have categories, so the current “seed only when empty” path would never add the fee category. Older copies must still open. A missing key means “no fee”, which is the pre-amendment book.
- **Alternatives considered**: A second seed pass that resets every ready-made name (would undo renames). Refusing to restore a copy that lacks the key (would strand books saved before this amendment). Letting the person file the fee under any category (the spec fixes the category).

## 17. Usual fee stored on the account

- **Decision**: Add `defaultCommissionMinor` to the existing account. It is integer piastres, zero or greater, default 0. Drift schema moves from version 2 to version 3 with `default_commission_minor INTEGER NOT NULL DEFAULT 0` on `account_rows`. The version 1 to 2 `commission_minor` upgrade remains. `AccountModel.toJson` writes `default_commission_minor`. A missing key reads as 0. `toCompanion` must pass `Value(defaultCommissionMinor)` so a non-zero usual fee is not dropped by the insert default. `saveAccount` rejects a negative value and does not write. More than two decimal places is rejected by the existing money parser. Changing the account type does not clear this field. `saveMovement` does not read it.
- **Rationale**: The spec asks for a usual amount on the account that starts the next qualifying record and can still be cleared. If `saveMovement` copied the usual fee whenever the sent fee was 0, the person could not save a zero fee on an account whose usual fee is greater than zero. The form is the place that fills the field: a new bank or e-wallet expense uses the paying account, a new transfer uses the source only, and changing that account before save replaces the starting fee when a fee is allowed. A saved row opens with its own `commissionMinor`. Cash and `other` expenses keep the field hidden. The usual fee is not added to the balance formula.
- **Alternatives considered**: A percentage of the payment (the spec says an amount). Adding the source and destination usual fees (the fee is taken from the source only). Rewriting saved rows when the usual fee changes (the spec keeps history). A new cubit or feature (the account save path already exists).
