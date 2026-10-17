# Research: Capture Draft and Review Screen

## Where the person opens review

**Decision**: Add a second action on the transaction list, next to the existing add button. The dashboard’s primary button and the list’s add button keep opening `/transactions/form`. Review opens `/capture/review` with no draft.

**Rationale**: The spec says the current income and expense entry stays, and review is an additional way to type those records. The transaction list is already where a person adds and reviews records. Leaving the dashboard button on the current form keeps everyday entry on the path people already use.

**Alternatives considered**: Replacing `/transactions/form` for income and expense was rejected because the spec keeps that entry, including transfers. Putting review on the dashboard primary button was rejected because that would hide the current form behind a less obvious path.

## What a hand-started draft contains

**Decision**: Kind is expense. Date is today. Amount, account, category, subcategory, and notes are empty. The uncertain set is empty. Commission is absent until the person selects a bank account or e-wallet, and then it starts as that account’s usual fee.

**Rationale**: The current transaction form already starts as an expense dated today (`TransactionFormPage`). Matching it avoids a second set of defaults. The spec says a hand-started draft has no uncertain marks.

**Alternatives considered**: Starting with no kind selected was rejected because confirm would need an extra “pick a kind” error the current form does not have. Starting as income was rejected because the usual fee, which this screen must show, applies to expenses.

## Where the person lands after confirm

**Decision**: On success, the review route pops, the same way `TransactionFormPage` pops after a save. On failure, the route stays open, the draft stays editable, and the failure message is shown.

**Rationale**: The spec says a successful confirm finishes that draft, and a failed confirm leaves the book unchanged and tells the person why. Popping returns them to the list they opened review from, where the new record is visible after the existing refresh.

**Alternatives considered**: Staying on a success screen was rejected because the current form does not do that, and the draft must not remain confirmable.

## Where the draft is kept

**Decision**: An in-memory data source registered in the `capture` GetIt scope. The scope is pushed when `/capture/review` opens and dropped when it closes. Confirm and discard clear the held draft. There is no Drift table and no backup change.

**Rationale**: The spec says the draft exists only while review is in use, and closing the app or leaving the screen drops it. Dropping the scope does that without a schema version. A later receipt or voice phase can pass a `CaptureDraft` as the route extra. A null extra means the hand-started draft above.

**Alternatives considered**: Holding the draft only in widget state was rejected because discard and confirm must be testable use cases that do not depend on a widget. Writing a Drift row was rejected because a killed app would then reopen an unsaved draft, which the spec forbids.

## Who validates the save

**Decision**: `ConfirmCaptureDraftUseCase` builds `SaveIncomeParams` or `SaveExpenseParams` and calls the existing use case. It does not copy the amount, date, account, category, or fee rules.

**Rationale**: The spec says confirm uses the same acceptance rules as recording by hand. Those rules already live in the transaction save path, including `commissionMinor` on `SaveExpenseParams` and `defaultCommissionMinor` on the account. A second copy would drift.

**Alternatives considered**: Re-validating inside capture was rejected because a rule fixed on the transaction form could be missed on review.

## How uncertain marks are shown

**Decision**: `CaptureDraft` carries a set of `CaptureField` values (`amount`, `date`, `account`, `category`, `subcategory`, `notes`, `commission`). The review page distinguishes fields in that set. It offers no control to add or remove a mark. Editing a value does not change the set. A hand-started draft uses an empty set.

**Rationale**: The spec says marks are display-only and empty fields are not auto-marked. Keeping the set on the entity lets a later phase, or a test, open the same screen with a mark already set.

**Alternatives considered**: A person-controlled toggle was rejected by the spec. Treating empty required fields as uncertain was rejected because confirm already reports them as missing.

## Fee when the account or kind changes

**Decision**: The page asks the confirm cubit to replace the draft’s commission when the paying account or the kind changes. Expense plus bank or e-wallet sets the commission to that account’s usual fee, including zero. Expense plus cash or `other`, or any income, clears the commission so the field is not offered. Switching kind also clears a category or subcategory that does not belong to the new kind.

**Rationale**: This matches the clarified spec and the current form’s usual-fee behavior. The stored usual fee on the account is not written.

**Alternatives considered**: Leaving the previous fee in place after an account change was rejected because the spec says the starting fee follows the newly selected account.
