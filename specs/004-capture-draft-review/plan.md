# Implementation Plan: Capture Draft and Review Screen

**Branch**: `004-capture-draft-review` | **Date**: 2026-10-17 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/004-capture-draft-review/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

One person can open a review screen, edit a proposed income or expense, and confirm it into the book, or leave and change nothing. A hand-started draft has no uncertain marks. A draft that already carries marks shows them, and the person cannot add or clear those marks. A bank or e-wallet expense starts with that account’s usual fee, which the person can change or clear. The current income, expense, and transfer entry stays.

The technical approach is a new `capture` feature. Confirm calls the existing `SaveIncomeUseCase` and `SaveExpenseUseCase`. The draft lives only in the review route’s memory and is dropped when that route closes. Decisions are in [research.md](research.md).

## Technical Context

**Language/Version**: Dart `>=3.10.0 <4.0.0` / Flutter (the app SDK constraint)

**Primary Dependencies**: Existing `flutter_bloc`, `get_it`, `go_router`, and path packages `either`, `themes`, `language`, `screen_util`, `field_validator`. No new package.

**Storage**: No Drift table and no schema bump. The draft is an in-memory value owned by the capture route scope. Confirm writes a normal income or expense through the existing transaction repository.

**Testing**: `flutter_test` and `bloc_test`. Use-case tests for confirm, discard, fee rules, and uncertain marks. Cubit tests for success and error. One widget test that a hand-started draft shows no uncertain control.

**Target Platform**: Android and iOS

**Project Type**: Mobile app

**Performance Goals**: A person who already has an account and a category can fill the screen and confirm one record in under 1 minute (SC-001). Confirm and discard need no network.

**Constraints**: Offline. The existing transaction form, including its transfer path, stays. Hand-started drafts have an empty uncertain set. Uncertain marks are display-only. Amounts stay integer minor units with at most two decimal places. A failed confirm leaves the book and the draft on screen. Leaving the route drops the draft.

**Scale/Scope**: One person, one open draft. Three user stories. One new screen. No receipt, voice, suggestion, or duplicate warning.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Gates are `.specify/memory/constitution.md` version 2.2.0.

| Gate | Result |
|---|---|
| I. Feature-first layers. Domain has no Flutter, Dio, or data imports | Pass. New `lib/features/capture/`. Confirm depends on the transactions use cases, which are domain types, not on `TransactionsRepositoryImpl` |
| II. Feature types in `capture_injection.dart` and `FeatureScope`, not in `ServiceLocator.init()`. Cubits `registerFactory`. Use cases, repository, data source `registerLazySingleton` | Pass. The review route pushes its own scope, nested under the existing finance shell so accounts and categories stay available |
| III. One cubit per action, `f` prefix, `ApiCallState<T>` in a part file. Widgets dispatch | Pass. The page does not call a save use case. Success pops the route in the listener |
| IV. `Either<Failure, T>` from `package:either`. Data source throws `AppException`. Repository maps with `RepositoryGuard` | Pass. Save failures already arrive as `Failure` from the existing use cases and are passed through |
| V. Models map to entities. Domain draft stays pure Dart | Pass. The in-memory holder stores the entity. There is no JSON |
| Use cases extend `UseCase<T, Params>`. Tests for use cases, repository, and cubits | Pass. Required before the feature is done |
| No service between cubit and use case | Pass |
| VI. Reuse `lib/core`, `lib/config`, `lib/shared`, `initApp`, and `AppRouter`. No second failure, router, or string table | Pass. Copy goes through `Strings` and `assets/lang`. Money and dates use `Money` and `CalendarDate` |

## Project Structure

### Documentation (this feature)

```text
specs/004-capture-draft-review/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── review-screen.md
└── tasks.md             # /speckit-tasks — not created here
```

### Source Code (repository root)

```text
lib/features/capture/
├── capture_injection.dart
├── data/
│   ├── datasources/capture_draft_data_source.dart
│   └── repositories/capture_repository_impl.dart
├── domain/
│   ├── entities/capture_draft.dart
│   ├── repositories/capture_repository.dart
│   └── usecases/
│       ├── confirm_capture_draft_use_case.dart
│       └── discard_capture_draft_use_case.dart
└── presentation/
    ├── controller/confirm_capture_draft/
    ├── controller/discard_capture_draft/
    ├── pages/capture_review_page.dart
    └── widgets/
lib/config/routes/app_routes.dart          # /capture/review
lib/config/routes/app_router.dart          # FeatureScope on that route
lib/features/transactions/presentation/pages/transaction_list_page.dart
                                           # second entry; existing FAB stays
```

**Structure Decision**: Single Flutter app. Capture sits beside `transactions` and does not add a second book. The finance shell already registers accounts, categories, and the save use cases. The review route adds a child `FeatureScope` named `capture`.

Operations, each with its own cubit and use case:

- Confirm capture draft
- Discard capture draft

The screen follows [contracts/review-screen.md](contracts/review-screen.md). The draft follows [data-model.md](data-model.md). Widgets format money and uncertain marks. They do not decide whether a fee applies or whether a save is valid.

## Post-Design Constitution Check

Re-checked after [research.md](research.md), [data-model.md](data-model.md), and [contracts/review-screen.md](contracts/review-screen.md).

| Gate | Result |
|---|---|
| Domain purity | Pass. `CaptureDraft` has no Flutter, Drift, or GetIt |
| Dependency direction | Pass. Cubits depend on capture use cases. Confirm calls `SaveIncomeUseCase` or `SaveExpenseUseCase` |
| Either and exceptions | Pass. A rejected amount, date, account, category, or fee is the `Failure` the existing save already returns |
| Scope | Pass. No photo, speech, suggestion, duplicate warning, or transfer on this screen |
| Unresolved clarifications | None. Fee, uncertain marks, and keeping the current entry are in the spec. Entry placement, default kind, default date, and the screen after confirm are in research |

## Complexity Tracking

No constitution violations.
