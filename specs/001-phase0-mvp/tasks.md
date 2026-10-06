---
description: "Task list for Phase 0 MVP personal money tracking"
---

# Tasks: Phase 0 MVP — Personal Money Tracking

**Input**: Design documents from `/specs/001-phase0-mvp/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Included. plan.md requires use-case, repository, and cubit tests before the feature is done, and quickstart.md names the automated checks. Write each story’s tests first and confirm they fail before the implementation tasks for that story.

**Organization**: Tasks are grouped by user story so each story can be implemented and tested as its own increment.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US7)
- Every task includes a file path

## Path Conventions

- Flutter app at the repository root: `lib/`, `test/`, `packages/either/`
- Ledger feature: `lib/features/ledger/`
- Paths match `specs/001-phase0-mvp/plan.md`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Dependencies and directories the rest of the work compiles against

- [ ] T001 [P] Add `flutter_bloc`, `get_it`, `go_router`, `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`, `path`, `intl`, and `flutter_localizations` to `pubspec.yaml`, plus dev dependencies `bloc_test`, `drift_dev`, and `build_runner`, and path dependencies on `packages/either`, `packages/themes`, `packages/language`, `packages/screen_util`, and `packages/field_validator`
- [ ] T002 [P] Create the local Either package in `packages/either/pubspec.yaml` and `packages/either/lib/either.dart` with `Left`, `Right`, and `fold`
- [ ] T003 [P] Create the directories from `specs/001-phase0-mvp/plan.md` under `lib/core/`, `lib/features/ledger/`, and `test/features/ledger/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared kernel, pure money rules, and the on-device schema. No user story starts before this phase.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 [P] Reuse `Failure`, `ValidationFailure`, and `AppException` from `lib/core/error/failures.dart` and `lib/core/error/exceptions.dart`. Do not add a second failure type
- [ ] T005 [P] Reuse `UseCase`, `Params`, and `NoParams` from `lib/core/usecases/usecase.dart`. Do not add a second use-case base
- [ ] T006 [P] Reuse the sealed `ApiCallState<T>` in `lib/core/presentation/api_call_state.dart`. Do not add a second state base class
- [ ] T007 [P] Reuse `FeatureScope` in `lib/core/di/feature_scope.dart`. Do not add a second scope widget
- [ ] T008 [P] Keep ledger types out of `ServiceLocator.init()` in `lib/injection_container.dart`
- [ ] T009 [P] Add the Arabic UI copy, including the seed category labels, through `lib/config/language/strings.dart` and the `language` package. Do not add a second string table
- [ ] T010 [P] Write failing Money tests (exact 12.50, reject a third decimal place, transaction amount > 0, opening balance may be negative or zero) in `test/features/ledger/domain/money_test.dart`
- [ ] T011 [P] Write failing CalendarDate tests (today, Saturday–Friday week, calendar month, reject end before start) in `test/features/ledger/domain/calendar_date_test.dart`
- [ ] T012 [P] Write failing calculator tests for opening-balance balances, transfer exclusion, and period shares in `test/features/ledger/domain/balance_calculator_test.dart` and `test/features/ledger/domain/report_calculator_test.dart`
- [ ] T013 [P] Write a failing seed test that expects the Arabic income and expense categories, including مواصلات / وقود, in `test/features/ledger/data/category_seed_test.dart`
- [ ] T014 Implement piastre `Money` in `lib/features/ledger/domain/entities/money.dart` so `test/features/ledger/domain/money_test.dart` passes
- [ ] T015 Implement `CalendarDate` and week, month, and custom ranges in `lib/features/ledger/domain/entities/calendar_date.dart` so `test/features/ledger/domain/calendar_date_test.dart` passes
- [ ] T016 Create `Account`, `Category`, `Subcategory`, and `LedgerTransaction` in `lib/features/ledger/domain/entities/account.dart`, `lib/features/ledger/domain/entities/category.dart`, `lib/features/ledger/domain/entities/subcategory.dart`, and `lib/features/ledger/domain/entities/ledger_transaction.dart`
- [ ] T017 Implement derived balances in `lib/features/ledger/domain/services/balance_calculator.dart` so `test/features/ledger/domain/balance_calculator_test.dart` passes
- [ ] T018 Implement period figures, including `0%` when the denominator is zero and one decimal place otherwise, in `lib/features/ledger/domain/services/report_calculator.dart` so `test/features/ledger/domain/report_calculator_test.dart` passes
- [ ] T019 Declare `LedgerRepository` returning `Either<Failure, T>` in `lib/features/ledger/domain/repositories/ledger_repository.dart`
- [ ] T020 [P] Define the Drift tables for accounts, categories, subcategories, and transactions in `lib/features/ledger/data/datasources/ledger_database.dart`
- [ ] T021 [P] Map those rows to entities in `lib/features/ledger/data/models/account_model.dart`, `lib/features/ledger/data/models/category_model.dart`, and `lib/features/ledger/data/models/transaction_model.dart`
- [ ] T022 Implement `LedgerLocalDataSource`, including the one-time Arabic category seed, in `lib/features/ledger/data/datasources/ledger_local_data_source.dart` so `test/features/ledger/data/category_seed_test.dart` passes. Open a file under the app documents directory with `path_provider`, not an in-memory database.
- [ ] T023 Map `AppException` to `Failure` with `RepositoryGuard` from `lib/core/data/repository_guard.dart` in `lib/features/ledger/data/repositories/ledger_repository_impl.dart`
- [ ] T024 Register only the ledger data layer in `lib/features/ledger/ledger_injection.dart`
- [ ] T025 Register ledger routes in `lib/config/routes/app_router.dart` and `lib/config/routes/app_routes.dart`, wrap them with `FeatureScope` from `lib/core/di/feature_scope.dart`, and start the app through `initApp()` in `lib/init_app.dart` and `App` in `lib/app.dart`. Do not add a second router
- [ ] T026 Replace the counter expectation in `test/widget_test.dart` with a smoke test that the Arabic shell builds
- [ ] T027 Generate Drift code for `lib/features/ledger/data/datasources/ledger_database.dart` with `dart run build_runner build --delete-conflicting-outputs`

**Checkpoint**: Money, dates, the balance formula, the empty database, and the Arabic shell exist. Story work can start.

---

## Phase 3: User Story 1 - See where money sits (Priority: P1) 🎯 MVP

**Goal**: The person adds accounts with opening balances, sees each current balance and total money, and can edit, exclude, deactivate, reactivate, or delete an empty account.

**Independent Test**: Add two accounts with opening balances and no income or expense. Each balance equals its opening balance, the total equals the included accounts, and 25,000 EGP is not income. Covers `specs/001-phase0-mvp/contracts/accounts.md`.

### Tests for User Story 1

- [ ] T028 [P] [US1] Write failing account use-case tests in `test/features/ledger/domain/account_use_cases_test.dart`. Cover these cases: the type can change only when the account has no transactions, and labels that do not fit the new type are cleared; an opening date later than an existing transaction is rejected; deactivate sets the account inactive and removes it from total money; reactivate does not put it back into the total.
- [ ] T029 [P] [US1] Write failing account repository tests in `test/features/ledger/data/account_repository_test.dart`. Close the file-backed database, reopen the same file, and assert the account is still there.
- [ ] T030 [P] [US1] Write failing account cubit tests for success and error in `test/features/ledger/presentation/account_cubits_test.dart`
- [ ] T031 [P] [US1] Write failing confirm-versus-cancel tests in `test/features/ledger/presentation/confirm_action_dialog_test.dart`

### Implementation for User Story 1

- [ ] T032 [US1] Persist create, edit, include/exclude, deactivate, reactivate, and empty-account delete in `lib/features/ledger/data/datasources/ledger_local_data_source.dart` and `lib/features/ledger/data/repositories/ledger_repository_impl.dart`. The type can change only when the account has no transactions, and labels that do not fit the new type are cleared. An opening date later than an existing transaction is rejected. Deactivate sets the account inactive and removes it from total money. Reactivate does not put it back into the total.
- [ ] T033 [US1] Create `SaveAccountUseCase`, `DeactivateAccountUseCase`, `ReactivateAccountUseCase`, `DeleteAccountUseCase`, and `GetAccountsUseCase`, each with its params, in `lib/features/ledger/domain/usecases/save_account_use_case.dart`, `lib/features/ledger/domain/usecases/deactivate_account_use_case.dart`, `lib/features/ledger/domain/usecases/reactivate_account_use_case.dart`, `lib/features/ledger/domain/usecases/delete_account_use_case.dart`, and `lib/features/ledger/domain/usecases/get_accounts_use_case.dart`
- [ ] T034 [US1] Create one cubit and part-file state per account action, with `f` methods and `ApiCallState`, under `lib/features/ledger/presentation/controller/save_account/`, `lib/features/ledger/presentation/controller/deactivate_account/`, `lib/features/ledger/presentation/controller/reactivate_account/`, `lib/features/ledger/presentation/controller/delete_account/`, and `lib/features/ledger/presentation/controller/get_accounts/`
- [ ] T035 [US1] Register the account use cases and cubits in `lib/features/ledger/ledger_injection.dart`
- [ ] T036 [US1] Build the confirm dialog in `lib/features/ledger/presentation/widgets/confirm_action_dialog.dart`
- [ ] T037 [US1] Build the account form and account list in `lib/features/ledger/presentation/pages/account_form_page.dart` and `lib/features/ledger/presentation/pages/account_list_page.dart`
- [ ] T038 [US1] Route the first-account empty state and the account list in `lib/features/ledger/presentation/navigation/ledger_router.dart`, and block transaction entry until an account exists

**Checkpoint**: User Story 1 works alone. Opening balances, inclusion, deactivation, and empty-account delete match the account contract.

---

## Phase 4: User Story 2 - Record income and spending (Priority: P1)

**Goal**: The person records, edits, and deletes income and expenses against an active account and a category. Balances follow every confirmed change.

**Independent Test**: From a known opening balance, add one income and one expense, edit one, delete one, and confirm the balance after each step. 12.50 EGP is exact. A third decimal place is rejected. An overspend is allowed and shows a negative balance. Covers the record and edit sections of `specs/001-phase0-mvp/contracts/transactions.md`.

### Tests for User Story 2

- [ ] T039 [P] [US2] Write failing income and expense use-case tests in `test/features/ledger/domain/income_expense_use_cases_test.dart`
- [ ] T040 [P] [US2] Write failing income and expense repository tests in `test/features/ledger/data/income_expense_repository_test.dart`
- [ ] T041 [P] [US2] Write failing income and expense cubit tests for success and error in `test/features/ledger/presentation/income_expense_cubits_test.dart`

### Implementation for User Story 2

- [ ] T042 [US2] Persist income and expense create, edit, and confirmed delete in `lib/features/ledger/data/datasources/ledger_local_data_source.dart` and `lib/features/ledger/data/repositories/ledger_repository_impl.dart`
- [ ] T043 [US2] Create `SaveIncomeUseCase`, `SaveExpenseUseCase`, `UpdateTransactionUseCase`, and `DeleteTransactionUseCase` in `lib/features/ledger/domain/usecases/save_income_use_case.dart`, `lib/features/ledger/domain/usecases/save_expense_use_case.dart`, `lib/features/ledger/domain/usecases/update_transaction_use_case.dart`, and `lib/features/ledger/domain/usecases/delete_transaction_use_case.dart`
- [ ] T044 [US2] Create cubits and part-file states under `lib/features/ledger/presentation/controller/save_income/`, `lib/features/ledger/presentation/controller/save_expense/`, `lib/features/ledger/presentation/controller/update_transaction/`, and `lib/features/ledger/presentation/controller/delete_transaction/`
- [ ] T045 [US2] Register the income and expense use cases and cubits in `lib/features/ledger/ledger_injection.dart`
- [ ] T046 [US2] Build the income and expense form, using the seed categories and active accounts only, in `lib/features/ledger/presentation/pages/transaction_form_page.dart`
- [ ] T047 [US2] Build the transaction history page in `lib/features/ledger/presentation/pages/transaction_list_page.dart`
- [ ] T048 [US2] Add income, expense, edit, and history routes in `lib/features/ledger/presentation/navigation/ledger_router.dart`, and call delete only after `lib/features/ledger/presentation/widgets/confirm_action_dialog.dart` confirms

**Checkpoint**: User Stories 1 and 2 together replace a notebook for income and spending.

---

## Phase 5: User Story 3 - Move money between own accounts (Priority: P2)

**Goal**: A transfer decreases the source, increases the destination, and does not count as income or expense.

**Independent Test**: With two included accounts, record a 1,000 EGP transfer. Both balances change by 1,000, total money is unchanged, and expenses do not increase. Editing the amount or either account updates both balances and still does not count as income or expense. A same-account transfer is rejected. Cancelled delete leaves both balances in place. Covers the transfer section of `specs/001-phase0-mvp/contracts/transactions.md`.

### Tests for User Story 3

- [ ] T049 [P] [US3] Write failing transfer use-case tests in `test/features/ledger/domain/transfer_use_case_test.dart`, including an edit of the amount or either account, and a rejection when the source and destination are the same
- [ ] T050 [P] [US3] Write failing transfer repository tests in `test/features/ledger/data/transfer_repository_test.dart`
- [ ] T051 [P] [US3] Write failing transfer cubit tests for success and error in `test/features/ledger/presentation/transfer_cubit_test.dart`

### Implementation for User Story 3

- [ ] T052 [US3] Persist one transfer row with source and destination in `lib/features/ledger/data/datasources/ledger_local_data_source.dart` and `lib/features/ledger/data/repositories/ledger_repository_impl.dart`
- [ ] T053 [US3] Create `SaveTransferUseCase` in `lib/features/ledger/domain/usecases/save_transfer_use_case.dart`
- [ ] T054 [US3] Extend `UpdateTransactionUseCase` in `lib/features/ledger/domain/usecases/update_transaction_use_case.dart`, and the transfer update in `lib/features/ledger/data/datasources/ledger_local_data_source.dart` and `lib/features/ledger/data/repositories/ledger_repository_impl.dart`, so a transfer edit changes both balances and still does not count as income or expense. Reject a same-account transfer.
- [ ] T055 [US3] Create the transfer cubit and part-file state in `lib/features/ledger/presentation/controller/save_transfer/save_transfer_cubit.dart`
- [ ] T056 [US3] Register the transfer use case and cubit in `lib/features/ledger/ledger_injection.dart`
- [ ] T057 [US3] Add the transfer mode, including opening an existing transfer for edit, to `lib/features/ledger/presentation/pages/transaction_form_page.dart` and its route in `lib/features/ledger/presentation/navigation/ledger_router.dart`

**Checkpoint**: Transfers between the person’s own accounts do not inflate spending.

---

## Phase 6: User Story 4 - Organize transactions by category (Priority: P2)

**Goal**: The person adds, renames, disables, and deletes categories and subcategories without losing history.

**Independent Test**: Record an expense under مواصلات / وقود, add a custom category, disable a used category, and confirm old rows still show the old name while new rows cannot select it. An unused category can be removed. Covers the category section of `specs/001-phase0-mvp/contracts/transactions.md`.

### Tests for User Story 4

- [ ] T058 [P] [US4] Write failing category use-case tests in `test/features/ledger/domain/category_use_cases_test.dart`
- [ ] T059 [P] [US4] Write failing category repository tests in `test/features/ledger/data/category_repository_test.dart`
- [ ] T060 [P] [US4] Write failing category cubit tests for success and error in `test/features/ledger/presentation/category_cubits_test.dart`

### Implementation for User Story 4

- [ ] T061 [US4] Persist category and subcategory add, rename, disable, and unused delete in `lib/features/ledger/data/datasources/ledger_local_data_source.dart` and `lib/features/ledger/data/repositories/ledger_repository_impl.dart`
- [ ] T062 [US4] Create `SaveCategoryUseCase`, `DeactivateCategoryUseCase`, `DeleteCategoryUseCase`, and `GetCategoriesUseCase` in `lib/features/ledger/domain/usecases/save_category_use_case.dart`, `lib/features/ledger/domain/usecases/deactivate_category_use_case.dart`, `lib/features/ledger/domain/usecases/delete_category_use_case.dart`, and `lib/features/ledger/domain/usecases/get_categories_use_case.dart`
- [ ] T063 [US4] Create cubits and part-file states under `lib/features/ledger/presentation/controller/save_category/`, `lib/features/ledger/presentation/controller/deactivate_category/`, `lib/features/ledger/presentation/controller/delete_category/`, and `lib/features/ledger/presentation/controller/get_categories/`
- [ ] T064 [US4] Register the category use cases and cubits in `lib/features/ledger/ledger_injection.dart`
- [ ] T065 [US4] Build category management in `lib/features/ledger/presentation/pages/category_list_page.dart`
- [ ] T066 [US4] Add the category route in `lib/features/ledger/presentation/navigation/ledger_router.dart`

**Checkpoint**: Categories can be managed without breaking older transactions.

---

## Phase 7: User Story 5 - Read the current month at a glance (Priority: P2)

**Goal**: The dashboard shows this calendar month’s income, expenses, and net result, total money, active account balances, the expense split, and the ten newest transactions.

**Independent Test**: With movements inside and outside the current month, the dashboard totals include only the current month, transfers stay out of those totals, deactivated accounts are absent, and opening a figure shows its transactions. Covers `specs/001-phase0-mvp/contracts/dashboard-and-reports.md`.

### Tests for User Story 5

- [ ] T067 [P] [US5] Write failing dashboard use-case tests in `test/features/ledger/domain/get_dashboard_use_case_test.dart`
- [ ] T068 [P] [US5] Write failing dashboard cubit tests for success and error in `test/features/ledger/presentation/get_dashboard_cubit_test.dart`

### Implementation for User Story 5

- [ ] T069 [US5] Create `GetDashboardUseCase` in `lib/features/ledger/domain/usecases/get_dashboard_use_case.dart`, reading through `lib/features/ledger/domain/services/report_calculator.dart` and `lib/features/ledger/domain/services/balance_calculator.dart`
- [ ] T070 [US5] Create the dashboard cubit and part-file state in `lib/features/ledger/presentation/controller/get_dashboard/get_dashboard_cubit.dart`
- [ ] T071 [US5] Register the dashboard use case and cubit in `lib/features/ledger/ledger_injection.dart`
- [ ] T072 [US5] Build the dashboard and its drill-down into `lib/features/ledger/presentation/pages/transaction_list_page.dart` from `lib/features/ledger/presentation/pages/dashboard_page.dart` and `lib/features/ledger/presentation/navigation/ledger_router.dart`

**Checkpoint**: Opening the app answers how this month is going.

---

## Phase 8: User Story 6 - Review any period (Priority: P2)

**Goal**: The person reads income, expenses, net result, category shares, per-account movement, and the transaction list for a day, a Saturday–Friday week, a calendar month, or a custom range.

**Independent Test**: Seed a known September, run 1–30 September, and match every total by hand. “This week” is Saturday through Friday. End before start does not run a report. Total money does not change when the range changes. Covers `specs/001-phase0-mvp/contracts/dashboard-and-reports.md`.

### Tests for User Story 6

- [ ] T073 [P] [US6] Write failing report use-case tests in `test/features/ledger/domain/get_report_use_case_test.dart`
- [ ] T074 [P] [US6] Write failing report cubit tests for success and error in `test/features/ledger/presentation/get_report_cubit_test.dart`

### Implementation for User Story 6

- [ ] T075 [US6] Create `GetReportUseCase` in `lib/features/ledger/domain/usecases/get_report_use_case.dart`
- [ ] T076 [US6] Create the report cubit and part-file state in `lib/features/ledger/presentation/controller/get_report/get_report_cubit.dart`
- [ ] T077 [US6] Register the report use case and cubit in `lib/features/ledger/ledger_injection.dart`
- [ ] T078 [US6] Build presets, custom range, category shares, and the account report in `lib/features/ledger/presentation/pages/report_page.dart` and `lib/features/ledger/presentation/navigation/ledger_router.dart`. The report’s transaction list is `lib/features/ledger/presentation/pages/transaction_list_page.dart` opened with the chosen date range, not a second list inside the report page.

**Checkpoint**: Any day, week, month, or custom range can be checked by hand.

---

## Phase 9: User Story 7 - Find a past transaction (Priority: P3)

**Goal**: The person searches by description, notes, account, category, or subcategory, and combines filters. Filters do not change stored rows.

**Independent Test**: Create rows that differ by notes, account, type, and category. One filter narrows the list. Two filters together keep only rows that match both. No match is an empty list, not an error. Covers the find section of `specs/001-phase0-mvp/contracts/transactions.md`.

### Tests for User Story 7

- [ ] T079 [P] [US7] Write failing search use-case tests in `test/features/ledger/domain/search_transactions_use_case_test.dart`
- [ ] T080 [P] [US7] Write failing search cubit tests for success and empty results in `test/features/ledger/presentation/search_transactions_cubit_test.dart`

### Implementation for User Story 7

- [ ] T081 [US7] Apply trimmed case-insensitive substring search and AND filters in `lib/features/ledger/data/datasources/ledger_local_data_source.dart` and `lib/features/ledger/data/repositories/ledger_repository_impl.dart`
- [ ] T082 [US7] Create `SearchTransactionsUseCase` in `lib/features/ledger/domain/usecases/search_transactions_use_case.dart`
- [ ] T083 [US7] Create the search cubit and part-file state in `lib/features/ledger/presentation/controller/search_transactions/search_transactions_cubit.dart`
- [ ] T084 [US7] Register the search use case and cubit in `lib/features/ledger/ledger_injection.dart`
- [ ] T085 [US7] Add search and combined filters to `lib/features/ledger/presentation/pages/transaction_list_page.dart`. Those filters still apply when `lib/features/ledger/presentation/pages/report_page.dart` opened the list with a date range.

**Checkpoint**: A past transaction can be found without changing it.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Static analysis, the scale check, and the manual quickstart

- [ ] T086 Run `flutter analyze` and clear every issue in `lib/`, `test/`, and `packages/either/`
- [ ] T087 [P] Add a 5,000-transaction report timing assertion in `test/features/ledger/domain/report_calculator_test.dart`
- [ ] T088 Walk the manual pass in `specs/001-phase0-mvp/quickstart.md` on a device in airplane mode and fix any miss against `specs/001-phase0-mvp/contracts/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies. Start immediately.
- **Foundational (Phase 2)**: Depends on Setup. Blocks every user story.
- **User stories (Phases 3–9)**: Depend on Foundational. Then follow the story order below, because several stories extend the same data source and repository files.
- **Polish (Phase 10)**: Depends on the stories you intend to ship.

### User Story Dependencies

- **User Story 1 (P1)**: After Foundational. No other story required. This is the first stop.
- **User Story 2 (P1)**: After User Story 1, because income and expense need an account. Uses the foundational category seed, not User Story 4.
- **User Story 3 (P2)**: After User Story 2. Extends the transaction form and transaction storage.
- **User Story 4 (P2)**: After Foundational for data, and after User Story 2 if you want to disable a category that an expense already uses. Can be built in parallel with User Story 3 only up through its tests (T058–T060). Implementation shares `ledger_local_data_source.dart` with User Story 3, so implement T061 after T052.
- **User Story 5 (P2)**: After User Stories 1, 2, and 3. Category management (User Story 4) is not required for the seed categories on the dashboard.
- **User Story 6 (P2)**: After User Story 5. The report page is separate from the dashboard, but both use the same calculators.
- **User Story 7 (P3)**: After User Story 2’s history page, and after User Story 6 if the report drill-down and search both land on `transaction_list_page.dart`. Implement T085 last among page edits to that file.

### Within Each User Story

- Tests are written and fail before that story’s implementation tasks
- Persistence before use cases
- Use cases before cubits
- Cubits registered before pages
- Pages before routes that open them

### Parallel Opportunities

- T001, T002, and T003 can run together
- T004 through T013 can run together
- After T010 and T011 are failing tests, T014 and T015 can run together
- After T016, T017 and T018 can run together
- T020 and T021 can run together after T016
- All tests inside one user story marked [P] can run together
- User Story 3 and User Story 4 tests can be written at the same time; do not edit `ledger_local_data_source.dart` from both at once

---

## Parallel Example: User Story 1

```bash
# Write the User Story 1 tests together:
# test/features/ledger/domain/account_use_cases_test.dart
# test/features/ledger/data/account_repository_test.dart
# test/features/ledger/presentation/account_cubits_test.dart
# test/features/ledger/presentation/confirm_action_dialog_test.dart

# Then implement in order: data source, use cases, cubits, dialog, pages, router.
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Two accounts, opening balances, total money, exclude, deactivate, and empty delete
5. Demo that increment before recording income

### Incremental Delivery

1. Setup + Foundational
2. User Story 1 → where money sits
3. User Story 2 → daily income and expenses (smallest useful ledger)
4. User Story 3 → transfers that are not expenses
5. User Story 4 → category management
6. User Story 5 → current-month dashboard
7. User Story 6 → any date range
8. User Story 7 → search and combined filters
9. Polish → `flutter analyze`, the 5,000-row check, and `specs/001-phase0-mvp/quickstart.md`

### Parallel Team Strategy

1. Everyone finishes Setup and Foundational together
2. After that, one person owns User Story 1, then User Story 2
3. A second person can write User Story 3 and User Story 4 tests while User Story 2 is implemented, then take the category screens after the shared data-source edits land
4. Dashboard and reports start only after income, expense, and transfer persistence exist

---

## Notes

- [P] tasks use different files and do not depend on an unfinished task
- [US1] through [US7] map to the stories in `specs/001-phase0-mvp/spec.md`
- Balances stay in `lib/features/ledger/domain/services/balance_calculator.dart`. Widgets format them and do not recompute them
- Confirmation dialogs stay in the widget. Cubits run only after confirm
- Phase 0 does not add backup, sync, category suggestions, or budgets
