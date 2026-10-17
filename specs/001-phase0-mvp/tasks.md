---
description: "Task list for Phase 0 MVP personal money tracking"
---

# Tasks: Phase 0 MVP — Personal Money Tracking

**Input**: Design documents from `/specs/001-phase0-mvp/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Included. plan.md requires use-case, repository, and cubit tests before the feature is done, and quickstart.md names the automated checks. Write each story’s tests first and confirm they fail before the implementation tasks for that story.

**Amendment 2026-10-16**: Phases 17–23 are the transfer commission. Tasks T001–T114 stay the shipped baseline. Any task marked SUPERSEDED pointed at the retired `lib/features/fenzo/` paths and must not be implemented again.

**Amendment 2026-10-17**: Phases 24–29 are the usual fee stored on each account. Tasks T001–T139 stay as they are. Do not add a new feature folder or a new cubit.

**Organization**: Tasks are grouped by user story so each story can be implemented and tested as its own increment.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US7)
- Every task includes a file path

## Path Conventions

- Flutter app at the repository root: `lib/`, `test/`, `packages/either/`
- Fenzo feature: `lib/features/fenzo/`
- Paths match `specs/001-phase0-mvp/plan.md`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Dependencies and directories the rest of the work compiles against

- [X] T001 [P] Add `flutter_bloc`, `get_it`, `go_router`, `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`, `path`, `intl`, and `flutter_localizations` to `pubspec.yaml`, plus dev dependencies `bloc_test`, `drift_dev`, and `build_runner`, and path dependencies on `packages/either`, `packages/themes`, `packages/language`, `packages/screen_util`, and `packages/field_validator`
- [X] T002 [P] Create the local Either package in `packages/either/pubspec.yaml` and `packages/either/lib/either.dart` with `Left`, `Right`, and `fold`
- [X] T003 [P] Create the directories from `specs/001-phase0-mvp/plan.md` under `lib/core/`, `lib/features/fenzo/`, and `test/features/fenzo/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared kernel, pure money rules, and the on-device schema. No user story starts before this phase.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 [P] Reuse `Failure`, `ValidationFailure`, and `AppException` from `lib/core/error/failures.dart` and `lib/core/error/exceptions.dart`. Do not add a second failure type
- [X] T005 [P] Reuse `UseCase`, `Params`, and `NoParams` from `lib/core/usecases/usecase.dart`. Do not add a second use-case base
- [X] T006 [P] Reuse the sealed `ApiCallState<T>` in `lib/core/presentation/api_call_state.dart`. Do not add a second state base class
- [X] T007 [P] Reuse `FeatureScope` in `lib/core/di/feature_scope.dart`. Do not add a second scope widget
- [X] T008 [P] Keep fenzo types out of `ServiceLocator.init()` in `lib/injection_container.dart`
- [X] T009 [P] Add the Arabic UI copy, including the seed category labels, through `lib/config/language/strings.dart` and the `language` package. Do not add a second string table
- [X] T010 [P] Write failing Money tests (exact 12.50, reject a third decimal place, transaction amount > 0, opening balance may be negative or zero) in `test/features/fenzo/domain/money_test.dart`
- [X] T011 [P] Write failing CalendarDate tests (today, Saturday–Friday week, calendar month, reject end before start) in `test/features/fenzo/domain/calendar_date_test.dart`
- [X] T012 [P] Write failing calculator tests for opening-balance balances, transfer exclusion, and period shares in `test/features/fenzo/domain/balance_calculator_test.dart` and `test/features/fenzo/domain/report_calculator_test.dart`
- [X] T013 [P] Write a failing seed test that expects the Arabic income and expense categories, including مواصلات / وقود, in `test/features/fenzo/data/category_seed_test.dart`
- [X] T014 Implement piastre `Money` in `lib/features/fenzo/domain/entities/money.dart` so `test/features/fenzo/domain/money_test.dart` passes
- [X] T015 Implement `CalendarDate` and week, month, and custom ranges in `lib/features/fenzo/domain/entities/calendar_date.dart` so `test/features/fenzo/domain/calendar_date_test.dart` passes
- [X] T016 Create `Account`, `Category`, `Subcategory`, and `FenzoTransaction` in `lib/features/fenzo/domain/entities/account.dart`, `lib/features/fenzo/domain/entities/category.dart`, `lib/features/fenzo/domain/entities/subcategory.dart`, and `lib/features/fenzo/domain/entities/fenzo_transaction.dart`
- [X] T017 Implement derived balances in `lib/features/fenzo/domain/services/balance_calculator.dart` so `test/features/fenzo/domain/balance_calculator_test.dart` passes
- [X] T018 Implement period figures, including `0%` when the denominator is zero and one decimal place otherwise, in `lib/features/fenzo/domain/services/report_calculator.dart` so `test/features/fenzo/domain/report_calculator_test.dart` passes
- [X] T019 Declare `FenzoRepository` returning `Either<Failure, T>` in `lib/features/fenzo/domain/repositories/fenzo_repository.dart`
- [X] T020 [P] Define the Drift tables for accounts, categories, subcategories, and transactions in `lib/features/fenzo/data/datasources/fenzo_database.dart`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T021 [P] Map those rows to entities in `lib/features/fenzo/data/models/account_model.dart`, `lib/features/fenzo/data/models/category_model.dart`, and `lib/features/fenzo/data/models/transaction_model.dart`
- [X] T022 Implement `FenzoLocalDataSource`, including the one-time Arabic category seed, in `lib/features/fenzo/data/datasources/fenzo_local_data_source.dart` so `test/features/fenzo/data/category_seed_test.dart` passes. Open a file under the app documents directory with `path_provider`, not an in-memory database.
- [X] T023 Map `AppException` to `Failure` with `RepositoryGuard` from `lib/core/data/repository_guard.dart` in `lib/features/fenzo/data/repositories/fenzo_repository_impl.dart`
- [X] T024 Register only the fenzo data layer in `lib/features/fenzo/fenzo_injection.dart`
- [X] T025 Register fenzo routes in `lib/config/routes/app_router.dart` and `lib/config/routes/app_routes.dart`, wrap them with `FeatureScope` from `lib/core/di/feature_scope.dart`, and start the app through `initApp()` in `lib/init_app.dart` and `App` in `lib/app.dart`. Do not add a second router
- [X] T026 Replace the counter expectation in `test/widget_test.dart` with a smoke test that the Arabic shell builds
- [X] T027 Generate Drift code for `lib/features/fenzo/data/datasources/fenzo_database.dart` with `dart run build_runner build --delete-conflicting-outputs`

**Checkpoint**: Money, dates, the balance formula, the empty database, and the Arabic shell exist. Story work can start.

---

## Phase 3: User Story 1 - See where money sits (Priority: P1) 🎯 MVP

**Goal**: The person adds accounts with opening balances, sees each current balance and total money, and can edit, exclude, deactivate, reactivate, or delete an empty account.

**Independent Test**: Add two accounts with opening balances and no income or expense. Each balance equals its opening balance, the total equals the included accounts, and 25,000 EGP is not income. Covers `specs/001-phase0-mvp/contracts/accounts.md`.

### Tests for User Story 1

- [X] T028 [P] [US1] Write failing account use-case tests in `test/features/fenzo/domain/account_use_cases_test.dart`. Cover these cases: the type can change only when the account has no transactions, and labels that do not fit the new type are cleared; an opening date later than an existing transaction is rejected; deactivate sets the account inactive and removes it from total money; reactivate does not put it back into the total.
- [X] T029 [P] [US1] Write failing account repository tests in `test/features/fenzo/data/account_repository_test.dart`. Close the file-backed database, reopen the same file, and assert the account is still there.
- [X] T030 [P] [US1] Write failing account cubit tests for success and error in `test/features/fenzo/presentation/account_cubits_test.dart`
- [X] T031 [P] [US1] Write failing confirm-versus-cancel tests in `test/features/fenzo/presentation/confirm_action_dialog_test.dart`

### Implementation for User Story 1

- [X] T032 [US1] Persist create, edit, include/exclude, deactivate, reactivate, and empty-account delete in `lib/features/fenzo/data/datasources/fenzo_local_data_source.dart` and `lib/features/fenzo/data/repositories/fenzo_repository_impl.dart`. The type can change only when the account has no transactions, and labels that do not fit the new type are cleared. An opening date later than an existing transaction is rejected. Deactivate sets the account inactive and removes it from total money. Reactivate does not put it back into the total.
- [X] T033 [US1] Create `SaveAccountUseCase`, `DeactivateAccountUseCase`, `ReactivateAccountUseCase`, `DeleteAccountUseCase`, and `GetAccountsUseCase`, each with its params, in `lib/features/fenzo/domain/usecases/save_account_use_case.dart`, `lib/features/fenzo/domain/usecases/deactivate_account_use_case.dart`, `lib/features/fenzo/domain/usecases/reactivate_account_use_case.dart`, `lib/features/fenzo/domain/usecases/delete_account_use_case.dart`, and `lib/features/fenzo/domain/usecases/get_accounts_use_case.dart`
- [X] T034 [US1] Create one cubit and part-file state per account action, with `f` methods and `ApiCallState`, under `lib/features/fenzo/presentation/controller/save_account/`, `lib/features/fenzo/presentation/controller/deactivate_account/`, `lib/features/fenzo/presentation/controller/reactivate_account/`, `lib/features/fenzo/presentation/controller/delete_account/`, and `lib/features/fenzo/presentation/controller/get_accounts/`
- [X] T035 [US1] Register the account use cases and cubits in `lib/features/fenzo/fenzo_injection.dart`
- [X] T036 [US1] Build the confirm dialog in `lib/features/fenzo/presentation/widgets/confirm_action_dialog.dart`
- [X] T037 [US1] Build the account form and account list in `lib/features/fenzo/presentation/pages/account_form_page.dart` and `lib/features/fenzo/presentation/pages/account_list_page.dart`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T038 [US1] Route the first-account empty state and the account list in `lib/features/fenzo/presentation/navigation/fenzo_router.dart`, and block transaction entry until an account exists

**Checkpoint**: User Story 1 works alone. Opening balances, inclusion, deactivation, and empty-account delete match the account contract.

---

## Phase 4: User Story 2 - Record income and spending (Priority: P1)

**Goal**: The person records, edits, and deletes income and expenses against an active account and a category. Balances follow every confirmed change.

**Independent Test**: From a known opening balance, add one income and one expense, edit one, delete one, and confirm the balance after each step. 12.50 EGP is exact. A third decimal place is rejected. An overspend is allowed and shows a negative balance. Covers the record and edit sections of `specs/001-phase0-mvp/contracts/transactions.md`.

### Tests for User Story 2

- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T039 [P] [US2] Write failing income and expense use-case tests in `test/features/fenzo/domain/income_expense_use_cases_test.dart`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T040 [P] [US2] Write failing income and expense repository tests in `test/features/fenzo/data/income_expense_repository_test.dart`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T041 [P] [US2] Write failing income and expense cubit tests for success and error in `test/features/fenzo/presentation/income_expense_cubits_test.dart`

### Implementation for User Story 2

- [X] T042 [US2] Persist income and expense create, edit, and confirmed delete in `lib/features/fenzo/data/datasources/fenzo_local_data_source.dart` and `lib/features/fenzo/data/repositories/fenzo_repository_impl.dart`
- [X] T043 [US2] Create `SaveIncomeUseCase`, `SaveExpenseUseCase`, `UpdateTransactionUseCase`, and `DeleteTransactionUseCase` in `lib/features/fenzo/domain/usecases/save_income_use_case.dart`, `lib/features/fenzo/domain/usecases/save_expense_use_case.dart`, `lib/features/fenzo/domain/usecases/update_transaction_use_case.dart`, and `lib/features/fenzo/domain/usecases/delete_transaction_use_case.dart`
- [X] T044 [US2] Create cubits and part-file states under `lib/features/fenzo/presentation/controller/save_income/`, `lib/features/fenzo/presentation/controller/save_expense/`, `lib/features/fenzo/presentation/controller/update_transaction/`, and `lib/features/fenzo/presentation/controller/delete_transaction/`
- [X] T045 [US2] Register the income and expense use cases and cubits in `lib/features/fenzo/fenzo_injection.dart`
- [X] T046 [US2] Build the income and expense form, using the seed categories and active accounts only, in `lib/features/fenzo/presentation/pages/transaction_form_page.dart`
- [X] T047 [US2] Build the transaction history page in `lib/features/fenzo/presentation/pages/transaction_list_page.dart`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T048 [US2] Add income, expense, edit, and history routes in `lib/features/fenzo/presentation/navigation/fenzo_router.dart`, and call delete only after `lib/features/fenzo/presentation/widgets/confirm_action_dialog.dart` confirms

**Checkpoint**: User Stories 1 and 2 together replace a notebook for income and spending.

---

## Phase 5: User Story 3 - Move money between own accounts (Priority: P2)

**Goal**: A transfer decreases the source, increases the destination, and does not count as income or expense.

**Independent Test**: With two included accounts, record a 1,000 EGP transfer. Both balances change by 1,000, total money is unchanged, and expenses do not increase. Editing the amount or either account updates both balances and still does not count as income or expense. A same-account transfer is rejected. Cancelled delete leaves both balances in place. Covers the transfer section of `specs/001-phase0-mvp/contracts/transactions.md`.

### Tests for User Story 3

- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T049 [P] [US3] Write failing transfer use-case tests in `test/features/fenzo/domain/transfer_use_case_test.dart`, including an edit of the amount or either account, and a rejection when the source and destination are the same
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T050 [P] [US3] Write failing transfer repository tests in `test/features/fenzo/data/transfer_repository_test.dart`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T051 [P] [US3] Write failing transfer cubit tests for success and error in `test/features/fenzo/presentation/transfer_cubit_test.dart`

### Implementation for User Story 3

- [X] T052 [US3] Persist one transfer row with source and destination in `lib/features/fenzo/data/datasources/fenzo_local_data_source.dart` and `lib/features/fenzo/data/repositories/fenzo_repository_impl.dart`
- [X] T053 [US3] Create `SaveTransferUseCase` in `lib/features/fenzo/domain/usecases/save_transfer_use_case.dart`
- [X] T054 [US3] Extend `UpdateTransactionUseCase` in `lib/features/fenzo/domain/usecases/update_transaction_use_case.dart`, and the transfer update in `lib/features/fenzo/data/datasources/fenzo_local_data_source.dart` and `lib/features/fenzo/data/repositories/fenzo_repository_impl.dart`, so a transfer edit changes both balances and still does not count as income or expense. Reject a same-account transfer.
- [X] T055 [US3] Create the transfer cubit and part-file state in `lib/features/fenzo/presentation/controller/save_transfer/save_transfer_cubit.dart`
- [X] T056 [US3] Register the transfer use case and cubit in `lib/features/fenzo/fenzo_injection.dart`
- [X] T057 [US3] Add the transfer mode, including opening an existing transfer for edit, to `lib/features/fenzo/presentation/pages/transaction_form_page.dart` and its route in `lib/features/fenzo/presentation/navigation/fenzo_router.dart`

**Checkpoint**: Transfers between the person’s own accounts do not inflate spending.

---

## Phase 6: User Story 4 - Organize transactions by category (Priority: P2)

**Goal**: The person adds, renames, disables, and deletes categories and subcategories without losing history.

**Independent Test**: Record an expense under مواصلات / وقود, add a custom category, disable a used category, and confirm old rows still show the old name while new rows cannot select it. An unused category can be removed. Covers the category section of `specs/001-phase0-mvp/contracts/transactions.md`.

### Tests for User Story 4

- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T058 [P] [US4] Write failing category use-case tests in `test/features/fenzo/domain/category_use_cases_test.dart`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T059 [P] [US4] Write failing category repository tests in `test/features/fenzo/data/category_repository_test.dart`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T060 [P] [US4] Write failing category cubit tests for success and error in `test/features/fenzo/presentation/category_cubits_test.dart`

### Implementation for User Story 4

- [X] T061 [US4] Persist category and subcategory add, rename, disable, and unused delete in `lib/features/fenzo/data/datasources/fenzo_local_data_source.dart` and `lib/features/fenzo/data/repositories/fenzo_repository_impl.dart`
- [X] T062 [US4] Create `SaveCategoryUseCase`, `DeactivateCategoryUseCase`, `DeleteCategoryUseCase`, and `GetCategoriesUseCase` in `lib/features/fenzo/domain/usecases/save_category_use_case.dart`, `lib/features/fenzo/domain/usecases/deactivate_category_use_case.dart`, `lib/features/fenzo/domain/usecases/delete_category_use_case.dart`, and `lib/features/fenzo/domain/usecases/get_categories_use_case.dart`
- [X] T063 [US4] Create cubits and part-file states under `lib/features/fenzo/presentation/controller/save_category/`, `lib/features/fenzo/presentation/controller/deactivate_category/`, `lib/features/fenzo/presentation/controller/delete_category/`, and `lib/features/fenzo/presentation/controller/get_categories/`
- [X] T064 [US4] Register the category use cases and cubits in `lib/features/fenzo/fenzo_injection.dart`
- [X] T065 [US4] Build category management in `lib/features/fenzo/presentation/pages/category_list_page.dart`
- [X] T066 [US4] Add the category route in `lib/features/fenzo/presentation/navigation/fenzo_router.dart`

**Checkpoint**: Categories can be managed without breaking older transactions.

---

## Phase 7: User Story 5 - Read the current month at a glance (Priority: P2)

**Goal**: The dashboard shows this calendar month’s income, expenses, and net result, total money, active account balances, the expense split, and the ten newest transactions.

**Independent Test**: With movements inside and outside the current month, the dashboard totals include only the current month, transfers stay out of those totals, deactivated accounts are absent, and opening a figure shows its transactions. Covers `specs/001-phase0-mvp/contracts/dashboard-and-reports.md`.

### Tests for User Story 5

- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T067 [P] [US5] Write failing dashboard use-case tests in `test/features/fenzo/domain/get_dashboard_use_case_test.dart`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T068 [P] [US5] Write failing dashboard cubit tests for success and error in `test/features/fenzo/presentation/get_dashboard_cubit_test.dart`

### Implementation for User Story 5

- [X] T069 [US5] Create `GetDashboardUseCase` in `lib/features/fenzo/domain/usecases/get_dashboard_use_case.dart`, reading through `lib/features/fenzo/domain/services/report_calculator.dart` and `lib/features/fenzo/domain/services/balance_calculator.dart`
- [X] T070 [US5] Create the dashboard cubit and part-file state in `lib/features/fenzo/presentation/controller/get_dashboard/get_dashboard_cubit.dart`
- [X] T071 [US5] Register the dashboard use case and cubit in `lib/features/fenzo/fenzo_injection.dart`
- [X] T072 [US5] Build the dashboard and its drill-down into `lib/features/fenzo/presentation/pages/transaction_list_page.dart` from `lib/features/fenzo/presentation/pages/dashboard_page.dart` and `lib/features/fenzo/presentation/navigation/fenzo_router.dart`

**Checkpoint**: Opening the app answers how this month is going.

---

## Phase 8: User Story 6 - Review any period (Priority: P2)

**Goal**: The person reads income, expenses, net result, category shares, per-account movement, and the transaction list for a day, a Saturday–Friday week, a calendar month, or a custom range.

**Independent Test**: Seed a known September, run 1–30 September, and match every total by hand. “This week” is Saturday through Friday. End before start does not run a report. Total money does not change when the range changes. Covers `specs/001-phase0-mvp/contracts/dashboard-and-reports.md`.

### Tests for User Story 6

- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T073 [P] [US6] Write failing report use-case tests in `test/features/fenzo/domain/get_report_use_case_test.dart`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T074 [P] [US6] Write failing report cubit tests for success and error in `test/features/fenzo/presentation/get_report_cubit_test.dart`

### Implementation for User Story 6

- [X] T075 [US6] Create `GetReportUseCase` in `lib/features/fenzo/domain/usecases/get_report_use_case.dart`
- [X] T076 [US6] Create the report cubit and part-file state in `lib/features/fenzo/presentation/controller/get_report/get_report_cubit.dart`
- [X] T077 [US6] Register the report use case and cubit in `lib/features/fenzo/fenzo_injection.dart`
- [X] T078 [US6] Build presets, custom range, category shares, and the account report in `lib/features/fenzo/presentation/pages/report_page.dart` and `lib/features/fenzo/presentation/navigation/fenzo_router.dart`. The report’s transaction list is `lib/features/fenzo/presentation/pages/transaction_list_page.dart` opened with the chosen date range, not a second list inside the report page.

**Checkpoint**: Any day, week, month, or custom range can be checked by hand.

---

## Phase 9: User Story 7 - Find a past transaction (Priority: P3)

**Goal**: The person searches by description, notes, account, category, or subcategory, and combines filters. Filters do not change stored rows.

**Independent Test**: Create rows that differ by notes, account, type, and category. One filter narrows the list. Two filters together keep only rows that match both. No match is an empty list, not an error. Covers the find section of `specs/001-phase0-mvp/contracts/transactions.md`.

### Tests for User Story 7

- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T079 [P] [US7] Write failing search use-case tests in `test/features/fenzo/domain/search_transactions_use_case_test.dart`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T080 [P] [US7] Write failing search cubit tests for success and empty results in `test/features/fenzo/presentation/search_transactions_cubit_test.dart`

### Implementation for User Story 7

- [X] T081 [US7] Apply trimmed case-insensitive substring search and AND filters in `lib/features/fenzo/data/datasources/fenzo_local_data_source.dart` and `lib/features/fenzo/data/repositories/fenzo_repository_impl.dart`
- [X] T082 [US7] Create `SearchTransactionsUseCase` in `lib/features/fenzo/domain/usecases/search_transactions_use_case.dart`
- [X] T083 [US7] Create the search cubit and part-file state in `lib/features/fenzo/presentation/controller/search_transactions/search_transactions_cubit.dart`
- [X] T084 [US7] Register the search use case and cubit in `lib/features/fenzo/fenzo_injection.dart`
- [X] T085 [US7] Add search and combined filters to `lib/features/fenzo/presentation/pages/transaction_list_page.dart`. Those filters still apply when `lib/features/fenzo/presentation/pages/report_page.dart` opened the list with a date range.

**Checkpoint**: A past transaction can be found without changing it.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Static analysis, the scale check, and the manual quickstart

- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T086 Run `flutter analyze` and clear every issue in `lib/`, `test/`, and `packages/either/`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T087 [P] Add a 5,000-transaction report timing assertion in `test/features/fenzo/domain/report_calculator_test.dart`
- [X] SUPERSEDED (shipped outside `lib/features/fenzo`; do not redo): T088 Walk the manual pass in `specs/001-phase0-mvp/quickstart.md` on a device in airplane mode and fix any miss against `specs/001-phase0-mvp/contracts/`

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
- **User Story 4 (P2)**: After Foundational for data, and after User Story 2 if you want to disable a category that an expense already uses. Can be built in parallel with User Story 3 only up through its tests (T058–T060). Implementation shares `fenzo_local_data_source.dart` with User Story 3, so implement T061 after T052.
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
- User Story 3 and User Story 4 tests can be written at the same time; do not edit `fenzo_local_data_source.dart` from both at once

---

## Parallel Example: User Story 1

```bash
# Write the User Story 1 tests together:
# test/features/fenzo/domain/account_use_cases_test.dart
# test/features/fenzo/data/account_repository_test.dart
# test/features/fenzo/presentation/account_cubits_test.dart
# test/features/fenzo/presentation/confirm_action_dialog_test.dart

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
3. User Story 2 → daily income and expenses (smallest useful fenzo)
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
- Balances stay in `lib/features/fenzo/domain/services/balance_calculator.dart`. Widgets format them and do not recompute them
- Confirmation dialogs stay in the widget. Cubits run only after confirm
- Phase 0 does not add backup, sync, category suggestions, or budgets

## Phase 11: Convergence

- [X] T089 CRITICAL: Use `screen_util` spacing and `lib/core/utils/values/text_styles.dart` on every fenzo screen in `lib/features/fenzo/presentation/pages/` per Constitution VI (contradicts)
- [X] T090 CRITICAL: Let `lib/features/fenzo/presentation/pages/transaction_form_page.dart` choose an active account, a matching category, an optional subcategory, transfer source and destination, date, and notes before save per FR-013, FR-014, and FR-016 (partial)
- [X] T091 Collect bank name, account number, wallet phone, opening date, and include-in-total on `lib/features/fenzo/presentation/pages/account_form_page.dart`, and lock type changes after the first transaction, per FR-002, FR-003, FR-005, and FR-006 (partial)
- [X] T092 Show each account balance on `lib/features/fenzo/presentation/pages/account_list_page.dart`, and after confirmation call deactivate, reactivate, or empty-account delete per US1/AC6 and US1/AC7 (partial)
- [X] T093 Add, rename, disable, and delete unused categories and subcategories from `lib/features/fenzo/presentation/pages/category_list_page.dart` per FR-029, FR-030, and FR-031 (partial)
- [X] T094 Show net result, active-account balances, expense shares, and a filtered drill-down on `lib/features/fenzo/presentation/pages/dashboard_page.dart` per FR-032, FR-033, FR-034, and FR-036 (partial)
- [X] T095 Add day, Saturday–Friday week, month, and custom-range presets, reject an end date before the start, and show category shares plus the account report on `lib/features/fenzo/presentation/pages/report_page.dart` per FR-037, FR-039, and FR-042 (partial)
- [X] T096 Add account, type, and category filter controls on `lib/features/fenzo/presentation/pages/transaction_list_page.dart` and combine them with search per FR-047 (partial)
- [X] T097 Add the opening-date rejection case to `test/features/fenzo/domain/account_use_cases_test.dart` per FR-012 (partial)

## Phase 12: Convergence

- [X] T098 CRITICAL: Add a `part` state file for every finance cubit, as `typedef {Operation}State = ApiCallState<T>`, under `lib/features/accounts/`, `lib/features/categories/`, `lib/features/transactions/`, `lib/features/dashboard/`, and `lib/features/reports/` per Constitution III (contradicts)
- [X] T099 CRITICAL: Move row mapping out of `lib/core/database/finance_store.dart` so core does not import feature models; keep `fromJson` / `fromRow` on each feature model in `lib/features/accounts/data/models/`, `lib/features/categories/data/models/`, and `lib/features/transactions/data/models/` per Constitution I (contradicts)
- [X] T100 Show the ten newest transactions on `lib/features/dashboard/presentation/pages/dashboard_page.dart` per FR-035 and US5/AC4 (partial)
- [X] T101 Show income-by-category amount and percentage on `lib/features/reports/presentation/pages/report_page.dart` per FR-040 and US6/AC3 (partial)
- [X] T102 Add a subcategory filter on `lib/features/transactions/presentation/pages/transaction_list_page.dart` and combine it with search, date, account, type, and category per FR-047 and US7/AC2 (partial)
- [X] T103 Add navigation from `lib/features/dashboard/presentation/pages/dashboard_page.dart` to categories and reports per US4 and US6 (missing)
- [X] T104 Open the period transaction list from `lib/features/reports/presentation/pages/report_page.dart` for the selected range per FR-043 and US6/AC6 (partial)
- [X] T105 Tell the person when a transaction amount is not greater than zero, has more than two decimal places, or is dated before the account opening date, in `lib/features/transactions/presentation/pages/transaction_form_page.dart` per FR-004, FR-020, FR-022, US2/AC5, US2/AC7, and US2/AC8 (partial)
- [X] T106 Tell the person when an account type is fixed because transactions already exist, in `lib/features/accounts/presentation/pages/account_form_page.dart` per US1/AC9 (partial)

## Phase 13: Convergence

- [X] T107 Tell the person why a transfer was not saved when the source and destination are the same account, or either account is missing or deactivated, in `lib/features/transactions/presentation/pages/transaction_form_page.dart` per FR-021 and US3/AC5 (partial)
- [X] T108 Show an empty result, not the first-account prompt, when search or filters match nothing on `lib/features/transactions/presentation/pages/transaction_list_page.dart` per FR-045 and US7/AC4 (partial)
- [X] T109 Tell the person which transactions block a new opening date on `lib/features/accounts/presentation/pages/account_form_page.dart` per the opening-date edge case (partial)
- [X] T110 Return each account balance from the accounts use case and format it on `lib/features/accounts/presentation/pages/account_list_page.dart` per plan: widgets do not calculate balances (contradicts)

## Phase 14: Convergence

- [X] T111 CRITICAL: From `lib/features/dashboard/presentation/pages/dashboard_page.dart`, open the account list and the transaction form in `lib/config/routes/app_router.dart`, and when no account exists ask for the first account and do not offer a transaction save, per FR-024 and US1/AC10 (missing)
- [X] T112 Show each transaction’s category and subcategory name on `lib/features/transactions/presentation/pages/transaction_list_page.dart` and on the recent rows of `lib/features/dashboard/presentation/pages/dashboard_page.dart`, including after a category is disabled, per FR-030 and US4/AC4 (partial)

## Phase 15: Convergence

- [X] T113 From `lib/features/transactions/presentation/pages/transaction_list_page.dart`, open `lib/features/transactions/presentation/pages/transaction_form_page.dart` for an existing income, expense, or transfer, and call delete only after `lib/shared/widgets/confirm_action_dialog.dart` confirms, providing `DeleteTransactionCubit` from `lib/config/routes/app_router.dart`, per FR-019, FR-054, US2/AC3, and US2/AC4 (missing)

## Phase 16: Convergence

- [X] T114 After a saved edit in `lib/features/transactions/presentation/pages/transaction_form_page.dart` and after a confirmed delete in `lib/features/transactions/presentation/pages/transaction_list_page.dart`, reload the transaction search and `GetReportCubit` so the list and the open report match the saved records per FR-019 (partial)

---

## Phase 17: Setup — Transfer commission

**Purpose**: Labels for the fee field. No new package and no new feature folder.

- [X] T115 [P] Add `fenzo_transfer_commission` and `fenzo_commission_not_allowed` to `assets/lang/en.json` and `assets/lang/ar.json`, and add the matching getters in `lib/config/language/strings.dart`. Do not add a second string table.

---

## Phase 18: Foundational — Transfer commission

**Purpose**: The fee exists on the transaction, older rows stay at zero, and balances come from the calculators. No story screen starts before this phase.

**Independent check**: A book saved before this phase still opens, every existing balance is unchanged, and a fee cannot be stored on income, cash, or an `other` account.

### Tests first

- [X] T116 [P] Write failing `saveMovement` tests in `test/shared/domain/finance_records_commission_test.dart`: a blank commission is 0; a negative commission is rejected; a commission larger than the principal is allowed; income, cash, and `other` reject a commission greater than zero and leave the book unchanged; a bank or e-wallet expense and any transfer accept it; the expense `categoryId` is not replaced by the fee category.
- [X] T117 [P] Extend `test/shared/domain/balance_calculator_test.dart` with failing cases: a transfer with no commission does not change total money; with a commission the destination changes by the moved amount only, the source changes by the moved amount plus the commission, and total money changes by the commission only when the source is included; a bank expense decreases that account by the payment plus the commission.
- [X] T118 [P] Extend `test/shared/domain/report_calculator_test.dart` with failing cases: period expenses and net result include `commissionMinor`; the chosen expense category changes by `amountMinor` only; `رسوم تحويل` receives the commissions; transfers in and transfers out stay the moved amount.
- [X] T119 [P] Write failing mapping tests in `test/features/transactions/data/money_transaction_model_test.dart`: `toJson` writes `commission_minor`, and a JSON object without that key reads as 0.
- [X] T120 [P] Extend `test/features/categories/data/category_seed_test.dart` so a book that already has categories gains `رسوم تحويل` with id `seed-expense-رسوم تحويل` and does not rename the other categories.

### Implementation

- [X] T121 Add `commissionMinor` to `lib/shared/domain/entities/money_transaction.dart`, defaulting to 0, and include it in `props`.
- [X] T122 [P] Add `commissionMinor` as a non-null integer with default 0 on `TransactionRows` in `lib/core/database/finance_database.dart`, raise `schemaVersion` to 2, and add an `onUpgrade` from 1 to 2 that adds the column with default 0. Regenerate `lib/core/database/finance_database.g.dart` with `dart run build_runner build --delete-conflicting-outputs`.
- [X] T123 Map `commissionMinor` in `lib/features/transactions/data/models/money_transaction_model.dart` (`fromEntity`, `fromRow`, `fromJson`, `toJson`, `toCompanion`) so a missing `commission_minor` key is 0, making `test/features/transactions/data/money_transaction_model_test.dart` pass.
- [X] T124 In `lib/shared/domain/finance_records.dart`, insert category id `seed-expense-رسوم تحويل` and name `رسوم تحويل` when that id is missing, reject a normal expense that uses that id, and accept or reject `commissionMinor` in `saveMovement` per `specs/001-phase0-mvp/data-model.md`, making `test/shared/domain/finance_records_commission_test.dart` and the new seed case in `test/features/categories/data/category_seed_test.dart` pass.
- [X] T125 [P] Apply `commissionMinor` in `lib/shared/domain/services/balance_calculator.dart` so `test/shared/domain/balance_calculator_test.dart` passes. Do not store a balance.
- [X] T126 [P] Apply `commissionMinor` in `lib/shared/domain/services/report_calculator.dart` so `test/shared/domain/report_calculator_test.dart` passes. Attribute commissions to category id `seed-expense-رسوم تحويل`. Do not add them to transfers in or transfers out.
- [X] T127 Pass `commissionMinor` through `lib/features/transactions/domain/repositories/transactions_repository.dart`, `lib/features/transactions/data/repositories/transactions_repository_impl.dart`, `lib/features/transactions/domain/usecases/save_expense_use_case.dart`, `lib/features/transactions/domain/usecases/save_transfer_use_case.dart`, and `lib/features/transactions/domain/usecases/update_transaction_use_case.dart`. Keep `lib/features/transactions/domain/usecases/save_income_use_case.dart` sending 0.

**Checkpoint**: Calculators and `saveMovement` enforce the fee. Screens still do not show it.

---

## Phase 19: User Story 2 — Record a fee on a bank or wallet payment (Priority: P1)

**Goal**: A payment from a bank account or digital wallet can include a transfer commission. Cash, other accounts, and income cannot.

**Independent Test**: Record a 200 EGP payment from a bank account with a 3 EGP commission and confirm that account falls by 203 EGP, the chosen category rises by 200 EGP, and `رسوم تحويل` rises by 3 EGP. Record 200 EGP from cash and confirm there is no fee field and the account falls by 200 EGP.

### Tests for User Story 2

- [X] T128 [P] [US2] Write failing use-case tests in `test/features/transactions/domain/save_expense_use_case_test.dart` that pass `commissionMinor` through `SaveExpenseUseCase` and `UpdateTransactionUseCase` in `lib/features/transactions/domain/usecases/save_expense_use_case.dart` and `lib/features/transactions/domain/usecases/update_transaction_use_case.dart`.
- [X] T129 [P] [US2] Write failing cubit tests for success and for `ValidationFailure` in `test/features/transactions/presentation/save_expense_cubit_test.dart`, covering `fSaveExpense` on `lib/features/transactions/presentation/controller/save_expense/save_expense_cubit.dart`.

### Implementation for User Story 2

- [X] T130 [US2] On an expense in `lib/features/transactions/presentation/pages/transaction_form_page.dart`, show the commission field only when the paying account is `bank` or `eWallet`, parse it with the existing money parser, send 0 when it is blank, and reject a save that still has a commission after the account changes to cash or `other`. Do not offer category id `seed-expense-رسوم تحويل` in the expense picker.
- [X] T131 [US2] When `commissionMinor` is greater than zero, show the payment and the fee as separate figures in `lib/features/transactions/presentation/widgets/transaction_summary.dart`.

**Checkpoint**: Bank and wallet payments record a fee. Transfers still have no fee field.

---

## Phase 20: User Story 3 — Record a fee on a move between accounts (Priority: P2)

**Goal**: Every internal transfer can include a transfer commission. The destination receives the moved amount. The source pays the moved amount plus the fee.

**Independent Test**: Move 1,000 EGP with a 5 EGP commission. The destination rises by 1,000 EGP, the source falls by 1,005 EGP, total money falls by 5 EGP, and expenses rise by 5 EGP. The same move with a blank commission leaves total money unchanged.

### Tests for User Story 3

- [X] T132 [P] [US3] Write failing use-case tests in `test/features/transactions/domain/save_transfer_use_case_test.dart` that pass `commissionMinor` through `SaveTransferUseCase` in `lib/features/transactions/domain/usecases/save_transfer_use_case.dart`.
- [X] T133 [P] [US3] Write failing cubit tests for success and error in `test/features/transactions/presentation/save_transfer_cubit_test.dart`, covering `fSaveTransfer` on `lib/features/transactions/presentation/controller/save_transfer/save_transfer_cubit.dart`.

### Implementation for User Story 3

- [X] T134 [US3] Show the commission field for every transfer in `lib/features/transactions/presentation/pages/transaction_form_page.dart`, including an edit that changes the fee to 0. Keep the moved amount and the fee as separate figures in `lib/features/transactions/presentation/widgets/transaction_summary.dart`.

**Checkpoint**: A transfer fee and a payment fee both save through the existing cubits. Deleting the row still removes both figures.

---

## Phase 21: User Story 5 — See the fee in this month (Priority: P2)

**Goal**: This month’s expenses include transfer commissions, and a recent row shows the fee apart from the principal.

**Independent Test**: With a 5 EGP commission dated this month, the home expense total includes 5 EGP and the recent row shows 5 EGP separately from the moved or paid amount.

### Implementation for User Story 5

- [X] T135 [US5] Show the fee as a separate figure on a recent row in `lib/features/dashboard/presentation/widgets/dashboard_activity.dart` when `commissionMinor` is greater than zero. Leave `lib/features/dashboard/presentation/widgets/dashboard_balance.dart` reading the period expense from the calculator. Do not add a second expense sum in the widget.

**Checkpoint**: The home month expense matches the calculator. A zero commission row looks as it did before this amendment.

---

## Phase 22: User Story 6 — See the fee in a period report (Priority: P2)

**Goal**: A period report counts the commission as spending and keeps transfers in and transfers out equal to the moved amount.

**Independent Test**: For a range that contains one transfer with a 5 EGP commission and one bank payment of 200 EGP with a 3 EGP commission, expenses include 8 EGP of fees, the payment category includes 200 EGP, and transfers out equal the moved amount only.

### Implementation for User Story 6

- [X] T136 [US6] Keep `lib/features/reports/presentation/pages/report_page.dart` bound to `expenseMinor`, `transfersInMinor`, and `transfersOutMinor` from the calculator. Do not add `commissionMinor` to the transfer lines on the page. The `رسوم تحويل` share comes from `expenseShares`.

**Checkpoint**: The account report ending balance still equals starting balance + income − expenses + transfers in − transfers out, with the fee inside expenses.

---

## Phase 23: Polish — Transfer commission

**Purpose**: Older books, analysis, and the manual pass.

- [X] T137 [P] Add `test/core/database/finance_schema_migration_test.dart` proving a schema-version-1 database gains `commission_minor` as 0 after `lib/core/database/finance_database.dart` upgrades to version 2.
- [X] T138 Run `flutter analyze` and `flutter test` from the repository root and clear every issue this amendment causes in `lib/` and `test/`.
- [X] T139 Walk steps 5, 5a, 5b, and 9 in `specs/001-phase0-mvp/quickstart.md` and fix any miss against `specs/001-phase0-mvp/contracts/transactions.md` and `specs/001-phase0-mvp/contracts/dashboard-and-reports.md`.

---

## Dependencies — Transfer commission

### Phase dependencies

- **Phase 17**: No dependency on other open tasks.
- **Phase 18**: Depends on Phase 17 for the labels the later screens use. Blocks Phases 19–22.
- **Phase 19 (US2)**: Depends on Phase 18. No dependency on US3.
- **Phase 20 (US3)**: Depends on Phase 18 and on T130, because it edits the same form.
- **Phase 21 (US5)**: Depends on Phase 18. Can run beside Phase 22. Does not require the form.
- **Phase 22 (US6)**: Depends on Phase 18. Can run beside Phase 21.
- **Phase 23**: Depends on Phases 19–22.

### Within Phase 18

- T116–T120 can run together, and they are written to fail before T121–T127.
- T121 and T122 can run together.
- T123 depends on T121 and T122.
- T124 depends on T121.
- T125 and T126 depend on T121 and can run together.
- T127 depends on T124.

### Parallel example after Phase 18

```text
T128 test/features/transactions/domain/save_expense_use_case_test.dart
T129 test/features/transactions/presentation/save_expense_cubit_test.dart
T135 lib/features/dashboard/presentation/widgets/dashboard_activity.dart
T136 lib/features/reports/presentation/pages/report_page.dart
```

T134 waits until T130 has landed in `lib/features/transactions/presentation/pages/transaction_form_page.dart`.

## Implementation strategy — Transfer commission

1. Finish Phase 17 and Phase 18. Stop and confirm existing balances are unchanged when the fee is 0.
2. Finish Phase 19 (US2). This is the MVP of the amendment: a bank or wallet payment can carry a fee.
3. Finish Phase 20 (US3) so a move between accounts can carry the same fee.
4. Finish Phases 21 and 22 so the home screen and period report show that fee as spending.
5. Finish Phase 23.

---

## Phase 24: Setup — Usual fee

**Purpose**: The label for the usual fee on an account. No new package and no new feature folder.

- [X] T140 [P] Add `fenzo_usual_commission` to `assets/lang/en.json` and `assets/lang/ar.json`, and add the matching getter in `lib/config/language/strings.dart`. English: "Usual transfer commission". Arabic: "رسوم التحويل المعتادة". Do not add a second string table.

---

## Phase 25: Foundational — Usual fee

**Purpose**: The usual fee exists on the account, older accounts stay at zero, and a saved transaction fee is not rewritten. No story screen starts before this phase.

**Independent check**: An account saved with a blank usual fee has 0, its balance is unchanged, and a transaction that already stored a fee still has that fee after the account’s usual fee changes.

### Tests first

- [X] T141 [P] Write failing `saveAccount` tests in `test/shared/domain/finance_records_usual_fee_test.dart`: a blank usual fee is stored as 0 and the opening balance is unchanged; a negative usual fee is rejected and the book is unchanged; changing the type of an account with no transactions keeps the usual fee; changing the usual fee does not change `commissionMinor` on an already saved transaction.
- [X] T142 [P] Write failing mapping tests in `test/features/accounts/data/account_model_test.dart`: `toJson` writes `default_commission_minor`, and a JSON object without that key reads as 0.
- [X] T143 [P] Extend `test/core/database/finance_schema_migration_test.dart` with a failing case: a schema-version-2 database whose `account_rows` have no `default_commission_minor` gains that column as 0 after `lib/core/database/finance_database.dart` upgrades to version 3, and the existing `commission_minor` value on `transaction_rows` stays as it was.

### Implementation

- [X] T144 [P] Add `defaultCommissionMinor` to `lib/shared/domain/entities/account.dart`, defaulting to 0, and include it in `props` and `copyWith`.
- [X] T145 [P] Add `defaultCommissionMinor` as a non-null integer with default 0 on `AccountRows` in `lib/core/database/finance_database.dart`, raise `schemaVersion` to 3, and add an `onUpgrade` from 2 to 3 that adds the column with default 0. Keep the version 1 to 2 `commission_minor` upgrade. Regenerate `lib/core/database/finance_database.g.dart` with `dart run build_runner build --delete-conflicting-outputs`.
- [X] T146 Map `defaultCommissionMinor` in `lib/features/accounts/data/models/account_model.dart` (`fromEntity`, `fromRow`, `fromJson`, `toJson`, `toCompanion`) so a missing `default_commission_minor` key is 0 and `toCompanion` passes `Value(defaultCommissionMinor)`, making `test/features/accounts/data/account_model_test.dart` pass.
- [X] T147 In `lib/shared/domain/finance_records.dart`, accept `defaultCommissionMinor` on `saveAccount`, reject a value below 0 as `commission_non_negative` without writing, keep the field when the account type changes, and do not change any transaction’s `commissionMinor`, making `test/shared/domain/finance_records_usual_fee_test.dart` pass.
- [X] T148 Pass `defaultCommissionMinor` through `lib/features/accounts/domain/repositories/accounts_repository.dart`, `lib/features/accounts/data/repositories/accounts_repository_impl.dart`, and `lib/features/accounts/domain/usecases/save_account_use_case.dart` (`SaveAccountParams` and `props`). Update the `saveAccount` fakes in `test/features/accounts/domain/account_use_cases_test.dart` and `test/features/accounts/presentation/account_cubits_test.dart` so they accept the new argument with default 0.

**Checkpoint**: Existing balances are unchanged. A usual fee of 0 is the same book as before this amendment.

---

## Phase 26: User Story 1 — Store a usual fee on the account (Priority: P1)

**Goal**: The person can save a usual transfer commission on an account. It does not change the balance. Editing it does not ask for confirmation and does not rewrite saved records.

**Independent Test**: Add Bank ABC with opening balance 25,000 EGP and usual fee 3 EGP. The balance is 25,000 EGP. Leave the usual fee blank on a second account and confirm it is 0. Change Bank ABC’s usual fee to 5 EGP and confirm a payment that already used 3 EGP still shows 3 EGP.

### Tests for User Story 1

- [X] T149 [P] [US1] Write failing use-case tests in `test/features/accounts/domain/save_account_usual_fee_test.dart` that pass `defaultCommissionMinor` through `SaveAccountUseCase` in `lib/features/accounts/domain/usecases/save_account_use_case.dart`, including a save that changes 300 piastres to 0.
- [X] T150 [P] [US1] Write failing cubit tests for success and for `ValidationFailure` in `test/features/accounts/presentation/save_account_usual_fee_cubit_test.dart`, covering `fSaveAccount` on `lib/features/accounts/presentation/controller/save_account/save_account_cubit.dart`.

### Implementation for User Story 1

- [X] T151 [US1] On `lib/features/accounts/presentation/pages/account_form_page.dart`, show the usual-fee field labeled with `Strings.fenzoUsualCommission`, parse it with the existing money parser (`allowZero: true`, `allowNegative: false`), send 0 when it is blank, and reject more than two decimal places without saving. Do not ask for confirmation. Changing the account type must not clear the field. Pass `defaultCommissionMinor` on `SaveAccountParams`.

**Checkpoint**: The account list balance is still the opening balance plus movements. The usual fee is not added to it.

---

## Phase 27: User Story 2 — Start a payment with the account’s usual fee (Priority: P1)

**Goal**: A new bank or e-wallet payment starts with that account’s usual fee. The person can change or clear it. A cash payment still has no fee.

**Independent Test**: Bank ABC’s usual fee is 3 EGP. A new 200 EGP payment starts at 3 EGP. Leaving it decreases the bank by 203 EGP. Clearing it decreases the bank by 200 EGP and leaves the usual fee at 3 EGP. A cash account with a usual fee of 5 EGP still shows no fee field on a payment.

### Implementation for User Story 2

- [X] T152 [US2] In `lib/features/transactions/presentation/pages/transaction_form_page.dart`, when a new expense’s paying account is `bank` or `eWallet`, start the commission field from that account’s `defaultCommissionMinor` (blank when it is 0). When the paying account changes to another bank or e-wallet before save, replace the field with that account’s usual fee. Opening a saved expense shows `commissionMinor` already on the row, not the account’s current usual fee. A cash or `other` expense keeps the field hidden even when that account’s usual fee is greater than zero. Switching that payment onto a bank or e-wallet starts the field from that account’s usual fee. Do not change `saveMovement` to copy the usual fee.

**Checkpoint**: Saving a cleared fee stores 0. The account’s usual fee is unchanged.

---

## Phase 28: User Story 3 — Start a move with the source account’s usual fee (Priority: P2)

**Goal**: A new transfer starts with the source account’s usual fee only. The destination’s usual fee is not added.

**Independent Test**: Bank ABC’s usual fee is 5 EGP and Vodafone Cash’s usual fee is 2 EGP. A new move from Bank ABC starts at 5 EGP, not 2 EGP and not 7 EGP. Changing the source to an account whose usual fee is 0 clears the starting fee. A saved move keeps its fee after the source account’s usual fee changes.

### Implementation for User Story 3

- [X] T153 [US3] In `lib/features/transactions/presentation/pages/transaction_form_page.dart`, when a new transfer’s source account is chosen, start the commission field from that source account’s `defaultCommissionMinor` only. Do not add the destination’s usual fee. When the source changes before save, replace the field with the new source’s usual fee. Opening a saved transfer shows the fee already on the row.

**Checkpoint**: The destination balance still increases by the moved amount only.

---

## Phase 29: Polish — Usual fee

**Purpose**: Analysis and the manual pass. Dashboard and report formulas stay as they are, because a usual fee is not spending until a saved row carries it.

- [X] T154 Run `flutter analyze` and `flutter test` from the repository root and clear every issue this amendment causes in `lib/` and `test/`.
- [X] T155 Walk steps 1, 5b, and 5c in `specs/001-phase0-mvp/quickstart.md` and fix any miss against `specs/001-phase0-mvp/contracts/accounts.md` and `specs/001-phase0-mvp/contracts/transactions.md`.

---

## Dependencies — Usual fee

### Phase dependencies

- **Phase 24**: No dependency on other open tasks.
- **Phase 25**: Depends on Phase 24 for the label the account form uses. Blocks Phases 26–28.
- **Phase 26 (US1)**: Depends on Phase 25. No dependency on US2 or US3.
- **Phase 27 (US2)**: Depends on Phase 25 and on Phase 26, because the account must already store the usual fee.
- **Phase 28 (US3)**: Depends on Phase 27, because it edits the same form.
- **Phase 29**: Depends on Phases 26–28.

### Within Phase 25

- T141, T142, and T143 can run together, and they are written to fail before T144–T148.
- T144 and T145 can run together.
- T146 depends on T144 and T145.
- T147 depends on T144.
- T148 depends on T147.

### Parallel example after Phase 25

```text
T149 test/features/accounts/domain/save_account_usual_fee_test.dart
T150 test/features/accounts/presentation/save_account_usual_fee_cubit_test.dart
```

T153 waits until T152 has landed in `lib/features/transactions/presentation/pages/transaction_form_page.dart`.

## Implementation strategy — Usual fee

1. Finish Phase 24 and Phase 25. Stop and confirm a usual fee of 0 leaves every balance unchanged.
2. Finish Phase 26 (US1). This is the MVP of the amendment: an account can store a usual fee.
3. Finish Phase 27 (US2) so a bank or wallet payment starts with that fee.
4. Finish Phase 28 (US3) so a move starts with the source account’s usual fee only.
5. Finish Phase 29. Do not add the usual fee to dashboard or report totals.
