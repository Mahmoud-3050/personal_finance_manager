# Research: Receipt Capture

## Where the person starts

**Decision**: Add a receipt action on the transaction list, beside the existing review action. It opens `/capture/receipt`. That page offers take photo and choose photo. The list’s add action still opens `/transactions/form`, including transfer. The review action still opens `/capture/review` with no draft.

**Rationale**: The spec starts from the transaction area and keeps the current income, expense, and transfer entry. A dedicated page matches the two photo actions and is where consent, failure, and skip are explained before review opens.

**Alternatives considered**: Two list buttons that open the camera or the library directly were rejected because consent and failure need a page that is not the review screen. Replacing the review action was rejected because a hand-started review must stay.

## What the first reader does

**Decision**: Domain defines `ReceiptReader`. The data layer ships `EmptyReceiptReader`. `sendsImageOffDevice` is false. `read` returns no amount, no date, and no shop name. `ReadReceiptUseCase` then builds an expense dated today whose uncertain set is exactly `amount`, `date`, and `shopName`. No off-device explanation is shown.

**Rationale**: The spec requires the flow to work before a reader is chosen, offline, with those three fields marked uncertain. An empty reader satisfies that without a vendor SDK in domain.

**Alternatives considered**: Blocking the screen on a cloud provider was rejected because the spec says the flow is not blocked. Guessing an amount was rejected because an empty reading must not invent one.

## When a reader would send the photo

**Decision**: `ReadReceiptUseCase` asks the repository before any read. The repository checks `sendsImageOffDevice` and `NetworkInfo`.

- On-device reader: read immediately and return `ReceiptProposalReady`.
- Off-device reader, device online: return `ReceiptConsentRequired` and do not read. Accept calls read. Skip deletes the photo and returns `ReceiptBlankReady`.
- Off-device reader, device offline: do not read and do not show consent. Return `ReceiptBlankReady` and delete the photo.

The shipped reader is on-device, so the consent branch is covered by a fake in tests. No cloud SDK is added.

**Rationale**: The spec requires the explanation before a photo leaves the device, and a blank review when the person skips or the network is missing. Putting the branch in the use case keeps the page from deciding it.

**Alternatives considered**: Always showing the warning was rejected because an on-device read must not show it. Sending first and explaining after was rejected by the spec.

## How a reading becomes a draft

**Decision**: `ReadReceiptUseCase` maps `ReceiptReading` onto `CaptureDraft`.

- A returned amount, date, or shop name that is not in `unsure` is filled and is not uncertain.
- A value in `unsure` is kept and that field is uncertain.
- A missing amount stays empty and is uncertain. Zero, negative, or an amount the reader could not express as minor units is treated as missing.
- A missing date becomes today and is uncertain.
- A missing or blank shop name stays empty and is uncertain.
- `account`, `category`, `subcategory`, `notes`, and `commission` are never added because the reader omitted them.
- Kind is expense. The person can switch kind on the existing review screen.

**Rationale**: This is the spec’s confident versus uncertain rule, including today’s date for an unread date and an empty amount. The existing confirm path already rejects an empty amount.

**Alternatives considered**: Marking every empty review field uncertain was rejected because the spec forbids that for account and category. Leaving an unread date blank was rejected because `CaptureDraft.date` is required and the spec says to show today with the mark.

## Where the photo and the shop name live

**Decision**: `CaptureDraft.shopName` is an optional string. `CaptureField.shopName` is added. The photo is a separate `ReceiptPhoto` (a file path in the app temp directory), passed with the draft as `CaptureReviewRequest`. A null route extra and a bare `CaptureDraft` extra still mean no photo, so the current hand-started review keeps working.

The review screen shows the photo only when the request has one. It shows the shop name field only when `shopName` is non-null or `shopName` is uncertain. Editing the shop name updates the draft and does not write notes. `ConfirmCaptureDraftUseCase` keeps building save params from amount, date, account, category, subcategory, notes, and commission only.

**Rationale**: The spec shows the photo for a receipt proposal and hides it for a hand-started or blank review. The shop name must be editable for a later suggestion and must not become the saved record by itself. Keeping it off the save params preserves that.

**Alternatives considered**: Putting the file path on `CaptureDraft` was rejected because confirm would then carry a file the book does not store. Copying the shop name into notes was rejected because confirm would save text the person did not put in notes.

## When the photo is deleted

**Decision**: `image_picker` runs only inside `ReceiptImageDataSource`. The chosen file is copied into a `receipt-capture` directory under the app temp directory. `DeleteReceiptPhotoUseCase` deletes that file. The review page calls `ReleaseReceiptPhotoCubit.fReleaseReceiptPhoto` from `dispose`, which covers confirm, discard, and leaving the route. If the person leaves the receipt page before review, `StartReceiptCaptureCubit.close` deletes a photo it still holds. `initApp` calls `clearLeftoverReceiptPhotos()` so a killed app does not keep the file until the next launch. The directory is not a Drift table and is not part of backup.

**Rationale**: The spec removes the photo when the attempt ends, including when the app is closed. `dispose` covers a normal leave. A startup sweep covers a process kill, which does not run `dispose`.

**Alternatives considered**: Deleting the picker cache in place was rejected because that cache is not ours and a startup sweep would be unsafe. Storing the image in the database was rejected because backup would then include it.

## How the cubit reports the outcome

**Decision**: `StartReceiptCaptureCubit` emits `ApiCallState<ReceiptCaptureOutcome>`.

- `fStartReceiptCapture(source)` picks, then reads or asks for consent.
- `fAcceptOffDeviceReading` reads the held photo.
- `fSkipToBlankDraft` deletes the held photo, if any, and returns a hand-started draft.
- Picker cancel emits success with `ReceiptCaptureCancelled`. The page stays on `/capture/receipt`.
- Access denied or an unavailable camera or library emits `ApiCallError` and does not offer a blank draft.
- A reader failure emits `ApiCallError` with a stable message the page uses to offer `fSkipToBlankDraft`. The photo is already deleted.

The page navigates to `/capture/review` only for `ReceiptProposalReady` and `ReceiptBlankReady`. It does not call `image_picker` or a save use case.

**Rationale**: Consent, cancel, and a blank draft are not failures. The spec treats a refused permission differently from a failed reading. One cubit matches one user operation, with a separate method for each decision the person can take. Pick, read, and delete stay separate use cases because each is one repository method.

**Alternatives considered**: A second state hierarchy was rejected because `ApiCallState` can carry the outcome. One use case that also saved the transaction was rejected by the spec.

## Which GetIt scope

**Decision**: `/capture/receipt` uses `FeatureScope` name `receipt-capture`. `/capture/review` keeps the name `capture`. Review’s scope also registers the delete use case and `ReleaseReceiptPhotoCubit`, so a receipt proposal can delete its file even though the receipt scope is underneath.

**Rationale**: Both routes would otherwise share the name `capture`. The review route drops and replaces a scope of the same name, which would dispose the receipt registrations while that page was still under the stack.

**Alternatives considered**: Registering the receipt types in `ServiceLocator.init()` was rejected by the constitution. Reusing the review scope for the picker was rejected because the receipt page must exist before review opens.
