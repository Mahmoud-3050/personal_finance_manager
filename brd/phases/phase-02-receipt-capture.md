# Phase 2 — Receipt capture

## Goal

Let the user photograph or pick a receipt, turn it into proposed transaction fields, and land on the phase 1 review screen. The photo is not kept, and the transaction is not saved until review confirms it.

## BRD coverage

| ID | Statement |
|---|---|
| FR-007 | Extract preliminary transaction data from receipt images. |
| NFR-003 | Minimize data sent to cloud services and explain when external services are used. |
| NFR-006 | Minimize entry steps and clearly identify errors and fields requiring review. |
| BR-005 | Extracted amount, date, account, or category is reviewed before saving. |
| AC-004 | Extracted receipt data is not saved until reviewed and confirmed. |

## Depends on

- [Phase 1](phase-01-capture-review.md) — `CaptureDraft` and the review route. This phase only fills a draft and opens that route.
- `image_picker` is already in `pubspec.yaml` and is unused in `lib/`. Use it from the capture data source only.
- Existing save use cases stay behind confirm. This phase does not call them directly.

## Decisions needed

| Decision | Working default | Blocks this phase? |
|---|---|---|
| Receipt languages | Arabic and English printed receipts. Fields the extractor is unsure about are marked uncertain on the draft. | Blocks the choice of OCR engine, not the capture-and-review flow. |
| Keep images and recordings | Delete the image when the user leaves review. No opt-in store in this phase. | No, if this default holds. |
| OCR and AI providers | The OCR port is an interface. A first implementation may return an empty proposal and mark every field uncertain, so review still works offline. A real engine is swapped in after a provider is chosen. | The real extractor is blocked. The screen flow is not. |

## In scope

- Entry from the transaction area: take a photo or pick one from the library.
- An image data source that returns bytes for the current session only.
- An OCR port in domain. The data layer implements it. Domain does not import a vendor SDK.
- Mapping OCR output onto a `CaptureDraft` with `source: receipt`, proposed amount, date, and merchant text, plus uncertain field names.
- Opening the phase 1 review page with that draft.
- Deleting the image file when review is confirmed, discarded, or left.
- If OCR needs a network, tell the user before the image leaves the device and let them skip to a blank review draft.

## Out of scope

- Voice (phase 3).
- Category suggestion (phase 4). The merchant text is stored on the draft so phase 4 can read it.
- Keeping a gallery of receipts.
- Saving a transaction from this phase’s cubit.

## Layers and files

Extend `lib/features/capture/`. Do not add a second feature.

```text
lib/features/capture/
├── domain/
│   ├── repositories/receipt_capture_repository.dart
│   └── usecases/start_receipt_capture_use_case.dart
├── data/datasources/
│   ├── receipt_image_data_source.dart      # image_picker
│   └── receipt_text_data_source.dart       # OCR port implementation
└── presentation/
    ├── controller/start_receipt_capture/
    └── pages/receipt_capture_page.dart
```

- `registerStartReceiptCapture` in `capture_injection.dart`. Cubit is a factory. The use case, repository, and data sources are lazy singletons.
- Route `/capture/receipt` in `lib/config/routes/app_routes.dart`, wrapped in `FeatureScope`.
- `StartReceiptCaptureCubit.fStartReceiptCapture` emits `ApiCallState`. On success the page navigates to `/capture/review` with the draft. The widget does not call `image_picker`.

## Data changes

No Drift table and no schema bump. The image is a temporary file, removed when the session ends.

Backup snapshot is unchanged.

## Strings

Add keys in `assets/lang/en.json` and `assets/lang/ar.json` for take photo, choose photo, extraction failed, offline or skipped extraction, and the notice that a cloud OCR service would send the image. Wire them through `lib/config/language/strings.dart`.

## Tests

- Use case: a successful extraction returns a draft and does not call `SaveExpenseUseCase` or `SaveIncomeUseCase` (AC-004).
- Use case: a data-source failure returns `Left` and still allows an empty draft when the user skips extraction.
- Repository: `AppException` from the image or OCR source becomes `Left`.
- Cubit: success and error.
- The uncertain set contains every field the extractor did not return.

## Done when

- [ ] The user can take or pick a receipt and reach the review screen (FR-007).
- [ ] Uncertain fields are marked (NFR-006).
- [ ] The transaction is absent from balances until confirm on the review screen (AC-004, BR-005).
- [ ] The image is gone after the user leaves review.
- [ ] A cloud extractor, if used, is explained before it runs (NFR-003).
- [ ] Tests above pass, and both language files contain the new keys.

## Estimate

1.5 weeks. Part of the BRD smart-capture window (weeks 7–10). The real OCR engine is extra time after a provider is chosen.
