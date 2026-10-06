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
