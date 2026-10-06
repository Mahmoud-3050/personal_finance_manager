# Tasks: Phase 2 — Backup and Restore

**Input**: Design documents from `/specs/002-phase2-backup/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: The constitution requires unit tests for use cases and repository implementations, and bloc tests for cubit success and error. Those tasks are included. Widget coverage beyond cancel-versus-confirm is the quickstart pass.

**Organization**: Tasks are grouped by user story so each story can be implemented and tested on its own.

**Shared code**: Reuse `Failure`, `UseCase`, `ApiCallState`, `FeatureScope`, `RepositoryGuard`, `FinanceStore`, `NetworkInfo`, `Strings`, `confirm_action_dialog.dart`, and `AppRouter`. Do not add a second failure type, router, or string table.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)

## Phase 1: Setup

**Purpose**: Packages and the backup feature tree

- [X] T001 Add `firebase_auth` and `cloud_firestore` to `pubspec.yaml`
- [X] T002 [P] Create `lib/features/backup/` with `data/datasources/`, `data/models/`, `data/repositories/`, `domain/entities/`, `domain/repositories/`, `domain/usecases/`, `domain/services/`, and `presentation/controller/`, `presentation/pages/` per `specs/002-phase2-backup/plan.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Snapshot, settings, and a real connection check. No user story starts before this.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T003 Add `internet_connection_checker_plus` to `pubspec.yaml` and implement `NetworkInfo.isConnected` in `lib/core/services/network/netwok_info.dart` with `InternetConnection().hasInternetAccess`, removing the stub that always returns connected
- [X] T004 [P] Add `BackupSettings` and `BackupCopy` in `lib/features/backup/domain/entities/backup_settings.dart` and `lib/features/backup/domain/entities/backup_copy.dart` per `specs/002-phase2-backup/data-model.md`
- [X] T005 [P] Add version-1 snapshot JSON in `lib/features/backup/data/models/book_snapshot_model.dart` per `specs/002-phase2-backup/contracts/export-file.md`, mapping through the existing account, category, subcategory, and transaction models
- [X] T006 Declare `BackupRepository` returning `Either<Failure, T>` in `lib/features/backup/domain/repositories/backup_repository.dart`
- [X] T007 Read and replace the device book through `FinanceStore` in `lib/features/backup/data/datasources/book_snapshot_data_source.dart`
- [X] T008 Persist schedule, last attempt, last success, last status, and last source in `lib/features/backup/data/datasources/backup_settings_data_source.dart`, defaulting the schedule to off
- [X] T009 Map `AppException` to `Failure` with `RepositoryGuard` in `lib/features/backup/data/repositories/backup_repository_impl.dart`
- [X] T010 [P] Add backup copy to `assets/lang/en.json`, `assets/lang/ar.json`, and `lib/config/language/strings.dart`
- [X] T011 Register the backup data source, settings data source, snapshot model, and `BackupRepository` in `lib/features/backup/backup_injection.dart` as `registerLazySingleton`. Do not register cubits here

**Checkpoint**: A snapshot of the device book can be built and written back. Settings default to off.

---

## Phase 3: User Story 1 - Keep a cloud copy on demand (Priority: P1) 🎯 MVP

**Goal**: The person sends a complete cloud copy when they ask, sees the last attempt, and a failed send does not change the device book.

**Independent Test**: With a known book and a connection, manual backup shows success and a time. With no connection, the status is not success and balances are unchanged.

### Tests for User Story 1

- [X] T012 [P] [US1] Write failing manual-backup use-case tests for a connected success and an offline non-success in `test/features/backup/domain/run_manual_backup_use_case_test.dart`
- [X] T013 [P] [US1] Write failing repository tests that a failed upload does not call book replace, in `test/features/backup/data/manual_backup_repository_test.dart`
- [X] T014 [P] [US1] Write failing cubit tests for success and error for `RunManualBackupCubit`, `SignInForBackupCubit`, and `GetBackupStatusCubit` in `test/features/backup/presentation/manual_backup_cubit_test.dart`

### Implementation for User Story 1

- [X] T015 [US1] Upload a version-1 snapshot for the signed-in person with the Firestore SDK in `lib/features/backup/data/datasources/cloud_backup_data_source.dart`. Do not send the upload through `DioConsumer`. Sign in with Google only when a cloud send starts. Cancel leaves the book unchanged
- [X] T016 [US1] Add `SignInForBackupUseCase`, `RunManualBackupUseCase`, and `GetBackupStatusUseCase` in `lib/features/backup/domain/usecases/sign_in_for_backup_use_case.dart`, `lib/features/backup/domain/usecases/run_manual_backup_use_case.dart`, and `lib/features/backup/domain/usecases/get_backup_status_use_case.dart`
- [X] T017 [US1] Add cubits and part-file `ApiCallState` types under `lib/features/backup/presentation/controller/sign_in_for_backup/`, `lib/features/backup/presentation/controller/run_manual_backup/`, and `lib/features/backup/presentation/controller/get_backup_status/`
- [X] T018 [US1] Register those use cases and cubits in `lib/features/backup/backup_injection.dart`
- [X] T019 [US1] Build the status screen from `specs/002-phase2-backup/contracts/backup-screens.md` in `lib/features/backup/presentation/pages/backup_status_page.dart`, with a manual backup action and the last time, status, and source
- [X] T020 [US1] Add `AppRoutes.backup` and a `FeatureScope` route in `lib/config/routes/app_routes.dart` and `lib/config/routes/app_router.dart`, and open it from Settings (`lib/features/dashboard/presentation/pages/settings_page.dart`)

**Checkpoint**: Manual backup works online, fails visibly offline, and recording still saves.

---

## Phase 4: User Story 2 - Restore a copy on purpose (Priority: P1)

**Goal**: The person sees at most five successful cloud copies and replaces the device book only after confirmation.

**Independent Test**: Six successes leave five rows. Cancel keeps later edits. Confirm makes the book match the chosen copy.

### Tests for User Story 2

- [X] T021 [P] [US2] Write failing tests that a sixth success drops the oldest copy, a cancelled restore does not replace the book, and a confirmed restore matches the chosen copy’s accounts, transactions, categories, and derived balances, in `test/features/backup/domain/restore_cloud_copy_use_case_test.dart`
- [X] T022 [P] [US2] Write failing repository tests for the five-copy trim in `test/features/backup/data/cloud_copy_repository_test.dart`
- [X] T023 [P] [US2] Write failing cubit tests for restore success and error in `test/features/backup/presentation/restore_cloud_copy_cubit_test.dart`

### Implementation for User Story 2

- [X] T024 [US2] List successful cloud copies and delete the oldest beyond five after a successful upload in `lib/features/backup/data/datasources/cloud_backup_data_source.dart`
- [X] T025 [US2] Add `ListCloudCopiesUseCase` and `RestoreCloudCopyUseCase` in `lib/features/backup/domain/usecases/list_cloud_copies_use_case.dart` and `lib/features/backup/domain/usecases/restore_cloud_copy_use_case.dart`
- [X] T026 [US2] Add cubits and part-file states under `lib/features/backup/presentation/controller/list_cloud_copies/` and `lib/features/backup/presentation/controller/restore_cloud_copy/`
- [X] T027 [US2] Register those use cases and cubits in `lib/features/backup/backup_injection.dart`
- [X] T028 [US2] Build the copy list in `lib/features/backup/presentation/pages/cloud_copies_page.dart`. Confirm with `lib/shared/widgets/confirm_action_dialog.dart`, showing the copy date and that current accounts, transactions, and categories will be replaced, before `fRestoreCloudCopy`
- [X] T029 [US2] Add `AppRoutes.cloudCopies` in `lib/config/routes/app_routes.dart` and `lib/config/routes/app_router.dart`

**Checkpoint**: Restore matches the chosen copy. Cancel changes nothing.

---

## Phase 5: User Story 3 - Send a copy on a schedule (Priority: P2)

**Goal**: Daily, weekly, or monthly cloud copies run when the product opens. Off sends nothing. Offline waits and retries.

**Independent Test**: Daily sends one success on a new calendar day and not a second time the same day. Off sends nothing. Offline shows waiting and does not mark success.

### Tests for User Story 3

- [X] T030 [P] [US3] Write failing schedule tests for daily, Saturday–Friday weekly, calendar monthly, same-day skip, and offline waiting in `test/features/backup/domain/backup_schedule_test.dart`
- [X] T031 [P] [US3] Write failing cubit tests for setting the schedule and for an automatic run success and error in `test/features/backup/presentation/automatic_backup_cubit_test.dart`

### Implementation for User Story 3

- [X] T032 [US3] Decide whether a schedule is due in `lib/features/backup/domain/services/backup_schedule.dart`
- [X] T033 [US3] Add `SetBackupScheduleUseCase` and `RunAutomaticBackupUseCase` in `lib/features/backup/domain/usecases/set_backup_schedule_use_case.dart` and `lib/features/backup/domain/usecases/run_automatic_backup_use_case.dart`
- [X] T034 [US3] Add cubits and part-file states under `lib/features/backup/presentation/controller/set_backup_schedule/` and `lib/features/backup/presentation/controller/run_automatic_backup/`
- [X] T035 [US3] Register those use cases and cubits in `lib/features/backup/backup_injection.dart`, and call `fRunAutomaticBackup` when the finance shell opens in `lib/config/routes/app_router.dart`
- [X] T036 [US3] Add the off, daily, weekly, and monthly control to `lib/features/backup/presentation/pages/backup_status_page.dart`

**Checkpoint**: A due connected open sends one copy. Off and offline do not pretend success.

---

## Phase 6: User Story 4 - Export a file and bring it back (Priority: P2)

**Goal**: The person exports a version-1 file with no passphrase, including while offline, and imports it only after the same replace confirmation. A bad file changes nothing.

**Independent Test**: Export offline, delete a transaction, cancel import, confirm import, then import a non-backup file and see no change.

### Tests for User Story 4

- [X] T037 [P] [US4] Write failing use-case tests for offline export, confirmed import, cancelled import, and a rejected file in `test/features/backup/domain/export_import_use_case_test.dart`
- [X] T038 [P] [US4] Write failing cubit tests for export and import success and error in `test/features/backup/presentation/export_import_cubit_test.dart`

### Implementation for User Story 4

- [X] T039 [US4] Write and read the version-1 file with `file_picker` and `share_plus` in `lib/features/backup/data/datasources/export_file_data_source.dart`. Do not ask for a passphrase
- [X] T040 [US4] Add `ExportBookUseCase` and `ImportBookUseCase` in `lib/features/backup/domain/usecases/export_book_use_case.dart` and `lib/features/backup/domain/usecases/import_book_use_case.dart`
- [X] T041 [US4] Add cubits and part-file states under `lib/features/backup/presentation/controller/export_book/` and `lib/features/backup/presentation/controller/import_book/`
- [X] T042 [US4] Register those use cases and cubits in `lib/features/backup/backup_injection.dart`
- [X] T043 [US4] Add export and import actions to `lib/features/backup/presentation/pages/backup_status_page.dart`. Call import only after `lib/shared/widgets/confirm_action_dialog.dart` confirms, and show the unusable-file message from `specs/002-phase2-backup/contracts/backup-screens.md`

**Checkpoint**: A file round-trip matches the book. A bad file does not.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Analysis and the manual pass

- [X] T044 Run `flutter analyze` and clear every issue in `lib/features/backup/`, `lib/core/services/network/netwok_info.dart`, and `lib/config/routes/`
- [X] T045 [P] Add a widget test that cancelling restore or import leaves the book unchanged, in `test/features/backup/presentation/confirm_restore_test.dart`
- [ ] T046 Walk `specs/002-phase2-backup/quickstart.md` on a device and fix any miss against `specs/002-phase2-backup/contracts/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup. Blocks every story
- **User Story 1 (Phase 3)**: After Foundational. MVP. No other story required
- **User Story 2 (Phase 4)**: After User Story 1, because restore lists cloud copies that manual backup creates
- **User Story 3 (Phase 5)**: After User Story 1, because automatic backup uses the same upload. Can proceed beside User Story 2 after T015
- **User Story 4 (Phase 6)**: After Foundational. Uses the snapshot model and does not need the cloud. Can proceed beside User Story 1
- **Polish (Phase 7)**: After the stories you intend to ship

### User Story Dependencies

- **User Story 1 (P1)**: First shippable slice
- **User Story 2 (P1)**: Needs a cloud copy from User Story 1
- **User Story 3 (P2)**: Needs the upload path from User Story 1. Does not need restore
- **User Story 4 (P2)**: Needs the snapshot model only. Independent of sign-in

### Within Each User Story

- Tests are written and fail before that story’s implementation
- Data source before use cases
- Use cases before cubits
- Cubits registered before pages
- Pages before routes that open them

### Parallel Opportunities

- T002 can run with T001
- T004, T005, and T010 can run together after T002
- All tests marked [P] inside one story can run together
- User Story 4 can be built while User Story 1 is in progress, if `book_snapshot_model.dart` is already done
- User Story 2 and User Story 3 should not edit `cloud_backup_data_source.dart` at the same time

---

## Parallel Example: User Story 1

```bash
# Tests together, then implementation:
# test/features/backup/domain/run_manual_backup_use_case_test.dart
# test/features/backup/data/manual_backup_repository_test.dart
# test/features/backup/presentation/manual_backup_cubit_test.dart

# Then: cloud data source, use cases, cubits, status page, route.
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2
2. Complete Phase 3
3. **STOP and VALIDATE**: Manual backup succeeds online, fails offline, and an expense still saves
4. Demo that slice before restore

### Incremental Delivery

1. Setup + Foundational → snapshot and settings
2. User Story 1 → manual cloud copy
3. User Story 2 → five copies and confirmed restore
4. User Story 3 → schedule
5. User Story 4 → file export and import, including offline
6. Polish → `flutter analyze` and `specs/002-phase2-backup/quickstart.md`

### Parallel Team Strategy

1. Everyone finishes Setup and Foundational
2. One person owns User Story 1, then User Story 2
3. A second person can take User Story 4 as soon as the snapshot model exists
4. User Story 3 starts after the cloud upload in T015 is stable

---

## Notes

- [P] tasks use different files and do not depend on an unfinished task
- [US1] through [US4] map to the stories in `specs/002-phase2-backup/spec.md`
- Confirmation stays in the widget. Cubits run only after confirm
- This phase does not add category suggestions, budgets, or payments

---

## Phase 8: Convergence

**Purpose**: Close gaps between the backup spec, the screen contract, and the current backup code

- [X] T047 Record a failed or waiting outcome when a manual cloud backup cannot be sent, and show that outcome as the last attempt on the status screen per FR-004 and FR-009 (partial)
- [X] T048 Ask the person to identify themselves before the cloud-copy list loads, and leave the book unchanged if they cancel per US1/AC5 (partial)
- [X] T049 Read the import file before confirmation, show its `createdAt`, and replace the book only after the person confirms per FR-011 (contradicts)
- [X] T050 Record an export as the last attempt with source export, without uploading that file per FR-009 (partial)
- [X] T051 Reload accounts, categories, the dashboard, and an open report after a confirmed restore or import so later balances and reports follow the replaced book per FR-013 (partial)
- [X] T052 List at most five cloud copies newest first, and show on each row that it is a cloud copy per US2/AC4 (partial)
- [X] T053 Say in the restore and import confirmation that current accounts, transactions, and categories will be replaced per FR-011 (partial)

---

## Phase 9: Convergence

**Purpose**: Show an export on the status screen, and leave the copy list when identification is cancelled

- [X] T054 Refresh the status screen after an export so the last attempt time, success, and export source are visible per FR-009 (partial)
- [X] T055 When identification is cancelled on the cloud-copy list, return to the backup status screen and leave the book unchanged per contract: cloud copies (partial)
