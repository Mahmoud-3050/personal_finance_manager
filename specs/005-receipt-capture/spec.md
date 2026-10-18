# Feature Specification: Receipt Capture

**Feature Branch**: `005-receipt-capture`

**Created**: 2026-10-18

**Status**: Draft

**Input**: User description: "I want to implement phase receipt-capture from brd/phases/phase-02-receipt-capture.md."

A person can photograph a printed receipt, or choose a photo they already have, and land on the existing review screen with a proposed expense. The proposal may include an amount, a date, and the shop name. Anything the reading did not confidently find is marked so the person knows what to check. The photo stays visible only while that review is open, and nothing is added to the book until the person confirms.

This specification covers BRD FR-007 (preliminary data from a receipt image), NFR-003 (explain before data leaves the device), NFR-006 (fewer steps, and mark what still needs review), BR-005 (extracted amount, date, account, or category is reviewed before saving), and AC-004 (receipt data is not saved until the person confirms). Voice capture, category suggestions, a gallery of receipts, and saving from this step are not part of this specification. Confirming or discarding still follows the review screen.

## Clarifications

### Session 2026-10-18

- Q: During review, can the person see the receipt photo? → A: Yes. The review screen shows that photo for this attempt only. It is removed when they confirm, discard, leave, or the app closes. A hand-started review and a blank review after a skip do not show a photo.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Turn a receipt into a proposal (Priority: P1)

From the transaction area, a person takes a photo of a printed receipt or chooses a photo they already have. The product reads what it can and opens the existing review screen with one proposed expense and that photo. A confidently read amount, date, or shop name is filled in and is not marked uncertain. An amount, date, or shop name that was not read, or that was read but is unsure, is marked uncertain. A returned value that is unsure is still shown. The person chooses the account and the category on the review screen. Those fields are not marked uncertain merely because the receipt did not name them. The book is unchanged.

**Why this priority**: Photographing a receipt is the reason for this phase. Without a proposal on the review screen, the person is still typing every field by hand.

**Independent Test**: From a known balance, take or choose one Arabic or English receipt whose total and date are clearly printed, and check that the review screen shows that photo, that amount and date without an uncertain mark, and the shop name, leaves account and category for the person, and that the balance and transaction list are unchanged.

**Acceptance Scenarios**:

1. **Given** the person is in the transaction area, **When** they choose to take a photo or to choose an existing photo, **Then** they can supply one receipt image and reach the review screen with a proposed expense and that photo visible.
2. **Given** a printed Arabic or English receipt with one clear total, a clear date, and a clear shop name, **When** reading finishes, **Then** the review screen shows that amount, that date, and that shop name, and none of those three is marked uncertain.
3. **Given** reading did not return an amount, a date, or a shop name, **When** the review screen opens, **Then** each missing one of those three is marked uncertain. A date that was not read is shown as today and is still marked uncertain. An amount that was not read is empty and marked uncertain.
4. **Given** reading returned an amount, a date, or a shop name but is not sure of it, **When** the review screen opens, **Then** that value is shown and that field is marked uncertain.
5. **Given** a receipt proposal is on the review screen, **When** the person looks at account, category, subcategory, notes, and any transfer commission, **Then** those are not marked uncertain only because the receipt reader left them empty.
6. **Given** the shop name is shown, **When** the person corrects it, **Then** the review screen shows the corrected name, no category is chosen for them, and no transaction is saved.
7. **Given** the person already records income, expense, and transfers by hand, **When** receipt capture is available, **Then** those existing ways of recording remain available.

---

### User Story 2 - Nothing counts until review, and the photo is not kept (Priority: P1)

The receipt photo exists only for this attempt. While a receipt proposal is open, the person can see that photo on the review screen. The person is not offered a gallery of receipts, and the photo is not attached to a saved record or included in a backup. Confirming, discarding, or leaving the review screen removes the photo. Closing the app during the attempt removes it as well. A review started by hand, or a blank review after a skip or a failed reading, does not show a photo. The transaction list and balances change only if the person later confirms on the review screen, under the rules that screen already uses.

**Why this priority**: A receipt photo is sensitive, and a guessed amount must not change a balance by itself. Both rules are part of accepting this phase.

**Independent Test**: Start from a known balance, open a receipt proposal, and check that the photo is visible. Then confirm once, and in a second attempt discard or leave. After confirm, exactly one record exists and the photo is gone. After discard or leave, the balance matches the start and the photo is gone. Open a hand-started review and a blank review after a skip, and check that neither shows a photo.

**Acceptance Scenarios**:

1. **Given** a receipt proposal is on the review screen and has not been confirmed, **When** the person looks at the review screen, **Then** they can see the receipt photo, and balances, reports, and the transaction list match their values from before the photo was chosen.
2. **Given** a complete proposal the person confirms on the review screen, **When** confirm succeeds, **Then** one income or one expense is saved under the existing review rules, and the receipt photo is gone.
3. **Given** a receipt proposal, **When** the person discards it, leaves the review screen, or closes the app before confirm, **Then** no transaction is created and the receipt photo is gone.
4. **Given** the person looks for the photo after confirm, discard, or leave, **Then** the product does not offer a gallery, does not attach the photo to the saved record, and does not include the photo in a backup.
5. **Given** the person starts receipt capture again after confirm, discard, or leave, **When** the new attempt opens, **Then** it does not restore the previous photo or the previous proposal.
6. **Given** the person opens a review by hand, or a blank review after skipping off-device reading or after a failed reading, **When** the review screen appears, **Then** no receipt photo is shown.

---

### User Story 3 - Explain before a photo leaves the device (Priority: P1)

If reading the receipt would send the photo off the device, the person is told that before it is sent, and they can continue with a blank review instead. Choosing that path sends nothing. While no off-device reader is in use, the product does not show that warning. Reading that stays on the device and finds nothing still opens the review screen with that photo, and with the amount, the date, and the shop name marked uncertain, so the person can type them without a network connection.

**Why this priority**: The person must know when a receipt leaves the device, and they must still be able to record the expense when reading cannot help.

**Independent Test**: With reading set to stay on the device, choose a photo and check that no off-device warning appears and that a proposal still opens with uncertain amount, date, and shop name when nothing was read. With reading set to send the photo off the device, check that the warning appears before any send, and that skipping opens a blank review and sends nothing.

**Acceptance Scenarios**:

1. **Given** reading would send the photo off the device, **When** the person has chosen a photo and reading has not yet started, **Then** they are told that the photo would leave the device, and the photo has not been sent yet.
2. **Given** that explanation is showing, **When** the person chooses to skip, **Then** the photo is not sent, the photo is removed, and the review screen opens as a blank draft: an expense dated today, no amount, no shop name, no uncertain marks, and no receipt photo.
3. **Given** that explanation is showing, **When** the person agrees, **Then** reading may use the photo and the review screen opens with that photo visible, with whatever was confidently read, and with uncertain marks on the amount, date, or shop name that were not confidently read.
4. **Given** reading stays on the device, **When** the person chooses a photo, **Then** no off-device explanation is shown.
5. **Given** on-device reading returns no amount, date, or shop name, **When** the review screen opens, **Then** the receipt photo is visible, those three are marked uncertain, and the person can fill them with no network connection.
6. **Given** the device has no network connection and reading would have needed one, **When** the person chooses a photo, **Then** they can continue with the same blank review as a skip, and the photo is not sent.

---

### User Story 4 - Continue when the photo cannot be read (Priority: P2)

If the camera or the photo library cannot be used, or the person cancels before a photo is chosen, they stay in the transaction area and nothing is created. If a photo was chosen but reading fails, they are told, and they can open a blank review or go back. A failed reading does not save a transaction.

**Why this priority**: A bad photo or a refused permission must not trap the person or write a guessed record. The happy path in Story 1 still delivers value without this recovery, but the recovery is required before the flow is safe to use.

**Independent Test**: Cancel the camera, refuse photo access, and feed a photo that cannot be read. In each case, confirm that balances are unchanged. After a failed reading, continue to a blank review and confirm that no uncertain marks were added and no transaction exists yet.

**Acceptance Scenarios**:

1. **Given** the person opened the camera or the photo chooser, **When** they cancel before a photo is chosen, **Then** they remain in the transaction area, no review draft is opened, and balances are unchanged.
2. **Given** the camera or the photo library is unavailable or access was refused, **When** the person tries to supply a receipt, **Then** they are told why, no draft is opened, and balances are unchanged.
3. **Given** a photo was chosen and reading fails, **When** the failure is shown, **Then** the person can open a blank review draft or return to the transaction area, the photo is removed, and no transaction is saved.
4. **Given** the person opens the blank review after a failure or a skip, **When** the review screen appears, **Then** it matches a review they started by hand: an expense dated today, no amount, no shop name, no uncertain marks, and no receipt photo.

---

### Edge Cases

- The receipt is blurry, blank, or not a receipt. Reading does not invent an amount. The amount, date, and shop name are marked uncertain, or the person is offered a blank review if reading fails outright. Nothing is saved.
- The receipt is not in Arabic or English. Fields the reader cannot understand are marked uncertain rather than filled with a guess. No transaction is saved until the person confirms on the review screen.
- Several amounts are printed and no single total is clear. The amount is left empty and marked uncertain. Line items are not saved as separate transactions.
- The only clear amount uses more than two decimal places, or the receipt is in a currency other than the product’s currency. That amount is not proposed as a confident value. The amount is marked uncertain so the person can type the figure they want to record.
- The date on the receipt is missing or not a real calendar date. The review screen shows today and marks the date uncertain. Confirm still uses the existing rule that the date must be on or after the account’s start date.
- The shop name is missing. It is marked uncertain, and the person may leave it blank. A blank shop name does not block confirm.
- The person switches the proposal from expense to income on the review screen (for example a refund). The existing review rules apply, including clearing a category that does not match the new kind. The shop name remains available to edit.
- No account exists yet. The person can still open the proposal, and confirm fails with the same guidance as a review they started by hand.
- The app is closed after a photo is chosen and before confirm. The photo is gone when they return, the proposal is not waiting, and no transaction was saved.
- Two receipt attempts are not kept at once. Starting again after the previous attempt ended does not restore the earlier photo.
- A review started by hand, a blank review after a skip, and a blank review after a failed reading show no receipt photo. Only an open receipt proposal shows the photo, and only until that attempt ends.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: From the transaction area, the person MUST be able to take one photo of a receipt or choose one existing photo, and then reach the existing review screen. The current income, expense, and transfer entry MUST remain available.
- **FR-002**: The product MUST turn that photo into one proposed draft. The draft starts as an expense. It MAY include a proposed amount, a proposed date, and a proposed shop name. The person MUST still be able to change the kind on the review screen.
- **FR-003**: An amount, date, or shop name that was read with confidence MUST be shown on the review screen and MUST NOT be marked uncertain.
- **FR-004**: An amount, date, or shop name that was not read, or that was read but is unsure, MUST be marked uncertain on the review screen. An unsure value that was returned MUST still be shown. When the date was not read, the screen shows today and the date stays marked uncertain. When the amount was not read, the amount is empty and marked uncertain.
- **FR-005**: Account, category, subcategory, notes, and transfer commission MUST NOT be marked uncertain only because the receipt reader did not propose them. The person sets account and category on the review screen, as they already can.
- **FR-006**: The shop name MUST be visible and editable while the draft is open. Changing it MUST NOT choose a category and MUST NOT save a transaction. The shop name is not required to confirm, and it MUST NOT be copied into the saved record on its own.
- **FR-007**: Choosing a photo, reading it, and opening the review screen MUST NOT change balances, reports, or the transaction list. This step MUST NOT save a transaction. A transaction is created only when the person confirms on the review screen, under the rules that screen already uses.
- **FR-008**: While a receipt proposal is on the review screen, the person MUST be able to see that receipt photo. The photo MUST be removed when the person confirms, discards, or leaves the review screen, when the app closes during the attempt, and when the attempt ends before review opens. A review started by hand, a blank review after a skip, and a blank review after a failed reading MUST NOT show a receipt photo. The product MUST NOT keep a gallery of receipts, MUST NOT attach the photo to the saved transaction, and MUST NOT include the photo in a backup.
- **FR-009**: If reading would send the photo off the device, the product MUST explain that, in the person’s current language, before the photo is sent, and MUST let them continue with a blank review draft without sending the photo. That blank draft is an expense dated today, with no amount, no shop name, no uncertain marks, and no receipt photo.
- **FR-010**: When reading stays on the device, the product MUST NOT show the off-device explanation. If that reading returns no amount, date, or shop name, the review screen MUST still open with those three marked uncertain.
- **FR-011**: If the device has no network connection and reading would need one, the person MUST be able to continue with the blank review from FR-009, and the photo MUST NOT be sent.
- **FR-012**: If reading fails after a photo was chosen, the product MUST tell the person, MUST remove the photo, and MUST let them open the blank review from FR-009 or return to the transaction area without saving.
- **FR-013**: If the person cancels before a photo is chosen, or the camera or photo library is unavailable or access is refused, the product MUST stay in the transaction area, MUST explain a refused or unavailable access, MUST open no draft, and MUST leave balances unchanged.
- **FR-014**: The prompts for taking a photo, choosing a photo, a failed reading, a skipped reading, and the off-device explanation MUST be available in the languages the product already supports, including Arabic and English, with a right-to-left layout for Arabic.
- **FR-015**: Reading aims to understand printed receipts in Arabic and English. A receipt it cannot understand MUST NOT be saved on its own. Unread amount, date, and shop name are marked uncertain as in FR-004.
- **FR-016**: This step MUST NOT suggest a category, MUST NOT capture voice, and MUST NOT save from anywhere except the existing review confirm.
- **FR-017**: Only one receipt attempt is open at a time. A new attempt after confirm, discard, leave, or a failed reading MUST NOT restore the previous photo or proposal.

### Key Entities

- **Receipt photo**: One image the person just took or chose for this attempt. While the receipt proposal is open, it is shown on the review screen. It is not part of the book, not part of a backup, and not available after the attempt ends. A hand-started review and a blank review do not have one.
- **Receipt proposal**: The review draft opened from that photo. It starts as an expense and may carry an amount, a date, a shop name, and uncertain marks on those three. It is not a saved transaction. It lasts only while the review screen is in use. Account, category, and any transfer commission are completed on that screen under the existing review rules.
- **Saved transaction**: The income or expense that exists only after a successful confirm on the review screen. It follows the same balance and report effect as a record the person confirmed from a review they started by hand.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A person who already has an account and a category can go from the transaction area to the review screen with a receipt proposal in under 1 minute when reading stays on the device or when they skip off-device reading.
- **SC-002**: In 100% of attempts, balances, reports, and the transaction list stay unchanged until the person confirms on the review screen.
- **SC-003**: In 100% of confirm, discard, leave, and app-close outcomes, the receipt photo is no longer available in the product and is not part of a backup. A successful confirm adds exactly one record.
- **SC-004**: In 100% of receipt proposals, every amount, date, or shop name that was not read with confidence is visibly marked before confirm. Account and category are not marked uncertain merely for being unproposed.
- **SC-005**: In 100% of attempts that would send the photo off the device, the person sees an explanation before the photo is sent, and skipping sends nothing while still opening a blank review.
- **SC-006**: A person can reach a usable review screen with no network connection by skipping off-device reading, or by using reading that stays on the device.
- **SC-007**: In 100% of open receipt proposals, the person can see that receipt photo on the review screen before the attempt ends. In 100% of hand-started reviews and blank reviews after a skip or a failed reading, no receipt photo is shown.

## Assumptions

- The review screen from the capture-draft phase already exists. This phase fills a draft and opens that screen. Confirm, discard, uncertain-mark display, transfer commission, and validation stay as that screen already defines them. An uncertain mark still does not block a valid confirm.
- A receipt reader that sends photos off the device is not chosen yet. The capture and review flow must work without one. On-device reading may propose nothing and mark the amount, the date, and the shop name uncertain. A later reader can replace that behavior. Any reader that would send the photo off the device must use the explanation in FR-009.
- Receipt photos are deleted by default. This phase has no choice to keep them. The photo is shown only while a receipt proposal is open, so the person can check the marked fields against it. It is not shown on a review started by hand or on a blank review.
- When one total is clearly printed, that total is the proposed amount. Separate line items are not separate transactions. If no total is clear, the amount is not guessed.
- The product records a single currency, as it does today. Amounts on a receipt in another currency are not converted. The amount is marked uncertain so the person types the figure to record.
- The shop name is kept on the draft so a later category suggestion can read it. This phase does not suggest a category. The name is not required, and it is not written into the saved notes unless the person types it there.
- One photo per attempt. Multi-page receipts are out of scope.
- Duplicate detection is out of scope. Confirm does not warn about a similar existing record.
- Only one person uses the book, on one device. The screen does not move real money.
- A refused camera or photo-library permission is explained in the product. This phase does not change the device’s permission settings by itself.
