# Contract: Receipt capture

The receipt page turns one photo into a review draft. Field mapping is in [data-model.md](../data-model.md). The review screen’s confirm and discard rules stay in [specs/004-capture-draft-review/contracts/review-screen.md](../../004-capture-draft-review/contracts/review-screen.md). What this phase adds on that screen is in [review-photo.md](review-photo.md).

## Open

- The transaction list offers receipt capture in addition to the current add action and the hand-started review action.
- The add action still opens the existing transaction form, including transfer.
- The hand-started review action still opens `/capture/review` with no draft and no photo.
- The receipt action opens `/capture/receipt`.

## Choose a photo

- The page offers take photo and choose photo. The page does not call the image picker itself.
- Cancel before a photo is chosen stays on `/capture/receipt`. No review opens. Balances do not change.
- A refused or unavailable camera or library shows why and stays on the page. No review opens. No blank draft is offered.

## Read

- The shipped reader stays on the device. It does not show an off-device explanation.
- An empty on-device reading opens review with an expense dated today, an empty amount, an empty shop name, and uncertain marks on amount, date, and shop name. The photo is visible. Account and category are not marked uncertain.
- A confident amount, date, or shop name is shown and is not marked uncertain.
- An unsure value is shown and is marked uncertain.
- This step does not save a transaction and does not change balances.

## Off-device reading

- Not shipped. The port still behaves as follows, and tests cover it with a fake.
- If the reader would send the photo and the device is online, the page explains that before the photo is sent. Agree then reads. Skip deletes the photo, sends nothing, and opens a blank review: expense, today, no amount, no shop name, no uncertain marks, no photo.
- If that reader would need a network and the device is offline, the photo is not sent, the photo is deleted, and the same blank review opens. The explanation is not required in that case because nothing is offered to send.

## Failure

- If a photo was chosen and reading fails, the page explains the failure, the photo is deleted, and the person can open the blank review or stay on the receipt page. Nothing is saved.

## Languages

- Take photo, choose photo, reading failed, skipped reading, and the off-device explanation exist in English and Arabic.
- Arabic uses the product’s existing right-to-left layout.
