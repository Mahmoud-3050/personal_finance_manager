# Contract: Review photo and shop name

Extends [specs/004-capture-draft-review/contracts/review-screen.md](../../004-capture-draft-review/contracts/review-screen.md). Confirm, discard, fees, kind, and uncertain-mark behavior stay as that contract states. This file adds the receipt photo and the shop name.

## Open

- A route extra of `CaptureReviewRequest` shows that draft and, when the request includes a photo, that photo.
- A null extra or a bare `CaptureDraft` extra shows no photo. A hand-started draft shows no shop name field.
- A blank draft after skip or failed reading shows no photo, no shop name field, and no uncertain marks.

## Photo

- The photo is visible at the top of a receipt proposal until the review route is disposed.
- Confirm, discard, leaving the route, and closing the app remove it. Closing the app is finished by the next app start if the process was killed.
- The photo is not a gallery, not attached to the saved transaction, and not part of a backup.
- There is no control to keep the photo.

## Shop name

- The field is shown when the draft has a shop name or the shop name is uncertain.
- The person can edit it. Editing does not choose a category, does not copy the name into notes, and does not save a transaction.
- A blank shop name does not block confirm.
- An uncertain mark on the shop name is display-only, same as the other marks. The person cannot add or clear it.

## Confirm

- Confirm still saves one income or one expense through the existing save.
- The saved record does not include the shop name or the photo.
- Success still pops the review route. That pop removes the photo.
