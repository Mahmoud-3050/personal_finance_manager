# Implementation Plan: Phase 2 — Backup and Restore

**Branch**: `002-phase2-backup` | **Date**: 2026-10-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/002-phase2-backup/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Phase 2 lets one person copy the on-device book to the cloud, on demand or on a daily, weekly, or monthly schedule, restore one of the five newest cloud copies, and export or import the same snapshot as a file with no passphrase. Recording stays on the device and does not require identification. Identification is asked only to send or retrieve a cloud copy.

The technical approach is a new `backup` feature. It snapshots and replaces the existing `FinanceStore` book. Cloud files go to Firebase Storage for the Firebase Auth user created from the Google sign-in the app already depends on. Decisions are in [research.md](research.md).

## Technical Context

**Language/Version**: Dart `>=3.10.0 <4.0.0` / Flutter (the app SDK constraint)

**Primary Dependencies**: Existing `flutter_bloc`, `get_it`, `go_router`, `drift`, `google_sign_in`, `file_picker`, `share_plus`, `firebase_core`; add `firebase_auth` and `firebase_storage`. Path packages `either`, `themes`, `language`, `screen_util`, `field_validator`

**Storage**: Device book stays Drift. Backup settings stay on the device (preferences). Cloud copies are Firebase Storage objects, five newest successes. Export is a version-1 JSON file

**Testing**: `flutter_test` and `bloc_test`. Use-case tests for schedule due dates, the five-copy trim, and invalid files. Repository tests with a fake cloud and a fake network. Cubit tests for success and error. One widget test that cancel does not restore

**Target Platform**: Android and iOS

**Project Type**: Mobile app

**Performance Goals**: A manual cloud backup of a personal book shows success or failure within 1 minute on a normal connection. Export of that book completes without a connection

**Constraints**: Device book is the working copy. Automatic backup is off until chosen. Weekly is Saturday–Friday. Restore and import replace the whole book only after confirmation. No passphrase. No bank secrets. Offline recording still works. `NetworkInfo` must report a real connection; the current stub always returns connected

**Scale/Scope**: One person. At most five successful cloud copies. The same book size as Phase 0, up to 5,000 transactions in one snapshot. Four user stories

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Gates are `.specify/memory/constitution.md` version 2.2.0.

| Gate | Result |
|---|---|
| I. Feature-first layers. Domain has no Flutter, Dio, or data imports | Pass. New `lib/features/backup/`. It reads the book through `FinanceStore` in `lib/core/database`, not through another feature’s repository |
| II. Feature types in `backup_injection.dart` and `FeatureScope`, not in `ServiceLocator.init()`. Cubits `registerFactory`. Use cases, repository, data sources `registerLazySingleton` | Pass |
| III. One cubit per action, `f` prefix, `ApiCallState<T>` in a part file. Widgets dispatch; they do not upload or parse the file | Pass. Confirm before restore and import stays in the widget |
| IV. `Either<Failure, T>` from `package:either`. Data source throws `AppException`. Repository maps with `RepositoryGuard` | Pass |
| V. Export JSON on models. Domain snapshot stays pure Dart | Pass. Version field and rejection of other versions live in the data model |
| Use cases extend `UseCase<T, Params>`. Tests for use cases, repository, and cubits | Pass. Required before the feature is done |
| No service between cubit and use case | Pass |
| VI. Reuse `lib/core`, `lib/config`, `lib/shared`, `initApp`, and `AppRouter`. No second failure, router, or string table | Pass. New copy goes through `Strings` and `assets/lang` |
| Network via `DioConsumer` | Exception, justified below. Cloud backup uses the Firebase Storage SDK, which is not this app’s HTTP API |

## Project Structure

### Documentation (this feature)

```text
specs/002-phase2-backup/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── backup-screens.md
│   └── export-file.md
└── tasks.md             # /speckit-tasks — not created here
```

### Source Code (repository root)

```text
lib/features/backup/
├── backup_injection.dart
├── data/
│   ├── datasources/       # cloud storage, settings, export file, book snapshot
│   ├── models/            # snapshot JSON version 1
│   └── repositories/
├── domain/
│   ├── entities/          # backup settings, backup copy
│   ├── repositories/
│   └── usecases/          # one per action below
└── presentation/
    ├── controller/<operation>/
    └── pages/
lib/core/database/         # existing FinanceStore load/save; backup does not add a second book
lib/core/services/network/ # real NetworkInfo check
lib/config/routes/         # backup routes on the existing router
```

**Structure Decision**: Single Flutter app. Phase 2 is the `backup` feature beside `accounts`, `categories`, `transactions`, `dashboard`, and `reports`. The finance shell registers it so the automatic check runs when the product opens. Operations, each with its own cubit and use case:

- Get backup status
- Sign in for cloud backup
- Run manual backup
- Set backup schedule
- Run automatic backup
- List cloud copies
- Restore cloud copy
- Export book
- Import book

Screens follow [contracts/backup-screens.md](contracts/backup-screens.md). The file follows [contracts/export-file.md](contracts/export-file.md). Widgets format status and dates; they do not decide whether a schedule is due or whether a file is version 1.

## Post-Design Constitution Check

Re-checked after [research.md](research.md), [data-model.md](data-model.md), and [contracts/](contracts/).

| Gate | Result |
|---|---|
| Domain purity | Pass. Settings, copy, and schedule-due rules have no Firebase, Drift, or Flutter |
| Dependency direction | Pass. Cubits depend on use cases. The repository writes the device book only through `FinanceStore` |
| Either and exceptions | Pass. Offline, bad file, and cancelled identification are `Failure` values |
| Scope | Pass. No category suggestion, budget, or payment types |
| Unresolved clarifications | None. Identification, five copies, and no passphrase are in the spec |

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| Cloud I/O does not use `DioConsumer` | Firebase Storage is the selected cloud backup transport and is not an HTTP endpoint this app defines | Routing the upload through Dio would not speak Firebase’s protocol and would invent a second cloud |
