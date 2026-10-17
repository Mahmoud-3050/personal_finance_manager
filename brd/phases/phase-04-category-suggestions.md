# Phase 4 — Category suggestions

## Goal

Suggest a category for a capture draft from the user’s own history and on-device rules first. Call a cloud classifier only when local matching finds nothing and the device is online. The suggestion is a field on the draft, not a saved transaction.

## BRD coverage

| ID | Statement |
|---|---|
| FR-010 | Suggest categories using local rules and AI when needed. |
| NFR-007 | Prefer local rules, use cloud AI only when needed, and provide a fallback when unavailable. |
| NFR-008 | Avoid tightly coupling business logic to a single AI provider. |
| AC-009 | Service secret keys are not exposed insecurely inside the client application. |
| BR-005 | A suggested category is still reviewed before saving. |
| BR-009 | AI does not determine balances. |

## Depends on

- [Phase 1](phase-01-capture-review.md) — the draft and the review screen, which already shows an editable category.
- Phases 2 and 3 are helpful because they put merchant text or a transcript on the draft. This phase also runs for a hand-filled draft that has notes.
- Existing categories and past transactions, read through their repository interfaces. Do not import another feature’s data layer.

## Decisions needed

| Decision | Working default | Blocks this phase? |
|---|---|---|
| OCR and AI providers | Ship the local matcher now. The cloud port’s first implementation returns no suggestion. Swap in a backend or Firebase function after a provider is chosen. | The cloud data source is blocked. Local suggestions are not. |
| Privacy of text sent for a suggestion | Ask before sending merchant text or a transcript off the device. Skipping leaves the category empty. | No, if this default holds. |

## In scope

- Local match, in order: an on-device rule whose text contains the merchant or transcript, then the category the user picked most often for that same text.
- A cloud classifier interface in domain. The data implementation is a no-op until a provider exists.
- Cloud is called only when local matching is empty and the user agrees to send the text.
- If the cloud call fails, the review screen stays usable with an empty category (NFR-007).
- Optional user feedback: when they change the suggested category before confirm, store that correction as a local rule.
- Secret keys stay off the device. The client calls a backend or a Firebase function (AC-009).

## Out of scope

- An AI coach or decision simulation (FR-018, FR-019).
- Suggesting an amount or a balance.
- Auto-saving the suggestion without the review screen.

## Layers and files

Extend `lib/features/capture/` while only capture reads the rules. Move the rule entity to `lib/shared/domain/entities/` if a second feature needs it.

```text
lib/features/capture/
├── domain/
│   ├── entities/category_suggestion_rule.dart
│   ├── repositories/category_suggestion_repository.dart
│   └── usecases/
│       ├── suggest_category_use_case.dart
│       └── save_category_feedback_use_case.dart
├── data/
│   ├── datasources/
│   │   ├── local_category_suggestion_data_source.dart
│   │   └── cloud_category_suggestion_data_source.dart   # no-op until a provider exists
│   └── repositories/category_suggestion_repository_impl.dart
└── presentation/controller/
    ├── suggest_category/
    └── save_category_feedback/
```

- `registerSuggestCategory` and `registerSaveCategoryFeedback` in `capture_injection.dart`.
- No new route. The review page calls `SuggestCategoryCubit.fSuggestCategory` when a draft has text, and `SaveCategoryFeedbackCubit.fSaveCategoryFeedback` when confirm uses a different category than the suggestion.
- Domain depends on the repository interface, not on a vendor SDK (NFR-008).

## Data changes

Add a Drift table for rules and feedback, and bump `schemaVersion` in `lib/core/database/finance_database.dart`.

Suggested columns: id, match text, category id, optional subcategory id, source (`rule` or `feedback`), updated at.

Include the table in `lib/features/backup/data/models/book_snapshot_model.dart` in the same change, so restore does not drop rules.

## Strings

Add keys in `assets/lang/en.json` and `assets/lang/ar.json` for the suggestion label, “from your history”, the cloud-send confirmation, and the empty-suggestion state. Wire them through `lib/config/language/strings.dart`.

## Tests

- Local matcher: a known merchant returns that category and does not call the cloud source (NFR-007).
- Local matcher: no match and offline returns an empty suggestion, not a failure.
- Cloud path: called only after local returns empty; a thrown `AppException` becomes an empty suggestion so review can continue.
- Feedback use case: a changed category writes one rule.
- Cubit success and error for both actions.
- No API key constant in `lib/` (AC-009).

## Done when

- [ ] Review shows a local suggestion when history or a rule matches (FR-010).
- [ ] Cloud runs only as a fallback, and failure leaves the category blank (NFR-007).
- [ ] Domain has no vendor import (NFR-008).
- [ ] Confirm still requires the user to keep or edit the suggestion (BR-005).
- [ ] The suggestion never writes a balance (BR-009).
- [ ] Rules survive backup and restore.
- [ ] Tests above pass, and both language files contain the new keys.

## Estimate

1.5 weeks for the local matcher, feedback, and the no-op cloud port. A real provider is additional work after it is chosen. Part of the BRD smart-capture window (weeks 7–10) plus the leftover AI slice of weeks 14–16.
