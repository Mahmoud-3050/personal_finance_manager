# Data Model: Receipt Capture

Accounts, categories, and the saved income or expense stay on the models the app already has. The review draft from [specs/004-capture-draft-review/data-model.md](../004-capture-draft-review/data-model.md) gains a shop name. The photo is not a database row.

## CaptureField

Add `shopName` to the existing set: `amount`, `date`, `account`, `category`, `subcategory`, `notes`, `commission`, `shopName`.

The person still cannot insert or remove a mark. Editing the shop name does not change the set.

## CaptureDraft

| Field | Required | Rule |
|---|---|---|
| shopName | no | Trimmed shop name from the receipt, or null. Not copied into `notes`. Not sent to the income or expense save. |

All other fields stay as in the capture-draft model. A hand-started draft and a blank draft after skip or failure leave `shopName` null and leave `shopName` out of `uncertainFields`.

A receipt proposal:

- Kind is `expense`.
- Date is the read date, or today when the date was not read. A missing date is in `uncertainFields`.
- `amountMinor` is the read minor-unit amount, or null. Null, zero, and negative are in `uncertainFields` and stored as null.
- `shopName` is the read name, or null. Null, blank, and an unsure name are in `uncertainFields`. A blank name is stored as null. An unsure non-blank name is kept.
- A confident amount, date, or shop name is not in `uncertainFields`.
- `account`, `category`, `subcategory`, `notes`, and `commission` are not added to `uncertainFields` by this mapping.

`copyWith` must be able to set and clear `shopName`. Existing call sites keep compiling because the field defaults to null.

## ReceiptPhoto

| Field | Required | Rule |
|---|---|---|
| path | yes | File under the app temp `receipt-capture` directory. Not a gallery item, not a backup entry, not a transaction attachment. |

Identity: the path. There is no database id.

## ReceiptReading

The reader’s raw result, before it becomes a draft.

| Field | Required | Rule |
|---|---|---|
| amountMinor | no | Null when the reader did not return an amount. |
| date | no | Null when the reader did not return a date. |
| shopName | no | Null or blank when the reader did not return a name. |
| unsure | yes | Subset of `amount`, `date`, and `shopName`. A field listed here was returned but is not confident. |

`EmptyReceiptReader` returns nulls and an empty `unsure` set. The use case still marks the three fields uncertain because they were not returned.

## ReceiptCaptureOutcome

| Outcome | When | Carries |
|---|---|---|
| `ReceiptProposalReady` | A reading was mapped | `CaptureDraft` and `ReceiptPhoto` |
| `ReceiptConsentRequired` | The reader would send the photo, and the device is online | `ReceiptPhoto` only. The reader has not been called |
| `ReceiptBlankReady` | The person skipped, reading failed and they continued, or an off-device reader had no network | Hand-started `CaptureDraft`. No photo |
| `ReceiptCaptureCancelled` | The person closed the camera or the library before choosing a photo | Nothing |

## State

```text
receipt page
  → cancelled                         (picker closed; stay on the page)
  → access denied or unavailable      (error; stay on the page; no draft)
  → consent required                  (photo held; reader not called)
      → proposal ready                (person agrees)
      → blank draft                   (person skips; photo deleted)
  → offline off-device reader         (blank draft; photo deleted; reader not called)
  → proposal ready                    (on-device read, including an empty read)
  → read failed                       (error; photo deleted; person may open a blank draft)
proposal ready or blank draft
  → review open                       (photo visible only for a proposal)
      → photo deleted, draft dropped  (confirm, discard, leave, or review dispose)
app start
  → leftover receipt-capture files deleted
```

Confirm success and failure stay on the existing review state model. A failed confirm does not delete the photo early; leaving the review route does.

## Relationships

- `ReceiptPhoto` is shown by the review route and then deleted. It does not point at an account or a transaction.
- `shopName` sits on the draft until the draft is dropped. Phase 4 may read it. This phase does not suggest a category from it.
- After confirm, the book contains one income or one expense. The draft, the shop name, and the photo are gone.

## Validation owned here

- Kind is expense on a new proposal.
- The uncertain set from a reading contains only `amount`, `date`, and `shopName`, and it contains each of those the reader did not return with confidence.
- Zero and negative amounts are not confident values.
- `shopName` is not a save field.
- The photo path is not a save field.
