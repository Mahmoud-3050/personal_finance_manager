# Phase 3 — Voice capture

## Goal

Let the user describe a transaction by speech, turn that speech into proposed fields, and land on the phase 1 review screen. The recording is not kept, and nothing is saved until review confirms it.

## BRD coverage

| ID | Statement |
|---|---|
| FR-008 | Convert voice input into proposed transaction data. |
| NFR-003 | Minimize data sent to cloud services and explain when external services are used. |
| NFR-006 | Clearly identify fields that still need review. |
| BR-005 | Extracted amount, date, account, or category is reviewed before saving. |
| AC-004 | Extracted voice data is not saved until reviewed and confirmed. |

## Depends on

- [Phase 1](phase-01-capture-review.md) — same `CaptureDraft` and review route.
- No speech package is in the app today. Add one only in this phase, and only inside the capture data source. Domain code does not import it.

## Decisions needed

| Decision | Working default | Blocks this phase? |
|---|---|---|
| Keep images and recordings | Do not keep the recording after the user leaves review. | No, if this default holds. |
| Speech language | Arabic and English, matching the app locales. | The recognizer configuration, not the review screen. |

## In scope

- A speak action that starts and stops listening.
- A speech data source that returns text. If recognition needs a network, explain that before audio leaves the device and allow cancel.
- A domain parser that reads the text into amount, date, and a short note. Missing pieces are marked uncertain.
- A `CaptureDraft` with `source: voice` opened on the phase 1 review page.
- Dropping the audio when review ends.

## Out of scope

- Receipt OCR (phase 2).
- Category suggestion (phase 4). The transcript is on the draft so phase 4 can read it.
- A stored voice library.
- Saving from this phase’s cubit.

## Layers and files

Extend `lib/features/capture/`.

```text
lib/features/capture/
├── domain/
│   ├── services/voice_transcript_parser.dart
│   ├── repositories/voice_capture_repository.dart
│   └── usecases/start_voice_capture_use_case.dart
├── data/datasources/speech_data_source.dart
└── presentation/
    ├── controller/start_voice_capture/
    └── pages/voice_capture_page.dart
```

- `registerStartVoiceCapture` in `capture_injection.dart`. Cubit is a factory. Use case, repository, and speech data source are lazy singletons.
- Route `/capture/voice` in `lib/config/routes/app_routes.dart`, wrapped in `FeatureScope`.
- `StartVoiceCaptureCubit.fStartVoiceCapture` emits `ApiCallState`. Success navigates to `/capture/review`. The page does not call the speech plugin.

The parser is pure Dart: it does not call the network and it does not decide a balance (BR-009).

## Data changes

No Drift table and no schema bump. Audio is session-only.

Backup snapshot is unchanged.

## Strings

Add keys in `assets/lang/en.json` and `assets/lang/ar.json` for start listening, stop, nothing recognized, permission denied, and the notice when recognition would send audio off the device. Wire them through `lib/config/language/strings.dart`.

## Tests

- Parser: a transcript with an amount and a date fills those fields and leaves category uncertain.
- Parser: empty or unusable text returns a draft with every field uncertain and does not throw.
- Use case: success returns a draft and does not call the income or expense save use cases (AC-004).
- Repository and cubit: success and error, including permission failure.

## Done when

- [ ] Speech becomes a draft on the review screen (FR-008).
- [ ] Uncertain fields are marked (NFR-006).
- [ ] Confirm is still required before any balance changes (AC-004, BR-005).
- [ ] The recording is not stored after review.
- [ ] Off-device recognition is explained first (NFR-003).
- [ ] Tests above pass, and both language files contain the new keys.

## Estimate

1 week. Part of the BRD smart-capture window (weeks 7–10).
