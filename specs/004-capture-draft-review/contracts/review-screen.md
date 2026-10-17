# Contract: Review screen

Screen behavior for one capture draft. Amount, date, account, category, and fee outcomes after confirm are the existing transaction contract in [specs/001-phase0-mvp/contracts/transactions.md](../../../001-phase0-mvp/contracts/transactions.md). Draft fields are in [data-model.md](../data-model.md).

## Open

- The transaction list offers review in addition to the current add action. The current add action still opens the existing transaction form.
- The dashboard primary action still opens the existing transaction form when an account exists, and the account form when none exists.
- Opening review from the list starts a hand draft: expense, today’s date, empty amount, no account, no category, no notes, no uncertain marks, and no fee until a bank or e-wallet is selected.
- Opening review with a supplied draft shows that draft’s values and its uncertain marks. This phase’s list action does not supply a draft.

## Edit

- The person can set kind to income or expense, and can edit amount, date, account, category, subcategory, notes, and, when it applies, the fee.
- Transfer is not offered. The existing form remains the place to record a transfer.
- Income categories are not offered for an expense, and expense categories are not offered for income.
- Switching kind clears a category or subcategory that does not belong to the new kind.
- Deactivated accounts are not offered.
- Subcategory and notes may be empty.
- A field in the draft’s uncertain set is visibly distinguished. There is no control to mark or unmark a field. Changing the value does not add or remove the mark.
- A hand draft shows no uncertain marks, including while required fields are still empty.

## Fee

- An expense from a bank account or e-wallet shows a commission. It starts as that account’s usual fee, including zero when the usual fee is zero.
- The person can change or clear that commission before confirm. Clearing it or leaving it blank saves zero. The account’s stored usual fee stays as it was.
- Income, cash, and `other` do not show a commission.
- Switching the paying account replaces the shown fee with the new account’s usual fee when the new account is a bank or e-wallet, and removes the fee otherwise.
- Switching the draft to income removes the fee.
- A negative fee, or a fee with more than two decimal places, does not save. The draft stays on screen and the person is told why.

## Confirm

- Confirm saves exactly one income or one expense through the same rules as the existing form.
- With no fee, the account balance changes by the confirmed amount only.
- With a fee, the paying account decreases by the expense amount plus the fee. Spending increases by both. The chosen category increases by the expense amount only. The fee is shown separately as the transfer commission.
- Success closes the review screen and returns to the screen that opened it. That draft cannot be confirmed again.
- Failure leaves the book unchanged, keeps the draft editable, and tells the person which rule failed.
- No account yet: confirm fails and the person is told to add an account first. The dashboard path for that case remains the existing account form, not this screen.

## Discard and leave

- Discard drops the draft and writes nothing.
- Leaving the review screen without confirming drops the draft and writes nothing.
- Closing the app during review writes nothing. The next open starts from a hand draft, not the abandoned one.
- Opening review again after discard or confirm starts from a hand draft.

## Languages

- Every new label exists in English and Arabic, including the uncertain-field hint, confirm, discard, the income/expense choice, and the fee label already used for the transfer commission.
