# Tasks: Capture Draft and Review Screen

**Input**: Design documents from `/specs/004-capture-draft-review/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: The constitution requires unit tests for use cases and repository implementations, and bloc tests for cubit success and error. Those tasks are included. The plan’s widget check for a hand-started draft is included with User Story 1. The device pass stays in the quickstart.

**Organization**: Tasks are grouped by user story so each story can be implemented and tested on its own.

**Shared code**: Reuse `Failure`, `UseCase`, `ApiCallState`, `FeatureScope`, `RepositoryGuard`, `SaveIncomeUseCase`, `SaveExpenseUseCase`, `Money`, `CalendarDate`, `AccountType`, `Strings`, and `AppRouter`. Do not add a second failure type, router, string table, or transaction repository. Do not add a Drift table.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US3)

## Phase 1: Setup

**Purpose**: Capture feature tree. No new package.

- [X] T001 Create `lib/features/capture/` with `data/datasources/`, `data/repositories/`, `domain/entities/`, `domain/repositories/`, `domain/usecases/`, `presentation/controller/`, `presentation/pages/`, and `presentation/widgets/` per `specs/004-capture-draft-review/plan.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The in-memory draft and the words every story shows. No user story starts before this.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T002 [P] Add `CaptureField` and `CaptureDraft` in `lib/features/capture/domain/entities/capture_draft.dart` per `specs/004-capture-draft-review/data-model.md`. Kind is income or expense. A hand-started draft is an expense dated today, with an empty uncertain set and no commission. Include `copyWith` that can clear category, subcategory, and commission
- [X] T003 Declare `CaptureRepository` returning `Either<Failure, T>` in `lib/features/capture/domain/repositories/capture_repository.dart` with `read`, `hold`, and `clear`
- [X] T004 Write failing repository tests that `hold` then `read` returns the same draft, `clear` makes `read` empty, and an `AppException` from the data source becomes `Left`, in `test/features/capture/data/capture_repository_test.dart`
- [X] T005 Store one draft in memory in `lib/features/capture/data/datasources/capture_draft_data_source.dart`. `clear` drops it. Do not write Drift
- [X] T006 Map `AppException` to `Failure` with `RepositoryGuard` in `lib/features/capture/data/repositories/capture_repository_impl.dart`
- [X] T007 [P] Add the review title, confirm, discard, income/expense choice, and uncertain-field hint to `assets/lang/en.json`, `assets/lang/ar.json`, and `lib/config/language/strings.dart`. Reuse the existing amount, date, account, category, notes, and `fenzoTransferCommission` strings
- [X] T008 Register the data source and `CaptureRepository` as `registerLazySingleton` in `lib/features/capture/capture_injection.dart` via `registerCaptureDataLayer`. Do not register cubits in this task

**Checkpoint**: A draft can be held and cleared in memory. Closing the scope drops it. Nothing is saved to the book.

---

## Phase 3: User Story 1 - Correct a draft before it counts (Priority: P1) 🎯 MVP

**Goal**: The person opens review, edits every field, and sees an uncertain mark only when the draft already has one. Nothing is written to the book.

**Independent Test**: Open review with no extra. The draft is an expense dated today and no field is marked uncertain. There is no control to add a mark. Open review with a draft that marks the amount uncertain and that field is distinguished. Leave the screen and balances are unchanged.

### Tests for User Story 1

- [X] T009 [P] [US1] Write a failing widget test in `test/features/capture/presentation/capture_review_page_test.dart` that a hand-started draft shows an expense dated today, no uncertain mark, and no control to mark a field; a supplied draft with `CaptureField.amount` uncertain shows that mark; and neither pump calls `SaveIncomeUseCase` or `SaveExpenseUseCase`

### Implementation for User Story 1

- [X] T010 [US1] Build the editable review screen in `lib/features/capture/presentation/pages/capture_review_page.dart` per `specs/004-capture-draft-review/contracts/review-screen.md`. A null route extra starts the hand draft from T002. A `CaptureDraft` extra is shown as supplied. Offer income and expense only. Offer active accounts and categories of the selected kind. Switching kind clears a category or subcategory that does not fit. Show the fee only for an expense from `AccountType.bank` or `AccountType.eWallet`, starting as that account’s `defaultCommissionMinor`, and replace or clear it when the account or kind changes. Distinguish fields in `uncertainFields`. Do not change that set when the person edits. Do not call a save use case
- [X] T011 [US1] Add `AppRoutes.captureReview` as `/capture/review` in `lib/config/routes/app_routes.dart` and a child `FeatureScope` named `capture` in `lib/config/routes/app_router.dart`, registered with `registerCaptureDataLayer`, passing `state.extra` when it is a `CaptureDraft`. Leave `AppRoutes.transactionForm` and the dashboard primary button unchanged
- [X] T012 [US1] Add a review action on `lib/features/transactions/presentation/pages/transaction_list_page.dart` that pushes `AppRoutes.captureReview` with no extra. Keep the existing floating action button on `AppRoutes.transactionForm`

**Checkpoint**: Review opens beside the current form. Editing and leaving write nothing.

---

## Phase 4: User Story 2 - Confirm one income or one expense (Priority: P1)

**Goal**: Confirm writes exactly one income or one expense through the existing save path, then closes review. A failed confirm stays on the screen and does not change the book.

**Independent Test**: From a known balance, confirm a 40.00 EGP expense and a 40.00 EGP income. The balance moves by exactly those amounts and each record appears once. A bank expense of 200 EGP with a usual fee of 3 EGP decreases the account by 203 EGP. Clearing the fee decreases it by 200 EGP only. An invalid amount saves nothing and leaves the draft editable.

### Tests for User Story 2

- [X] T013 [P] [US2] Write failing use-case tests in `test/features/capture/domain/confirm_capture_draft_use_case_test.dart` that a valid expense calls `SaveExpenseUseCase` once and clears the draft; a valid income calls `SaveIncomeUseCase` once and does not call the expense use case; a bank or e-wallet expense passes `commissionMinor` and a cash, `other`, or income draft passes 0; a save `Failure` leaves the held draft in place; a second confirm after success does not save again
- [X] T014 [P] [US2] Write failing cubit tests for success and error of `ConfirmCaptureDraftCubit.fConfirmCaptureDraft` in `test/features/capture/presentation/confirm_capture_draft_cubit_test.dart`

### Implementation for User Story 2

- [X] T015 [US2] Add `ConfirmCaptureDraftUseCase` extending `UseCase` in `lib/features/capture/domain/usecases/confirm_capture_draft_use_case.dart`. Build `SaveExpenseParams` or `SaveIncomeParams` from the draft and call the existing use case in `lib/features/transactions/domain/usecases/save_expense_use_case.dart` or `lib/features/transactions/domain/usecases/save_income_use_case.dart`. Do not copy amount, date, account, category, or fee checks. On `Right`, clear the held draft. On `Left`, leave the draft held
- [X] T016 [US2] Add `ConfirmCaptureDraftCubit` with `fConfirmCaptureDraft` and a part-file `ApiCallState` typedef in `lib/features/capture/presentation/controller/confirm_capture_draft/confirm_capture_draft_cubit.dart` and `lib/features/capture/presentation/controller/confirm_capture_draft/confirm_capture_draft_states.dart`
- [X] T017 [US2] Register `ConfirmCaptureDraftUseCase` as `registerLazySingleton` and `ConfirmCaptureDraftCubit` as `registerFactory` in `lib/features/capture/capture_injection.dart`, and provide the cubit from the capture `FeatureScope` in `lib/config/routes/app_router.dart`
- [X] T018 [US2] Dispatch `fConfirmCaptureDraft` from the confirm control in `lib/features/capture/presentation/pages/capture_review_page.dart`. On success, `context.pop()`. On error, show the failure message and keep the draft. The widget must not call `SaveIncomeUseCase` or `SaveExpenseUseCase`

**Checkpoint**: Confirm creates one record and returns to the list. Invalid input saves nothing.

---

## Phase 5: User Story 3 - Leave without saving (Priority: P1)

**Goal**: Discard, or leaving review, drops the draft and writes nothing. The next open starts empty.

**Independent Test**: Enter a 100 EGP expense and discard. The balance and the transaction list match the start. Open review again and the 100 is gone. Leave the screen without discard or confirm and nothing is saved.

### Tests for User Story 3

- [X] T019 [P] [US3] Write failing use-case tests in `test/features/capture/domain/discard_capture_draft_use_case_test.dart` that discard clears the held draft and does not call `SaveIncomeUseCase` or `SaveExpenseUseCase`
- [X] T020 [P] [US3] Write failing cubit tests for success and error of `DiscardCaptureDraftCubit.fDiscardCaptureDraft` in `test/features/capture/presentation/discard_capture_draft_cubit_test.dart`

### Implementation for User Story 3

- [X] T021 [US3] Add `DiscardCaptureDraftUseCase` extending `UseCase` in `lib/features/capture/domain/usecases/discard_capture_draft_use_case.dart`. It clears the held draft and does not call a save use case
- [X] T022 [US3] Add `DiscardCaptureDraftCubit` with `fDiscardCaptureDraft` and a part-file `ApiCallState` typedef in `lib/features/capture/presentation/controller/discard_capture_draft/discard_capture_draft_cubit.dart` and `lib/features/capture/presentation/controller/discard_capture_draft/discard_capture_draft_states.dart`
- [X] T023 [US3] Register `DiscardCaptureDraftUseCase` as `registerLazySingleton` and `DiscardCaptureDraftCubit` as `registerFactory` in `lib/features/capture/capture_injection.dart`, and provide the cubit from the capture `FeatureScope` in `lib/config/routes/app_router.dart`
- [X] T024 [US3] Dispatch `fDiscardCaptureDraft` from the discard control in `lib/features/capture/presentation/pages/capture_review_page.dart`, then `context.pop()` on success. Do not pop by calling confirm. Rely on `FeatureScope` disposal in `lib/core/di/feature_scope.dart` to drop the in-memory draft when the route closes without confirm

**Checkpoint**: Discard and leaving the route leave the book unchanged. The next visit starts from a hand draft.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Language parity and the quickstart pass

- [X] T025 [P] Run `flutter test test/features/capture test/config/language/locale_parity_test.dart` and `flutter analyze lib/features/capture` from the repository root
- [X] T026 Walk the device checks in `specs/004-capture-draft-review/quickstart.md`, including the existing add button still opening the current form

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup. Blocks all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational. No dependency on US2 or US3
- **User Story 2 (Phase 4)**: Depends on Foundational. Wiring the button (T018) depends on the page from T010. The use case and cubit (T015–T017) do not
- **User Story 3 (Phase 5)**: Depends on Foundational. Wiring discard (T024) depends on the page from T010. The use case and cubit (T021–T023) do not
- **Polish (Phase 6)**: Depends on US1, US2, and US3

### User Story Dependencies

- **User Story 1 (P1)**: Starts after Foundational. This is the MVP screen
- **User Story 2 (P1)**: Save path can be built after Foundational. The person can confirm only after the US1 screen exists
- **User Story 3 (P1)**: Discard can be built after Foundational. The discard control needs the US1 screen. Leaving the route already drops the scope once T011 is done

### Within Each User Story

- Tests are written and fail before that story’s implementation
- Use case before cubit
- Cubit registration before the page dispatches it
- The page does not call a save use case

### Parallel Opportunities

- T002 and T007 can run together
- T009 can start as soon as T002 exists
- T013 and T014 can run together
- T019 and T020 can run together
- After Foundational, US2’s use case and US3’s use case can be written by different people while US1 builds the page

---

## Parallel Example: User Story 2

```bash
Task: "Write failing confirm use-case tests in test/features/capture/domain/confirm_capture_draft_use_case_test.dart"
Task: "Write failing confirm cubit tests in test/features/capture/presentation/confirm_capture_draft_cubit_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2
2. Complete Phase 3
3. Stop and check the independent test: edit a draft, see marks only when supplied, leave, and confirm the book is unchanged

### Incremental Delivery

1. Setup and Foundational
2. User Story 1: review without saving
3. User Story 2: confirm one income or expense, including the usual fee
4. User Story 3: discard and leave without saving
5. Polish: analyzer, capture tests, locale parity, and the quickstart device pass

### Parallel Team Strategy

1. Finish Setup and Foundational together
2. Then one person builds the page (US1) while another writes the confirm and discard use cases (US2 and US3)
3. Wire the buttons after the page exists

---

## Notes

- [P] tasks touch different files and do not depend on an unfinished task
- User story tasks carry [US1], [US2], or [US3]
- The dashboard primary button and `AppRoutes.transactionForm` stay the current entry, including transfers
- Do not persist the draft and do not bump `schemaVersion`

---

## Phase 7: Convergence

**Purpose**: Close gaps found after implementation against the spec, plan, and constitution

- [X] T027 After a successful confirm in `lib/features/capture/presentation/pages/capture_review_page.dart`, refresh the transaction list, account balances, and dashboard the same way `TransactionListPage._reloadAfterChange` does, before `context.pop()`, so the new income or expense and the updated balance are visible per US2/AC1 (partial)
- [X] T028 When no active account exists, show `Strings.fenzoEmpty` and do not offer confirm on `lib/features/capture/presentation/pages/capture_review_page.dart`, matching `TransactionFormPage`, per the spec edge case "No account exists yet" (partial)
- [X] T029 Map every confirm failure code, including `subcategory_invalid`, to an existing translated string in `CaptureReviewPage` and never show the raw code, per FR-007 (partial)
