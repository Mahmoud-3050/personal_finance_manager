# Phase 9 — Release readiness

## Goal

Prove the new phases and the existing financial core on Android and iOS, with both languages complete, before calling the BRD MVP done.

## BRD coverage

| ID | Statement |
|---|---|
| AC-010 | Core financial functions are tested on Android and iOS before release. |
| NFR-005 | Support the Android and iOS versions selected during implementation planning. |
| AC-009 | Re-check that no service secret key shipped inside the client. |

This phase does not add a feature. It closes the checks named in the implementation plan’s release slice.

## Depends on

- [Phase 2](phase-02-receipt-capture.md), [phase 3](phase-03-voice-capture.md), and [phase 4](phase-04-category-suggestions.md) for capture.
- [Phase 6](phase-06-safe-to-spend.md) for the explained figure.
- [Phase 7](phase-07-duplicate-warning.md) and [phase 8](phase-08-cash-flow-forecast.md) for the Should items included in this release.
- Existing accounts, transactions, categories, dashboard, reports, and backup, which already have tests and still need a device pass.

Phase 4’s cloud provider may still be the no-op. Release does not wait on a vendor if the local suggestion and the empty fallback work.

## Decisions needed

| Decision | Working default | Blocks this phase? |
|---|---|---|
| Minimum OS versions | Record whatever the Flutter project already targets in `android/` and `ios/`. Do not raise them in this phase unless a new plugin requires it. | Recording the numbers is part of the phase. Choosing a higher floor is not required to start. |

## In scope

- Run the automated tests for capture, obligations, goals, Safe-to-Spend, duplicates, and the forecast, including offline and cancel paths.
- Confirm `test/config/language/locale_parity_test.dart` passes after every new key from phases 1–8 exists in both `assets/lang/en.json` and `assets/lang/ar.json`.
- A written device pass, on one Android device and one iOS device, of: add account, manual expense, transfer, receipt review then confirm, voice review then discard, local category suggestion, obligation, savings goal, Safe-to-Spend lines, duplicate warning cancel and keep, forecast empty state and payday set, backup and restore.
- Record the minimum Android and iOS versions from the project files into this phase’s checklist once they are read.
- Search the client for embedded API keys before release (AC-009).

## Out of scope

- New product behavior.
- FR-018 and FR-019.
- Store listing, screenshots, and crash-reporting setup beyond what the app already has.
- Raising the minimum OS as a product decision.

## Layers and files

No new feature folder. Fixes found during the pass go back into the phase that owns the defect, using that phase’s layers.

Checks to run:

- `flutter test` for the suites named above.
- `flutter analyze` with no new warnings in the touched features.
- `test/config/language/locale_parity_test.dart` for string parity.

Device notes can live in a short checklist at the bottom of this file when the pass happens. They are not a new spec.

## Data changes

None, unless a device pass finds a snapshot gap. That fix belongs in the phase that added the table (phase 4 or phase 5) and must include the backup model.

## Strings

No new keys of its own. This phase fails if any key added in phases 1–8 is missing from either language file.

## Tests

The acceptance checks are the existing automated tests plus the device script:

- AC-004: discard a voice draft and a receipt draft and confirm balances did not change.
- AC-006: Safe-to-Spend on the device lists each included and excluded amount.
- AC-007: restore after phase 5 still brings back an obligation and a goal.
- AC-008: duplicate cancel writes nothing; keep writes the new row only.
- AC-009: no vendor secret in the app binary’s source.
- AC-010: the script above is done on Android and on iOS.

## Done when

- [ ] Automated tests for phases 1–8 pass.
- [ ] `locale_parity_test` passes (Arabic and English).
- [ ] `flutter analyze` is clean for the features those phases touched.
- [ ] The device script is signed off on Android and on iOS (AC-010).
- [ ] Minimum OS versions are written down from the project (NFR-005).
- [ ] No service secret key is in the client (AC-009).

## Estimate

2–4 weeks, overlapping the end of the feature phases. This matches the BRD release window (weeks 17–20) for one developer, and it shrinks if the automated tests from earlier phases already cover the acceptance cases.
