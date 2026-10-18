# Quickstart: Receipt Capture

Prove receipt capture against [contracts/receipt-capture.md](contracts/receipt-capture.md) and [contracts/review-photo.md](contracts/review-photo.md). Draft and photo rules are in [data-model.md](data-model.md). Confirm still follows [specs/004-capture-draft-review/contracts/review-screen.md](../004-capture-draft-review/contracts/review-screen.md).

## Prerequisites

- Flutter SDK matching the app constraint (`>=3.10.0 <4.0.0`).
- One account and one expense category already on the device.
- No network is required for the shipped reader.

## Run

From the repository root, after the feature’s tests exist:

```bash
flutter test test/features/capture
flutter analyze lib/features/capture
```

`flutter test test/config/language/locale_parity_test.dart` checks that the new English and Arabic strings match.

## Device checks

1. Open the transaction list. Add still opens the current form, including transfer. Review still opens a hand-started expense with no photo and no shop name field.
2. Open receipt capture, take a photo or choose one, and land on review. The photo is visible. Amount and shop name are empty and marked uncertain. The date is today and marked uncertain. Account and category are not marked uncertain. The balance and the transaction list are unchanged.
3. Edit the shop name. No category is selected because of that edit. Confirm a complete expense. One expense exists, the balance moved by that amount only, and the photo is gone. The saved record’s notes do not gain the shop name unless it was typed into notes.
4. Start another receipt, open review, and discard or leave. The balance matches the start and the photo is gone. The next receipt does not restore the previous photo or shop name.
5. Open review by hand, and open a blank review after a failed reading. Neither shows a photo or a shop name field.
6. Deny camera or library access. The page explains why, review does not open, and the balance is unchanged.
7. With no network, take or choose a photo. Review still opens with the photo and the three uncertain fields. No off-device explanation is shown.
