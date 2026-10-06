# Implementation Plan: Phase 0 MVP — Personal Money Tracking

**Branch**: `001-phase0-mvp` | **Date**: 2026-10-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-phase0-mvp/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Phase 0 is an Arabic, right-to-left, offline fenzo for one person. They keep accounts with opening balances, record income, expenses, and internal transfers, classify them, and read a current-month dashboard plus date-range reports. Nothing connects to a bank.

The technical approach is one `fenzo` feature in the existing Flutter app. Domain code owns money (integer piastres), the balance formula, and date ranges. Drift stores the facts on device. Cubits call one use case each and never calculate balances in widgets. Decisions are in [research.md](research.md).

## Technical Context

**Language/Version**: Dart `^3.13.4` / Flutter stable (app already created)

**Primary Dependencies**: `flutter_bloc`, `get_it`, `go_router`, `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`, `path`, `intl`, `flutter_localizations`; path packages `packages/either`, `packages/themes`, `packages/language`, `packages/screen_util`, `packages/field_validator`; dev: `bloc_test`, `drift_dev`, `build_runner`

**Storage**: On-device SQLite through Drift. No network database

**Testing**: `flutter_test` and `bloc_test`. Domain tests for money and balances. Repository tests against an in-memory database. Cubit tests for success and error. One widget test for confirm versus cancel

**Target Platform**: Android and iOS (the Flutter project also has desktop and web shells; Phase 0 is specified and checked as a mobile app)

**Project Type**: Mobile app

**Performance Goals**: A report over a personal history of up to 5,000 transactions appears within 2 seconds. Recording an expense takes the person under 30 seconds

**Constraints**: Offline for every Phase 0 story. Arabic RTL only. EGP with at most two decimal places, never rounded. No bank secrets, no sign-in, no real payments. Balances are derived, not stored. Destructive delete and deactivate ask for confirmation

**Scale/Scope**: One person, one device, dozens of accounts and categories, up to 5,000 transactions. Seven user stories. No backup, suggestions, or budgets

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Gates below are `.specify/memory/constitution.md` version 2.2.0, the same text as `.cursor/rules/00-project-constitution.mdc`.

| Gate | Result |
|---|---|
| I. Feature-first layers: presentation → domain ← data. Domain has no Flutter, Dio, or data imports | Pass. One `fenzo` feature. `lib/features/profile/` is not in this repo; `fenzo` uses the prescribed tree |
| II. GetIt through `ServiceLocator`. Feature types registered on the route via `FeatureScope`, not in `ServiceLocator.init()`. Cubits `registerFactory`. Use cases, repository, data source `registerLazySingleton` | Pass. Database registration lives in the fenzo scope |
| III. Cubit per user action, `f` prefix, immutable `ApiCallState<T>`, widgets dispatch with `context.read` and do not call the data source | Pass. Confirm dialogs stay in the widget and only then call `f…` |
| IV. `Either<Failure, T>` from `package:either/either.dart`, not `dartz`. Data source throws `AppException`. Repository maps to `Failure` | Pass. `either` is the path package `packages/either` |
| V. Models map to entities. `fromJson` stays in data. Domain stays pure Dart | Pass. Drift rows map in the data layer. No separate mapper class |
| Use cases extend `UseCase<Type, Params>` | Pass. One use case per repository method |
| Tests for use cases, repository, and cubit success/error. `flutter analyze` clean | Pass. Required before the feature is done |
| No service between cubit and use case, no `BaseCubit` / `BaseRepository` | Pass |
| Local packages `either`, `themes`, `language`, `screen_util`, `field_validator` | Pass. Root `pubspec.yaml` path-depends on `packages/<name>`. Presentation uses those packages instead of pub.dev duplicates |
| VI. Shared app codebase | Pass. Fenzo reuses `lib/core`, `lib/config`, and `lib/shared`. It does not add a second `Failure`, `UseCase`, `ApiCallState`, `FeatureScope`, router, or string table. Local fenzo data does not call Dio |
| HTTP / Dio remote data source | Not applicable. The constitution allows local I/O in the data source. Phase 0 must work offline, so the fenzo data source is local only |

## Project Structure

### Documentation (this feature)

```text
specs/001-phase0-mvp/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── accounts.md
│   ├── transactions.md
│   └── dashboard-and-reports.md
└── tasks.md             # /speckit-tasks — not created here
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── injection_container.dart          # ServiceLocator.init(); no fenzo types
├── core/
│   ├── error/                        # Failure, AppException
│   ├── usecase/usecase.dart
│   └── presentation/                 # ApiCallState, FeatureScope
├── features/fenzo/
│   ├── fenzo_injection.dart
│   ├── data/
│   │   ├── datasources/              # Drift local data source + seed
│   │   ├── models/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/                 # Account, Category, Transaction, Money, CalendarDate
│   │   ├── repositories/
│   │   └── usecases/
│   └── presentation/
│       ├── controller/<operation>/   # one cubit + part-file state
│       ├── navigation/
│       ├── pages/
│       └── widgets/
packages/either/                      # package:either/either.dart
test/
├── features/fenzo/domain/
├── features/fenzo/data/
├── features/fenzo/presentation/
└── widget_test.dart
```

**Structure Decision**: Single Flutter app. Phase 0 is the `fenzo` feature plus the small core types the constitution requires (`ServiceLocator`, `UseCase`, `ApiCallState`, `FeatureScope`, `Failure`). Operations, each with its own cubit and use case:

- Save, deactivate, reactivate, and delete account; get accounts
- Save income, save expense, save transfer, update transaction, delete transaction
- Save, deactivate, and delete category; get categories
- Get dashboard, get report, search transactions

Screens follow [contracts/](contracts/). The balance formula lives in the domain and is the only implementation of [data-model.md](data-model.md) derived figures. Widgets format those results; they do not recompute them.

## Post-Design Constitution Check

Re-checked after [research.md](research.md), [data-model.md](data-model.md), and [contracts/](contracts/).

| Gate | Result |
|---|---|
| Domain purity | Pass. Entities and the balance formula have no Drift, Flutter, or JSON |
| Dependency direction | Pass. Cubits depend on use cases. The repository implementation depends on the local data source. Contracts describe screens, not SQL |
| Either and exceptions | Pass. Validation failures (third decimal place, locked account type, end before start, used category delete) are `Failure` values, not raw database errors |
| Scope | Pass. No backup, sync, AI, or budget types in the model |
| Unresolved clarifications | None |

## Complexity Tracking

No constitution violations require justification.
