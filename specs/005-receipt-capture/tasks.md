# Tasks: Receipt Capture

**Input**: Design documents from `/specs/005-receipt-capture/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: The constitution requires unit tests for use cases and repository implementations, and bloc tests for cubit success and error. Those tasks are included. The plan’s widget check for the photo and the shop name is included with User Story 1. The device pass stays in the quickstart.

**Organization**: Tasks are grouped by user story so each story can be implemented and tested on its own.

**Shared code**: Reuse `Failure`, `UseCase`, `ApiCallState`, `FeatureScope`, `RepositoryGuard`, `NetworkInfo`, `SaveIncomeUseCase`, `SaveExpenseUseCase`, `Money`, `CalendarDate`, `Strings`, and `AppRouter`. Do not add a second failure type, router, string table, reader SDK, or Drift table. Do not add a package. `image_picker` is already in `pubspec.yaml`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)

## Phase 1: Setup

**Purpose**: Keep receipt capture inside the existing capture feature. No new package.

- [X] T001 Leave `image_picker` as the existing dependency in `pubspec.yaml` and add no package. Extend `lib/features/capture/` only, per `specs/005-receipt-capture/plan.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The draft field, the photo value, the reader port, and the words every story shows. No user story starts before this.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T002 [P] Add optional `shopName` and `CaptureField.shopName` to `lib/features/capture/domain/entities/capture_draft.dart` per `specs/005-receipt-capture/data-model.md`. Default `shopName` to null so existing call sites keep compiling. `copyWith` must set and clear it. A hand-started draft leaves it null and leaves it out of `uncertainFields`
- [X] T003 [P] Add `ReceiptPhoto` with a required `path` in `lib/features/capture/domain/entities/receipt_photo.dart` per `specs/005-receipt-capture/data-model.md`
- [X] T004 [P] Add `ReceiptReading` (`amountMinor`, `date`, `shopName`, `unsure`) in `lib/features/capture/domain/entities/receipt_reading.dart` per `specs/005-receipt-capture/data-model.md`. `unsure` is a subset of amount, date, and shop name
- [X] T005 [P] Add the sealed `ReceiptCaptureOutcome` (`ReceiptProposalReady`, `ReceiptConsentRequired`, `ReceiptBlankReady`, `ReceiptCaptureCancelled`) in `lib/features/capture/domain/entities/receipt_capture_outcome.dart` per `specs/005-receipt-capture/data-model.md`
- [X] T006 [P] Add `CaptureReviewRequest` with a required `CaptureDraft` and an optional `ReceiptPhoto` in `lib/features/capture/domain/entities/capture_review_request.dart`
- [X] T007 Declare `ReceiptCaptureRepository` returning `Future` results for `pick`, `prepare`, `read`, and `delete`, plus `bool get sendsImageOffDevice`, in `lib/features/capture/domain/repositories/receipt_capture_repository.dart`. `prepare` reports on-device, consent required, or offline without a second failure type
- [X] T008 [P] Add take photo, choose photo, reading failed, skipped reading, the off-device explanation, access denied, and the shop name label to `assets/lang/en.json`, `assets/lang/ar.json`, and `lib/config/language/strings.dart`. Reuse the existing amount, date, account, category, and uncertain-field strings
- [X] T009 Write failing repository tests that an `AppException` from the image source or the reader becomes `Left`, and that `delete` removes a file under the receipt temp directory, in `test/features/capture/data/receipt_capture_repository_test.dart`
- [X] T010 Implement `ReceiptImageDataSource` in `lib/features/capture/data/datasources/receipt_image_data_source.dart`. Call `image_picker` only in this file. Copy the chosen file into an app temp `receipt-capture` directory. Expose `clearLeftoverReceiptPhotos()`. Do not write Drift
- [X] T011 Implement `EmptyReceiptReader` in `lib/features/capture/data/datasources/receipt_reader_data_source.dart`. `sendsImageOffDevice` is false. `read` returns null amount, null date, null shop name, and an empty `unsure` set. Do not import a vendor SDK in `lib/features/capture/domain/`
- [X] T012 Map `AppException` to `Failure` with `RepositoryGuard` in `lib/features/capture/data/repositories/receipt_capture_repository_impl.dart`. On-device `prepare` reads. An off-device reader that is online returns consent and does not read. An off-device reader that is offline does not read. Use `NetworkInfo` from `lib/core/services/network/netwok_info.dart` only for that check
- [X] T013 Register the image source, the empty reader, and `ReceiptCaptureRepository` as `registerLazySingleton` in `lib/features/capture/capture_injection.dart`. Do not register them in `ServiceLocator.init()` in `lib/injection_container.dart`. Do not register cubits in this task

**Checkpoint**: A photo can be stored as a temp file and deleted. The empty reader proposes nothing. Nothing is saved to the book.

---

## Phase 3: User Story 1 - Turn a receipt into a proposal (Priority: P1) 🎯 MVP

**Goal**: From the transaction list, the person takes or chooses one photo and lands on review with that photo and a proposed expense. A confident amount, date, or shop name is filled in. Anything those three were not read with confidence is marked uncertain. The book does not change.

**Independent Test**: From a known balance, choose a photo. Review shows the photo, an empty uncertain amount, today as an uncertain date, and an empty uncertain shop name. Account and category are not marked uncertain. The balance and the transaction list are unchanged. A fake reading with a clear amount, date, and shop name leaves those three unmarked.

### Tests for User Story 1

- [X] T014 [P] [US1] Write failing use-case tests in `test/features/capture/domain/read_receipt_use_case_test.dart` that an empty reading becomes an expense dated today with `amount`, `date`, and `shopName` uncertain and amount null; a confident amount, date, and shop name are set and not uncertain; an unsure value is kept and uncertain; zero or negative amounts are stored as null and uncertain; `account`, `category`, `subcategory`, `notes`, and `commission` are not added; and the use case does not depend on `SaveIncomeUseCase` or `SaveExpenseUseCase`
- [X] T015 [P] [US1] Extend `test/features/capture/presentation/capture_review_page_test.dart` so a `CaptureReviewRequest` with a photo and an uncertain shop name shows the photo and `uncertain-shopName`; a null extra and a bare `CaptureDraft` show no photo and no shop name field; editing the shop name does not select a category; and none of the pumps call `SaveIncomeUseCase` or `SaveExpenseUseCase`
- [X] T016 [P] [US1] Write failing cubit tests in `test/features/capture/presentation/start_receipt_capture_cubit_test.dart` that `fStartReceiptCapture` success with the empty reader emits `ReceiptProposalReady` whose uncertain set is amount, date, and shop name, and that a cancelled pick emits `ReceiptCaptureCancelled` without opening a draft

### Implementation for User Story 1

- [X] T017 [US1] Add `ReadReceiptUseCase` extending `UseCase` in `lib/features/capture/domain/usecases/read_receipt_use_case.dart`. Map `ReceiptReading` onto `CaptureDraft` per `specs/005-receipt-capture/data-model.md`. Do not call a save use case
- [X] T018 [US1] Add `PickReceiptImageUseCase` extending `UseCase` in `lib/features/capture/domain/usecases/pick_receipt_image_use_case.dart`. Return the picked `ReceiptPhoto`, or null when the person cancels
- [X] T019 [US1] Add `StartReceiptCaptureCubit` with `fStartReceiptCapture` and a part-file `ApiCallState<ReceiptCaptureOutcome>` typedef in `lib/features/capture/presentation/controller/start_receipt_capture/start_receipt_capture_cubit.dart` and `lib/features/capture/presentation/controller/start_receipt_capture/start_receipt_capture_states.dart`. On-device success emits `ReceiptProposalReady`. A null pick emits success with `ReceiptCaptureCancelled`
- [X] T020 [US1] Register `PickReceiptImageUseCase` and `ReadReceiptUseCase` as `registerLazySingleton` and `StartReceiptCaptureCubit` as `registerFactory` in `lib/features/capture/capture_injection.dart` via `registerStartReceiptCapture`
- [X] T021 [US1] Build `lib/features/capture/presentation/pages/receipt_capture_page.dart` per `specs/005-receipt-capture/contracts/receipt-capture.md` with take photo and choose photo. Dispatch `fStartReceiptCapture`. On `ReceiptProposalReady`, push `AppRoutes.captureReview` with a `CaptureReviewRequest`. On `ReceiptCaptureCancelled`, stay on the page. The widget must not call `image_picker` or a save use case
- [X] T022 [US1] Add `AppRoutes.captureReceipt` as `/capture/receipt` in `lib/config/routes/app_routes.dart` and a child `FeatureScope` named `receipt-capture` in `lib/config/routes/app_router.dart`, registered with `registerStartReceiptCapture`. Do not reuse the scope name `capture`
- [X] T023 [US1] Add a receipt action on `lib/features/transactions/presentation/pages/transaction_list_page.dart` that pushes `AppRoutes.captureReceipt`. Keep the existing form button on `AppRoutes.transactionForm` and the hand-started review button on `AppRoutes.captureReview`
- [X] T024 [US1] Show the photo only when `CaptureReviewPage` in `lib/features/capture/presentation/pages/capture_review_page.dart` is given a `ReceiptPhoto`, using a `Key` of `receipt-photo`. Show the shop name field only when `shopName` is non-null or `CaptureField.shopName` is uncertain, using the uncertain mark from `lib/features/capture/presentation/widgets/capture_uncertain_mark.dart`. Editing the shop name updates the draft and does not write notes or choose a category
- [X] T025 [US1] In `lib/config/routes/app_router.dart`, pass a `CaptureReviewRequest` extra through to `CaptureReviewPage`. A bare `CaptureDraft` extra still supplies that draft with no photo. A null extra still starts `CaptureDraft.handStarted()`

**Checkpoint**: Choosing a photo opens review with the photo and three uncertain fields. The current form and the hand-started review stay. The book is unchanged.

---

## Phase 4: User Story 2 - Nothing counts until review, and the photo is not kept (Priority: P1)

**Goal**: The photo is removed when review ends, including after the app is killed. Confirm still saves one income or expense and does not store the photo or the shop name.

**Independent Test**: Open a receipt proposal and confirm one complete expense. The photo file is gone and the saved notes do not gain the shop name. Discard or leave another proposal and the photo is gone and the balance matches the start. A hand-started review shows no photo.

### Tests for User Story 2

- [X] T026 [P] [US2] Write failing use-case tests in `test/features/capture/domain/delete_receipt_photo_use_case_test.dart` that delete removes the temp file, a second delete of a missing file still returns `Right`, and the use case does not call `SaveIncomeUseCase` or `SaveExpenseUseCase`
- [X] T027 [P] [US2] Extend `test/features/capture/domain/confirm_capture_draft_use_case_test.dart` so a draft with a shop name saves the notes the person typed and does not substitute the shop name
- [X] T028 [P] [US2] Write failing cubit tests for success and error of `ReleaseReceiptPhotoCubit.fReleaseReceiptPhoto` in `test/features/capture/presentation/release_receipt_photo_cubit_test.dart`

### Implementation for User Story 2

- [X] T029 [US2] Add `DeleteReceiptPhotoUseCase` extending `UseCase` in `lib/features/capture/domain/usecases/delete_receipt_photo_use_case.dart`. It deletes that `ReceiptPhoto` and does not call a save use case
- [X] T030 [US2] Add `ReleaseReceiptPhotoCubit` with `fReleaseReceiptPhoto` and a part-file `ApiCallState` typedef in `lib/features/capture/presentation/controller/release_receipt_photo/release_receipt_photo_cubit.dart` and `lib/features/capture/presentation/controller/release_receipt_photo/release_receipt_photo_states.dart`
- [X] T031 [US2] Register `DeleteReceiptPhotoUseCase` as `registerLazySingleton` and `ReleaseReceiptPhotoCubit` as `registerFactory` in `lib/features/capture/capture_injection.dart`, and provide the cubit from the existing `capture` `FeatureScope` in `lib/config/routes/app_router.dart`
- [X] T032 [US2] From `dispose` in `lib/features/capture/presentation/pages/capture_review_page.dart`, call `fReleaseReceiptPhoto` when the page was opened with a photo, so confirm, discard, and leaving the route delete it. Hold the cubit from `initState` before `dispose`. A hand-started review and a blank review pass no photo
- [X] T033 [US2] In `close` of `lib/features/capture/presentation/controller/start_receipt_capture/start_receipt_capture_cubit.dart`, delete a photo the cubit still holds so leaving `/capture/receipt` before review does not keep the file. Call `super.close()` last
- [X] T034 [US2] Call `clearLeftoverReceiptPhotos()` from `lib/init_app.dart` after `ServiceLocator.init`. Do not register receipt types in `lib/injection_container.dart`
- [X] T035 [US2] Leave `lib/features/capture/domain/usecases/confirm_capture_draft_use_case.dart` building `SaveIncomeParams` and `SaveExpenseParams` from amount, date, account, category, subcategory, notes, and commission only. Do not pass `shopName` or the photo path

**Checkpoint**: Ending review deletes the photo. Confirm still writes one record and does not keep the image or the shop name.

---

## Phase 5: User Story 3 - Explain before a photo leaves the device (Priority: P1)

**Goal**: The shipped reader stays on the device and shows no off-device explanation. A reader that would send the photo must explain first. Skip and a missing network open a blank review and send nothing.

**Independent Test**: With the empty reader, choosing a photo shows no off-device explanation and opens a proposal whose amount, date, and shop name are uncertain. With a fake reader that sends off-device, the explanation appears before `read`, skip opens a hand-started draft with no photo, and an offline device opens that same blank draft without `read`.

### Tests for User Story 3

- [X] T036 [P] [US3] Write failing use-case tests in `test/features/capture/domain/read_receipt_use_case_test.dart` that an on-device reader never returns `ReceiptConsentRequired`; an online off-device reader returns `ReceiptConsentRequired` and does not call `read` until accept; skip deletes the photo and returns `ReceiptBlankReady` as `CaptureDraft.handStarted()`; an offline off-device reader returns that blank draft and does not call `read`
- [X] T037 [P] [US3] Extend `test/features/capture/presentation/start_receipt_capture_cubit_test.dart` with success and error for `fAcceptOffDeviceReading` and `fSkipToBlankDraft`

### Implementation for User Story 3

- [X] T038 [US3] Teach `ReadReceiptUseCase` in `lib/features/capture/domain/usecases/read_receipt_use_case.dart` to return `ReceiptConsentRequired`, `ReceiptProposalReady`, or `ReceiptBlankReady` from the repository `prepare` result in `lib/features/capture/domain/repositories/receipt_capture_repository.dart`. Accept is the only path that calls `read` for an off-device reader. Do not add a cloud SDK
- [X] T039 [US3] Add `fAcceptOffDeviceReading` and `fSkipToBlankDraft` to `lib/features/capture/presentation/controller/start_receipt_capture/start_receipt_capture_cubit.dart`. Skip deletes the held photo and emits `ReceiptBlankReady`. The empty reader never emits `ReceiptConsentRequired`
- [X] T040 [US3] On `ReceiptConsentRequired` in `lib/features/capture/presentation/pages/receipt_capture_page.dart`, explain that the photo would leave the device before any read, using the string from T008. Agree dispatches `fAcceptOffDeviceReading`. Skip dispatches `fSkipToBlankDraft` and pushes review with the hand-started draft and no photo. An on-device result must not show that explanation

**Checkpoint**: The shipped flow never shows the off-device explanation. A fake off-device reader cannot read until the person agrees, and skip sends nothing.

---

## Phase 6: User Story 4 - Continue when the photo cannot be read (Priority: P2)

**Goal**: Cancel and a refused camera or library stay off review. A failed reading explains itself, deletes the photo, and can still open a blank review. Nothing is saved.

**Independent Test**: Cancel the picker, refuse access, and fail the reader. Balances stay unchanged. Only the reader failure offers a blank review, and that review has no photo and no uncertain marks.

### Tests for User Story 4

- [X] T041 [P] [US4] Write failing tests in `test/features/capture/domain/pick_receipt_image_use_case_test.dart` and `test/features/capture/data/receipt_capture_repository_test.dart` that a cancelled pick is not a `Failure`, an access failure is `Left` with a stable access-denied message, a reader `AppException` is `Left` with a stable read-failed message, and skip after that failure still returns a hand-started draft
- [X] T042 [P] [US4] Extend `test/features/capture/presentation/start_receipt_capture_cubit_test.dart` so access denied emits `ApiCallError` and read failure emits `ApiCallError` without emitting `ReceiptProposalReady`

### Implementation for User Story 4

- [X] T043 [US4] In `lib/features/capture/data/datasources/receipt_image_data_source.dart`, treat closing the picker as no photo and throw `AppException` with the access-denied message when the camera or library is unavailable or refused. In `lib/features/capture/data/datasources/receipt_reader_data_source.dart`, a reader failure throws `AppException` with the read-failed message. Do not leak `PlatformException`
- [X] T044 [US4] In `lib/features/capture/presentation/pages/receipt_capture_page.dart`, stay on `/capture/receipt` for cancel and for access denied, with no blank-draft action. For a read failure, show the failure string from T008, and let the person dispatch `fSkipToBlankDraft` or stay. Do not save a transaction

**Checkpoint**: A bad permission does not open review. A failed reading can still open a blank review, and the book is unchanged.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Language parity and the quickstart pass

- [X] T045 [P] Run `flutter test test/features/capture test/config/language/locale_parity_test.dart` and `flutter analyze lib/features/capture` from the repository root
- [ ] T046 Walk the device checks in `specs/005-receipt-capture/quickstart.md`, including the existing add and hand-started review actions

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup. Blocks all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational. No dependency on US2, US3, or US4
- **User Story 2 (Phase 4)**: Depends on Foundational. Releasing the photo from the page (T032) depends on the review page from T024. The delete use case (T029) does not
- **User Story 3 (Phase 5)**: Depends on Foundational and on the cubit and page from US1 (T019, T021)
- **User Story 4 (Phase 6)**: Depends on Foundational and on the receipt page from T021. The picker and reader failure mapping (T043) can start after T010 and T011
- **Polish (Phase 7)**: Depends on US1, US2, US3, and US4

### User Story Dependencies

- **User Story 1 (P1)**: Starts after Foundational. This is the MVP path to review
- **User Story 2 (P1)**: The delete use case can be built after Foundational. The person only sees deletion after the US1 review shows a photo
- **User Story 3 (P1)**: Consent extends the US1 read path. The empty reader already satisfies the on-device half
- **User Story 4 (P2)**: Cancel, access denied, and read failure extend the US1 page. They do not change confirm

### Within Each User Story

- Tests are written and fail before that story’s implementation
- Use case before cubit
- Cubit registration before the page dispatches it
- The receipt page does not call `image_picker` or a save use case

### Parallel Opportunities

- T002, T003, T004, T005, T006, and T008 can run together
- T010 and T011 can run together after T003 and T004
- T014, T015, and T016 can run together
- T026, T027, and T028 can run together
- T036 and T037 can run together
- T041 and T042 can run together
- After Foundational, the delete use case (US2) can be written while US1 builds the page

---

## Parallel Example: User Story 1

```bash
Task: "Write failing read-receipt use-case tests in test/features/capture/domain/read_receipt_use_case_test.dart"
Task: "Extend the review widget test in test/features/capture/presentation/capture_review_page_test.dart"
Task: "Write failing start-receipt cubit tests in test/features/capture/presentation/start_receipt_capture_cubit_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2
2. Complete Phase 3
3. Stop and check the independent test: choose a photo, see it on review with amount, date, and shop name uncertain, and confirm the book is unchanged

### Incremental Delivery

1. Setup and Foundational
2. User Story 1: photo to a proposed expense on the existing review screen
3. User Story 2: delete the photo when the attempt ends, and keep it out of the saved record
4. User Story 3: explain before an off-device read, and skip to a blank review
5. User Story 4: cancel, refused access, and a failed reading
6. Polish: analyzer, capture tests, locale parity, and the quickstart device pass

### Parallel Team Strategy

1. Finish Setup and Foundational together
2. Then one person builds the receipt page and review photo (US1) while another writes delete and the startup sweep (US2)
3. Add consent (US3) and the failure paths (US4) after the receipt page exists

---

## Notes

- [P] tasks touch different files and do not depend on an unfinished task
- User story tasks carry [US1], [US2], [US3], or [US4]
- The transaction form and the hand-started review stay
- Do not persist the photo, do not bump `schemaVersion`, and do not put the photo in a backup
- The shipped reader is `EmptyReceiptReader`. Do not add a cloud SDK in this task list
