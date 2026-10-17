# Phase 1 — Capture draft and review screen

## Goal

Give the user one review screen for a proposed transaction. Nothing is written to the book until they confirm, and cancel leaves the book unchanged.

## BRD coverage

| ID | Statement |
|---|---|
| FR-009 | Review and edit extracted data before saving. |
| BR-005 | Any amount, date, account, or category extracted from image, voice, or AI must be reviewed before saving. |
| AC-004 | Extracted receipt or voice data is not saved until reviewed and confirmed. |

This phase builds the review path with a draft the user can fill by hand. Phases 2 and 3 plug extractors into the same draft. Phase 4 plugs a category suggestion into it.

## Depends on

Existing save paths, reused as-is:

- `lib/features/transactions/domain/usecases/save_income_use_case.dart` — `SaveIncomeUseCase`
- `lib/features/transactions/domain/usecases/save_expense_use_case.dart` — `SaveExpenseUseCase`
- Account and category pickers already used by the transaction form
- `lib/config/routes/app_routes.dart` and `FeatureScope` for the new route

No earlier remaining phase.

## Decisions needed

| Decision | Working default | Blocks this phase? |
|---|---|---|
| Keep images and recordings | The draft holds field values only. Media is a later phase. | No |
| OCR and AI providers | None. The user types or edits every field. | No |

## In scope

- A pure-Dart `CaptureDraft`: source (`manual` for this phase), proposed amount, date, account, category, subcategory, notes, and a set of field names that are uncertain.
- A review page that edits those fields and shows which ones are uncertain.
- Confirm saves an income or an expense through the existing use cases.
- Discard drops the draft and does not write a transaction.
- Income versus expense is a choice on the review screen. Transfers stay on the existing transaction form.

## Out of scope

- Taking a photo, OCR, speech, or category suggestion (phases 2–4).
- A second transaction repository.
- Persisting the draft across app restarts.
- Duplicate warning (phase 7).

## Layers and files

New feature `lib/features/capture/`, three layers, registered only from its injection file. Do not register these types in `ServiceLocator.init()`.

```text
lib/features/capture/
├── capture_injection.dart
├── domain/
│   ├── entities/capture_draft.dart
│   ├── repositories/capture_repository.dart
│   └── usecases/
│       ├── confirm_capture_draft_use_case.dart
│       └── discard_capture_draft_use_case.dart
├── data/
│   ├── datasources/capture_draft_data_source.dart
│   ├── models/capture_draft_model.dart
│   └── repositories/capture_repository_impl.dart
└── presentation/
    ├── controller/confirm_capture_draft/
    ├── controller/discard_capture_draft/
    ├── pages/capture_review_page.dart
    └── widgets/
```

- `capture_injection.dart` exposes `registerCaptureDataLayer`, `registerConfirmCaptureDraft`, and `registerDiscardCaptureDraft`. Cubits are `registerFactory`. Use cases, the repository, and the data source are `registerLazySingleton`.
- Route `/capture/review` is added in `lib/config/routes/app_routes.dart`. The route builder wraps the page in `FeatureScope` and provides the cubits with `BlocProvider`.
- One cubit per action: `ConfirmCaptureDraftCubit.fConfirmCaptureDraft` and `DiscardCaptureDraftCubit.fDiscardCaptureDraft`. State is `ApiCallState`. The page dispatches with `context.read`. It does not call a repository.
- `ConfirmCaptureDraftUseCase` builds `SaveIncomeParams` or `SaveExpenseParams` and calls the existing use case. Domain code stays free of Flutter.

## Data changes

No Drift table and no schema bump. The draft lives in memory for the review session.

`lib/features/backup/data/models/book_snapshot_model.dart` is unchanged, because nothing new is stored in the book until confirm, and confirm writes a normal transaction the snapshot already includes.

## Strings

Add keys to both `assets/lang/en.json` and `assets/lang/ar.json` for the review title, field labels, uncertain-field hint, confirm, discard, and the income/expense choice. Wire them through `lib/config/language/strings.dart`.

## Tests

- Use case: confirm with a valid expense calls save and returns the updated book. Confirm with a missing amount or account returns a failure and does not save.
- Use case: discard returns success and does not call save.
- Repository: maps a data-source `AppException` to `Left`.
- Cubit: success and error for confirm, and success for discard.
- Acceptance: after discard, and before confirm, the transaction list and balances do not contain the draft (AC-004).

## Done when

- [ ] A draft can be edited on the review screen.
- [ ] Confirm creates one income or one expense through the existing save use cases.
- [ ] Discard writes nothing (AC-004).
- [ ] Uncertain fields are visible on the draft, even if this phase never sets them.
- [ ] Tests above pass, and both language files contain the new keys.

## Estimate

1 week. This is the first slice of the BRD smart-capture window (weeks 7–10).
