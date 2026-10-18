# Implementation Plan: Receipt Capture

**Branch**: `005-receipt-capture` | **Date**: 2026-10-18 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/005-receipt-capture/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

A person takes or chooses one receipt photo from the transaction list, and the existing review screen opens with a proposed expense, that photo, and uncertain marks on any amount, date, or shop name that was not read with confidence. The photo is not part of the book. Confirm still goes through the existing review save. The first reader stays on the device and proposes nothing, so review works with no network and no off-device notice. A later reader that would send the photo must explain first and must offer a blank review that sends nothing.

Decisions are in [research.md](research.md).

## Technical Context

**Language/Version**: Dart `>=3.10.0 <4.0.0` / Flutter (the app SDK constraint)

**Primary Dependencies**: Existing `flutter_bloc`, `get_it`, `go_router`, `image_picker` (already in `pubspec.yaml`, unused in `lib/`), and path packages `either`, `themes`, `language`, `screen_util`, `field_validator`. No new package.

**Storage**: No Drift table and no schema bump. The photo is one file in an app temp directory, removed when review ends and swept on the next app start. The draft stays the in-memory `CaptureDraft` the review route already holds. Backup is unchanged.

**Testing**: `flutter_test` and `bloc_test`. Use-case tests for a proposal, a confident reading, an unsure reading, a skipped reading, and a data-source failure. Repository test that `AppException` becomes `Left`. Cubit tests for success and error. Widget tests that a receipt proposal shows the photo and the shop name, and that a hand-started review shows neither.

**Target Platform**: Android and iOS

**Project Type**: Mobile app

**Performance Goals**: From the transaction list to the review screen in under 1 minute when reading stays on the device or the person skips off-device reading (SC-001). The first reader returns immediately.

**Constraints**: The receipt cubit does not call `SaveIncomeUseCase` or `SaveExpenseUseCase`. Widgets do not call `image_picker`. Domain does not import a reader SDK. Account, category, subcategory, notes, and commission are not marked uncertain only because the reader left them empty. A hand-started review and a blank review show no photo. Amounts stay integer minor units. An unread date is today and is marked uncertain.

**Scale/Scope**: One person, one photo, one open proposal. Four user stories. One new screen, plus the shop name and the photo on the existing review screen.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Gates are `.specify/memory/constitution.md` version 2.2.0.

| Gate | Result |
|---|---|
| I. Feature-first layers. Domain has no Flutter, Dio, or data imports | Pass. Extend `lib/features/capture/`. The reader port is a domain interface. `image_picker` stays in the image data source |
| II. Feature types in `capture_injection.dart` and `FeatureScope`, not in `ServiceLocator.init()`. Cubits `registerFactory`. Use cases, repository, data sources `registerLazySingleton` | Pass. `/capture/receipt` uses its own scope name so it does not replace the review scope. Leftover-file cleanup is a function call from `initApp`, not a GetIt registration |
| III. One cubit per action, `f` prefix, `ApiCallState<T>` in a part file. Widgets dispatch | Pass. `StartReceiptCaptureCubit` emits `ApiCallState<ReceiptCaptureOutcome>`. The page does not pick an image or save a transaction |
| IV. `Either<Failure, T>` from `package:either`. Data sources throw `AppException`. Repository maps with `RepositoryGuard` | Pass |
| V. Models map to entities. Domain stays pure Dart | Pass. `shopName` is a field on `CaptureDraft`. The photo is a path value, not a Drift row |
| Use cases extend `UseCase<T, Params>`. Tests for use cases, repository, and cubits | Pass. Required before the feature is done |
| No service between cubit and use case | Pass. The cubit calls the pick, read, and delete use cases |
| VI. Reuse `lib/core`, `lib/config`, `lib/shared`, `initApp`, and `AppRouter`. No second failure, router, or string table | Pass. Copy goes through `Strings` and `assets/lang`. Money and dates use `Money` and `CalendarDate`. `NetworkInfo` is consulted only when a reader declares that it would send the photo |

## Project Structure

### Documentation (this feature)

```text
specs/005-receipt-capture/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── receipt-capture.md
│   └── review-photo.md
└── tasks.md             # /speckit-tasks — not created here
```

### Source Code (repository root)

```text
lib/features/capture/
├── capture_injection.dart
├── domain/
│   ├── entities/capture_draft.dart          # shopName, CaptureField.shopName
│   ├── entities/receipt_photo.dart
│   ├── entities/receipt_reading.dart
│   ├── entities/receipt_capture_outcome.dart
│   ├── repositories/receipt_capture_repository.dart
│   └── usecases/
│       ├── pick_receipt_image_use_case.dart
│       ├── read_receipt_use_case.dart
│       └── delete_receipt_photo_use_case.dart
├── data/
│   ├── datasources/receipt_image_data_source.dart    # image_picker + temp files
│   ├── datasources/receipt_reader_data_source.dart   # empty on-device reader
│   └── repositories/receipt_capture_repository_impl.dart
└── presentation/
    ├── controller/start_receipt_capture/
    ├── controller/release_receipt_photo/
    └── pages/receipt_capture_page.dart
lib/features/capture/presentation/pages/capture_review_page.dart
                                                   # photo + shop name
lib/config/routes/app_routes.dart                  # /capture/receipt
lib/config/routes/app_router.dart
lib/features/transactions/presentation/pages/transaction_list_page.dart
lib/init_app.dart                                  # sweep leftover photos
assets/lang/en.json
assets/lang/ar.json
lib/config/language/strings.dart
```

**Structure Decision**: Single Flutter app. Receipt capture stays inside `capture` and does not add a second feature. The receipt route and the review route use different `FeatureScope` names. The screen follows [contracts/receipt-capture.md](contracts/receipt-capture.md) and [contracts/review-photo.md](contracts/review-photo.md). The draft and photo follow [data-model.md](data-model.md).

Operations:

- Pick a receipt image
- Read a receipt into a draft
- Delete a receipt photo
- Start receipt capture (cubit composes the three)
- Release the photo when review ends

Widgets format the photo, the shop name, and uncertain marks. They do not decide confidence, consent, or whether a save is valid.

## Post-Design Constitution Check

Re-checked after [research.md](research.md), [data-model.md](data-model.md), [contracts/receipt-capture.md](contracts/receipt-capture.md), and [contracts/review-photo.md](contracts/review-photo.md).

| Gate | Result |
|---|---|
| Domain purity | Pass. `ReceiptReader` is an interface. The empty reader and `image_picker` are data sources |
| Dependency direction | Pass. The receipt cubit does not depend on the save use cases. Confirm still ignores `shopName` |
| Either and exceptions | Pass. A picker or reader `AppException` becomes `Left`. Cancel and offline skip are outcomes, not failures |
| Scope | Pass. No voice, category suggestion, receipt gallery, or Drift change. No off-device reader is shipped |
| Unresolved clarifications | None. The photo is shown only for a receipt proposal. Entry, the empty reader, consent, and deletion are in research |

## Complexity Tracking

No constitution violations.
