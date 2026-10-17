# Feature Specification: Capture Draft and Review Screen

**Feature Branch**: `004-capture-draft-review`

**Created**: 2026-10-17

**Status**: Draft

**Input**: User description: "I want to implement the feature of phase Capture draft and review screen, from brd/phases/phase-01-capture-review.md."

A person can open one review screen for a proposed income or expense, correct every field, and only then add it to their book. Leaving the screen without confirming adds nothing. This is the review step required before any later receipt, voice, or suggestion flow is allowed to save money. Photo capture, voice capture, category suggestions, and duplicate warnings are not part of this specification.

This specification covers BRD FR-009 (review and edit before saving), BR-005 (extracted fields are reviewed before saving), and AC-004 (nothing is saved until the person confirms). In this slice the person fills the draft on the review screen. Later slices may arrive with fields already proposed.

## Clarifications

### Session 2026-10-17

- Q: When the person confirms an expense from a bank account or e-wallet, does this review screen collect the transfer commission the way the existing expense entry does? → A: Yes. Bank and e-wallet expenses show the paying account’s usual fee, and the person can change or clear it before confirm. The purchase amount and the fee stay separate. Income, cash, and other accounts do not take a fee on this screen. Transfers are still not offered here.
- Q: In this slice, how does a field become uncertain? → A: Display only. A draft the person starts by hand has no uncertain fields. A mark is shown only when the draft already carries one. The person cannot add or clear a mark. Empty fields are not marked uncertain.
- Q: Does the review screen replace the current income and expense entry? → A: No. The current income and expense entry stays. Review is an additional way to type those records. Transfers stay on their own entry.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Correct a draft before it counts (Priority: P1)

A person opens a review screen for a new income or expense. They set or change the kind of record, the amount, the date, the account, the category, an optional subcategory, and optional notes. When the draft is an expense from a bank account or a digital wallet, they also see a transfer commission that starts as that account’s usual fee, and they can change or clear it. A draft the person starts by hand has no uncertain fields. If a draft already carries an uncertain mark, that field is visibly marked so the person knows what to check. The person cannot add or clear those marks. Nothing on this screen changes an account balance until they confirm in a later step.

**Why this priority**: The product’s rule is that the person stays in control of every figure. Without a review screen, later capture from a receipt or from speech would have nowhere safe to land.

**Independent Test**: Open the review screen with no prior draft, fill or change each field, and check that no field is marked uncertain. Open a draft that already marks the amount as uncertain and check that the amount is visibly distinguished. Leave without confirming and check that balances and the transaction list are unchanged.

**Acceptance Scenarios**:

1. **Given** the person has at least one active account and a matching category, **When** they open the review screen to start a draft by hand, **Then** they see an editable draft with kind (income or expense), amount, date, account, category, optional subcategory, and optional notes, no field is marked uncertain, and no new transaction exists yet.
2. **Given** a draft is on the review screen, **When** the person changes the amount, date, account, category, subcategory, or notes, **Then** the screen shows the edited values and the book is still unchanged.
3. **Given** a draft already marks a field uncertain, **When** the person looks at that field, **Then** it is visibly distinguished from fields that are not uncertain. **Given** a draft the person started by hand, **When** they look for a way to mark or clear uncertainty, **Then** there is none.
4. **Given** the person switches the draft from expense to income, or from income to expense, **When** the previously chosen category does not belong to the new kind, **Then** that category is cleared and they must choose a category of the new kind.
5. **Given** the person is reviewing a draft, **When** they look for a way to record a transfer between their own accounts, **Then** that action is not offered on this screen.
6. **Given** an expense draft whose paying account is a bank or a digital wallet with a usual fee of 3 EGP, **When** the review screen opens or the person selects that account, **Then** the commission starts at 3 EGP and the person can change it or clear it. The account’s stored usual fee stays 3 EGP.
7. **Given** an income draft, or an expense draft paid from cash or from an account that is neither a bank nor a digital wallet, **When** the person reviews it, **Then** no transfer commission is offered.

---

### User Story 2 - Confirm one income or one expense (Priority: P1)

A person who is satisfied with the draft confirms it. The product saves exactly one income or one expense, using the same rules as recording that kind of transaction by hand. The account balance and reports then include that one record. Confirming again is not possible from the same draft, because the draft is finished.

**Why this priority**: Editing a draft is not useful until confirm writes one real record. The current income and expense entry stays, so confirm is what makes this additional screen worth opening.

**Independent Test**: From a known account balance, confirm one 40.00 EGP expense and one 40.00 EGP income on two drafts, and check that the balance moved by exactly those amounts and that each appears once.

**Acceptance Scenarios**:

1. **Given** a complete expense draft (amount greater than zero, at most two decimal places, an active account, an expense category, and a date on or after that account’s start date), **When** the person confirms, **Then** one expense is saved, that account’s balance decreases by the amount, and the expense appears in that date’s records.
2. **Given** a complete income draft with the same completeness rules and an income category, **When** the person confirms, **Then** one income is saved, that account’s balance increases by the amount, and the income appears in that date’s records.
3. **Given** a confirmed draft, **When** the person looks for that same draft still waiting, **Then** it is gone, and confirming it cannot create a second copy.
4. **Given** the amount is zero, negative, or has more than two decimal places, **When** the person confirms, **Then** nothing is saved and they are told why.
5. **Given** the account is missing, inactive, or the date is before the account’s start date, or the category is missing or of the wrong kind, **When** the person confirms, **Then** nothing is saved and they are told why.
6. **Given** a field was marked uncertain but now holds a valid value, **When** the person confirms an otherwise complete draft, **Then** the record is saved. The uncertain mark does not block a valid confirm.
7. **Given** a bank account with a usual fee of 3 EGP and a balance of 1,000 EGP, **When** the person confirms an expense of 200 EGP and leaves the starting fee of 3 EGP unchanged, **Then** the account decreases by 203 EGP, spending increases by 203 EGP, the 200 EGP stays in the chosen category, and the 3 EGP is shown separately as the transfer commission.
8. **Given** that same starting fee of 3 EGP, **When** the person clears it or sets it to 0 EGP and confirms, **Then** the account decreases by the expense amount only, and the account’s usual fee stays 3 EGP.
9. **Given** a commission that is negative or has more than two decimal places, **When** the person confirms, **Then** nothing is saved and they are told why.

---

### User Story 3 - Leave without saving (Priority: P1)

A person who does not want the draft leaves it. Cancel, discard, or leaving the review screen drops the draft. Balances, reports, and the transaction list stay as they were.

**Why this priority**: A review screen that sometimes saves on the way out would break the rule that nothing counts until the person confirms.

**Independent Test**: Start from a known balance, enter a 100 EGP expense on the review screen, discard it, and confirm the balance and the transaction list match the start.

**Acceptance Scenarios**:

1. **Given** a draft with an amount and an account filled in, **When** the person discards it, **Then** no transaction is created and balances and reports stay as they were.
2. **Given** a draft the person has edited, **When** they leave the review screen without confirming, **Then** the draft is dropped and nothing is saved.
3. **Given** the person discarded a draft, **When** they open the review screen again, **Then** they get an empty draft, not the discarded one.
4. **Given** the app is closed while a draft is open and not confirmed, **When** the person returns, **Then** that draft is not waiting and no transaction was saved.

---

### Edge Cases

- No account exists yet. The person cannot confirm a draft. They are told to add an account first, the same as when they try to record a transaction by hand.
- Subcategory and notes are empty. Confirm still succeeds when amount, date, account, and category are valid.
- The person confirms with an income category while the draft is an expense, or the reverse. Nothing is saved until the category matches the kind.
- A field is uncertain and also empty when it is required (amount, date, account, or category). Confirm fails with the same reason as a missing value. The uncertain mark stays visible. An empty required field on a hand-started draft is not marked uncertain. It fails confirm because the value is missing.
- The person edits an uncertain field. The mark stays until confirm or discard. Editing does not add a mark, and it does not clear one. The mark never writes a transaction by itself.
- Two drafts are not open as two saved records. This slice keeps one review at a time. Starting review again after discard or confirm starts empty.
- The amount uses the product’s existing money rule: at most two decimal places, rejected rather than rounded. With no commission, the balance changes by exactly the confirmed amount. With a commission, the paying account decreases by the expense amount plus the fee.
- Switching the paying account before confirm replaces the starting fee with the new account’s usual fee. A bank or wallet switched to cash, or to an account that is neither a bank nor a digital wallet, drops the fee. Income never shows a fee. A saved expense keeps the fee that was confirmed. Changing the account’s usual fee later does not change that saved expense.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The product MUST offer one review screen for a single proposed income or expense before that proposal is part of the book. This screen is an additional way to record income or expense. The current income and expense entry MUST remain, and transfers MUST stay on their own entry.
- **FR-002**: The person MUST be able to set the draft’s kind to income or expense, and MUST be able to edit amount, date, account, category, subcategory, and notes on that screen.
- **FR-003**: The review screen MUST NOT offer an internal transfer. Transfers stay on the existing transfer entry.
- **FR-004**: The product MUST show each uncertain mark the draft already carries, in a way the person can see before they confirm. A draft the person starts by hand MUST have no uncertain marks. The person MUST NOT be able to add or clear a mark. Empty fields MUST NOT be marked uncertain for being empty.
- **FR-005**: Opening, editing, or discarding a draft MUST NOT change account balances, reports, or the transaction list.
- **FR-006**: Confirm MUST save exactly one income or one expense that matches the draft, and MUST apply the same acceptance rules as recording that kind of transaction by hand (amount greater than zero, at most two decimal places, active account, category of the matching kind, date on or after the account’s start date, and the transfer-commission rules in FR-014 and FR-015).
- **FR-007**: A failed confirm MUST leave the book unchanged and MUST tell the person which rule failed.
- **FR-008**: After a successful confirm, that draft MUST be finished so the same draft cannot be confirmed again.
- **FR-009**: Discard, leaving the review screen without confirming, and closing the app during review MUST drop the draft and MUST NOT create a transaction.
- **FR-010**: A new visit to the review screen MUST start from an empty draft when the previous one was confirmed, discarded, or lost because the person left.
- **FR-011**: An uncertain mark MUST NOT block confirm when the field’s value satisfies the rules in FR-006.
- **FR-012**: Switching kind MUST clear a category or subcategory that does not belong to the new kind.
- **FR-013**: The review screen MUST be usable without a network connection, as with the rest of recording.
- **FR-014**: When the draft is an expense from a bank account or a digital wallet, the review screen MUST show a transfer commission that starts as that paying account’s usual fee. The person MUST be able to change or clear it before confirm. A blank or zero fee means no commission. The purchase amount and the fee stay separate, and the paying account decreases by both when the fee is greater than zero.
- **FR-015**: The review screen MUST NOT offer a transfer commission on income, on an expense from cash, or on an expense from an account that is neither a bank account nor a digital wallet. Switching away from a bank or digital wallet, or switching the draft to income, MUST remove the fee from the draft.

### Key Entities

- **Capture draft**: A proposed income or expense that is not yet in the book. It holds the kind, amount, date, account, category, optional subcategory, optional notes, an optional transfer commission when FR-014 applies, and the set of fields currently marked uncertain. It exists only while the review screen is in use. The commission is not the account’s stored usual fee. Editing it does not change that usual fee.
- **Saved transaction**: The income or expense that exists only after a successful confirm. It is the same kind of record the person already creates by hand, and it follows that record’s effect on balances and reports.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A person who already has an account and a category can fill the review screen and confirm one record in under 1 minute.
- **SC-002**: In 100% of discard, leave, and app-close cases during review, the account balance and the transaction list are identical to their values before the draft was opened.
- **SC-003**: A successful confirm adds exactly one record, with no second copy from the same draft. With no commission, that account’s balance changes by exactly the confirmed amount. With a commission, it changes by the expense amount plus the fee.
- **SC-004**: Every field marked uncertain is visible as uncertain on the review screen before confirm, in 100% of drafts that carry such a mark.
- **SC-005**: A person can complete review, confirm, and discard with no network connection.

## Assumptions

- This slice is used by hand. The person opens the review screen and types the fields. Receipt photos, voice, and category suggestions are later work and are not required to test this specification. The current income and expense entry remains available beside this screen.
- A draft is not kept after the person leaves the review screen or after the app closes. There is no list of unfinished drafts.
- Uncertain marks are a warning, not a lock. They tell the person to look. A valid value can still be confirmed. This slice does not create those marks. A later receipt or voice draft may arrive with marks already set, and this screen shows them.
- Money, dates, accounts, categories, and transfer commissions follow the rules already used when the person records income or expense by hand, including Egyptian pounds and piastres with at most two decimal places. A negative commission or a commission with more than two decimal places is rejected. The account’s stored usual fee is only a starting value.
- Subcategory and notes stay optional.
- Duplicate detection is out of scope. Confirm does not warn about a similar existing record.
- The review screen is offered in the languages the product already supports, including right-to-left layout for Arabic.
- Only one person uses the book, on one device, as in the rest of the product. The screen does not move real money.
