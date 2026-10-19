# Feature Specification: Phase 0 MVP — Personal Money Tracking

**Feature Branch**: `001-phase0-mvp`

**Created**: 2026-10-06

**Status**: Draft

**Input**: User description: "This is the BRD for Personal Finance Manager (BRD v1.0, 6 October 2026, Draft / Baseline). Read it and collect the project details. Create Phase 0 (MVP) for now."

**Amended**: 2026-10-16 — Add a transfer commission on each move between the person’s accounts, and on each payment from a bank account or digital wallet.

**Amended**: 2026-10-17 — Store a usual transfer commission on each account, and use it as the starting fee on the next qualifying record.

**Amended**: 2026-10-20 — On a move between the person’s accounts, the transfer commission can be a fixed amount or a percentage of the moved amount.

**Amended**: 2026-10-20 — The usual fee stored on each account can be a fixed amount or a percentage, matching the choice on a transfer.

Phase 0 is the first usable version of a personal money-tracking product for one person. The person records where money sits and how it moves. The product does not connect to banks, does not move real money, and does not ask for bank secrets. Everything the person records stays on the device and works with no internet connection.

This specification covers only the MVP described in BRD section 20.1: accounts and opening balances, income, expense, and internal transfers, categories and subcategories, a basic dashboard, basic reports over a chosen date range, search and filters, and recording that stays on the device. A transfer commission is part of that same recording: it is the fee the person enters when money moves between their accounts, or when they pay from a bank account or a digital wallet. On a move between their accounts, that fee can be a fixed amount or a percentage of the amount being moved. On a payment, the saved fee stays an amount of money. Each account can also store a usual fee as either a fixed amount or a percentage, so the next qualifying record starts with that choice and the person does not have to type it again. Later phases are listed under Assumptions so they are not lost, and they are not part of this specification.

## Clarifications

### Session 2026-10-06

- Q: How precise are money amounts in Phase 0? → A: Egyptian pounds and piastres, at most 2 decimal places (for example 12.50). More than 2 decimal places is rejected, not rounded.
- Q: Which accounts does the home screen list when some are deactivated? → A: The home screen does not list accounts. Deactivated accounts stay in the account list and in past reports, are not offered for new transactions, and their current balance still counts in the home total.
- Q: Which days does “this week” include? → A: Saturday through Friday.
- Q: Can the account type change after creation? → A: Only while the account has no transactions. After that, the type is fixed.
- Q: Which destructive actions ask for confirmation? → A: Deleting a transaction, deleting an account with no transactions, and deactivating an account. Cancel leaves everything unchanged. Amount edits do not ask.
- Q: What does the home screen lead with, and where do categories and backup live? → A: The home figure is the current money in every account, not this month’s net. This month’s income and expenses stay on that card. Expense categories are listed largest share first. The home screen does not list accounts and does not show a separate net row. Categories and backup open from Settings, which is reached from the home bar. On search, the word field stays on the screen; account, type, category, and subcategory filters open together from a filter control beside that field.

### Session 2026-10-16

- Q: Where does a transfer commission apply, and who pays it? → A: On every move between the person’s own accounts, and on every payment from a bank account or a digital wallet. The person types the fee. It is extra, taken from the source of a move or from the paying account. The destination receives the full moved amount. A blank fee means zero and changes nothing. Cash and other accounts do not take a fee on a payment. Income does not take a fee. The product does not look up a bank or wallet tariff.

### Session 2026-10-17

- Q: What does a usual commission stored on an account do? → A: Each account can store a usual fee. Blank or zero means there is no usual fee. It is not looked up from a bank or wallet. Storing it does not change that account’s balance. On a new payment from a bank account or a digital wallet, the fee starts from that paying account’s usual fee. On a new move, the fee starts from the source account’s usual fee, not the destination’s, and not the sum of both. The person can change or clear it before saving. A saved record keeps the fee that was saved. Changing the account’s usual fee does not change records already saved. A payment from cash, or from an account that is neither a bank account nor a digital wallet, still cannot carry a fee, even when that account has a usual fee for moves. Income never uses the usual fee.

### Session 2026-10-20

- Q: How can the commission on a move be entered? → A: As either a fixed amount or a percentage of the moved amount. One percent of 1,000 EGP is a commission of 10 EGP. The person sees that 10 EGP before saving. The destination still receives 1,000 EGP and the source pays 1,010 EGP. A percentage on the move is not added on top of a fixed usual fee. The product does not look up a tariff. Changing the moved amount updates a percentage commission and does not change a fixed one. Moves already saved stay fixed amounts until the person edits them.
- Q: Can the usual fee on an account be a percentage? → A: Yes. Each account’s usual fee is either a fixed amount or a percentage, the same choice as on a transfer. A blank or zero usual fee means none. Storing it still does not change the balance. On a new move, the commission starts with that source account’s basis and value: a fixed usual fee starts a fixed commission, and a 1% usual fee starts a 1% commission of the moved amount. On a new bank or wallet payment, a fixed usual fee starts that money amount; a percentage usual fee starts the money amount that rate produces from the payment amount, and the saved payment keeps a money fee only. Changing the source or paying account before saving replaces the starting fee with the newly chosen account’s usual fee when a fee is still allowed. Accounts that already had only a money usual fee stay fixed amounts until the person edits them.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See where money sits (Priority: P1)

A person adds each account that holds money — a bank account, an electronic wallet, cash, or another account — and records how much was there when they started tracking it. They can also store the usual transfer commission for that account as either a fixed amount or a percentage. They can then see each account’s current balance. The home total is the sum of every account’s current balance. The usual fee is not itself money that has left the account.

**Why this priority**: Without accounts and a starting balance, later income, spending, and reports have nothing to attach to. This story alone already answers “how much money do I have, and where is it?” A percentage usual fee lets them set a rate once, such as 1%, for later moves and payments.

**Independent Test**: Add Bank ABC with a fixed usual fee of 3 EGP and a second account with a 1% usual fee. Confirm each balance equals its opening balance and that neither usual fee is spending.

**Acceptance Scenarios**:

1. **Given** the person has no accounts yet, **When** they add “Bank ABC” as a bank account with an opening balance of 25,000 EGP and a start date, **Then** that account shows a current balance of 25,000 EGP, and that 25,000 is not counted as income.
2. **Given** a bank account is being added, **When** the person enters a bank name and an account number, **Then** those values are kept only as labels that identify the account.
3. **Given** an electronic wallet is being added, **When** the person enters the linked phone number, **Then** that number is kept only as a label that identifies the wallet.
4. **Given** several accounts exist, **When** the person views their money on the home screen, **Then** the total equals the sum of every account’s current balance, including a deactivated account and an account marked as excluded from the total.
5. **Given** an account is excluded from the total, **When** the person views that account, **Then** its own current balance is still shown on the account. The home total still includes it.
6. **Given** an account already has history, **When** the person deactivates it and confirms, **Then** its past records stay unchanged, it remains in the account list, it cannot be used for new transactions, and its current balance still counts in the home total. **When** they cancel, **Then** the account stays active and nothing changes.
7. **Given** an account has no transactions, **When** the person removes it and confirms, **Then** it disappears. **When** they cancel, **Then** the account remains. **Given** an account has transactions, **When** the person tries to remove it permanently, **Then** the product offers deactivation instead and keeps the history.
8. **Given** an account has no transactions, **When** the person changes its type, **Then** the type changes and identifying labels that do not apply to the new type are cleared.
9. **Given** an account already has a transaction, **When** the person tries to change its type, **Then** the type stays unchanged and they are told that the type is fixed once transactions exist.
10. **Given** the person is adding Bank ABC, **When** they enter a fixed usual transfer commission of 3 EGP and an opening balance of 25,000 EGP, **Then** the account keeps a fixed usual fee of 3 EGP, the current balance is still 25,000 EGP, and that 3 EGP is not spending and is not income.
11. **Given** the person is adding an account, **When** they leave the usual fee blank or set it to 0 EGP or 0%, **Then** the account’s usual fee is zero and fixed.
12. **Given** an account’s usual fee is a fixed 3 EGP and a saved payment already used that 3 EGP, **When** the person changes the usual fee to 5 EGP, **Then** the saved payment still shows 3 EGP and the account balance does not change because of the new usual fee alone.
13. **Given** the person enters a negative usual fee, a negative usual rate, a usual fee with more than two decimal places, or a usual rate with more than two decimal places, **When** they try to save the account, **Then** the account is not saved with that fee and they are told why.
14. **Given** the person is adding Vodafone Cash, **When** they choose a percentage usual fee of 1% and an opening balance of 0 EGP, **Then** the account keeps a 1% usual fee, the current balance is still 0 EGP, and that rate is not spending and is not income.
15. **Given** an account’s usual fee is 1% and a saved move already used that 1%, **When** the person changes the usual fee to a fixed 5 EGP, **Then** the saved move still shows 1% and its commission, and the account balance does not change because of the new usual fee alone.
16. **Given** an account that already had only a money usual fee of 3 EGP before a percentage could be chosen, **When** the person opens it, **Then** it shows a fixed usual fee of 3 EGP and the balance has not changed because of the new choice alone.

---

### User Story 2 - Record income and spending (Priority: P1)

A person records money coming in and money going out against a chosen account, category, and date, with optional notes. Each record immediately changes that account’s balance. When the payment is from a bank account or a digital wallet, they can also record the transfer commission charged on that payment. If that account has a fixed usual fee, the payment starts with that money amount. If it has a percentage usual fee, the payment starts with the money amount that rate produces from the payment amount. The person can change or clear it. The saved payment keeps a money fee only. The purchase amount and the fee stay separate. They can correct or remove a record, and the balance follows the correction.

**Why this priority**: Recording income and spending is the daily job of the product. Together with Story 1 it is the smallest version that replaces a notebook.

**Independent Test**: Starting from an account with a known opening balance, add one income and one expense, then edit and delete one of them, and confirm the balance after every step.

**Acceptance Scenarios**:

1. **Given** an active account and an income category, **When** the person records income with an amount, that account, a category, a date on or after the account’s start date, and optional notes, **Then** the account’s balance increases by that amount and the income is available for that date’s reports.
2. **Given** an active account and an expense category, **When** the person records an expense the same way, **Then** the account’s balance decreases by that amount and the expense is available for that date’s reports.
3. **Given** a recorded income or expense, **When** the person changes the amount, account, category, subcategory, date, or notes, **Then** balances and reports match the corrected record.
4. **Given** a recorded income or expense, **When** the person deletes it and confirms, **Then** it no longer affects balances or reports. **When** they cancel, **Then** the record and the balance stay as they were.
5. **Given** the person enters an amount of zero or less, **When** they try to save, **Then** the record is not saved and they are told the amount must be greater than zero.
6. **Given** the person enters 12.50, **When** they save an expense, **Then** the account balance changes by exactly 12.50 EGP.
7. **Given** the person enters an amount with more than two decimal places, such as 12.505, **When** they try to save, **Then** the record is not saved and they are told that only two decimal places are allowed.
8. **Given** a transaction dated before the account’s opening date, **When** they try to save, **Then** the record is not saved and they are told the date cannot be earlier than the opening date.
9. **Given** an account’s balance is 100 EGP, **When** the person records an expense of 150 EGP, **Then** the balance becomes −50 EGP and is shown as negative. The product does not block the record.
10. **Given** no account exists yet, **When** the person opens the product, **Then** they are asked to add the first account and cannot record a transaction until one exists.
11. **Given** a bank account with 1,000 EGP, **When** the person records a payment of 200 EGP from that account with a transfer commission of 3 EGP, **Then** the account decreases by 203 EGP, spending increases by 203 EGP, the 200 EGP stays in the category they chose, and the 3 EGP is shown separately under رسوم تحويل.
12. **Given** a digital wallet with 500 EGP, **When** the person records a payment of 100 EGP with a commission of 1.50 EGP, **Then** the wallet decreases by 101.50 EGP and spending increases by 101.50 EGP.
13. **Given** a payment from a bank account or digital wallet with a commission left blank or set to 0 EGP, **When** they save, **Then** the account decreases by the payment amount only.
14. **Given** the person is paying from cash or from an account that is neither a bank account nor a digital wallet, **When** they enter the payment, **Then** no transfer commission is offered and saving does not add a fee.
15. **Given** a saved bank or wallet payment that still has a commission greater than zero, **When** the person changes the paying account to cash or to an account that is neither a bank nor a digital wallet and tries to save, **Then** the change is not saved and they are told the fee applies only to a bank account or a digital wallet.
16. **Given** Bank ABC has a fixed usual fee of 3 EGP and a balance of 1,000 EGP, **When** the person records a payment of 200 EGP and leaves the starting fee of 3 EGP unchanged, **Then** the account decreases by 203 EGP, spending increases by 203 EGP, the 200 EGP stays in the category they chose, and the 3 EGP is shown separately under رسوم تحويل.
17. **Given** the same bank and the same starting fee of 3 EGP, **When** the person clears the fee or sets it to 0 EGP and saves the payment, **Then** the account decreases by the payment amount only, and the account’s usual fee stays a fixed 3 EGP.
18. **Given** the same bank and the same starting fee of 3 EGP, **When** the person changes that fee to 1.50 EGP before saving, **Then** the saved payment uses 1.50 EGP, and the account’s usual fee stays a fixed 3 EGP.
19. **Given** a new payment starts on a bank account whose usual fee is a fixed 3 EGP, **When** the person switches the paying account to a digital wallet whose usual fee is a fixed 1.50 EGP before saving, **Then** the fee shown becomes 1.50 EGP.
20. **Given** a cash account has a usual fee of 5 EGP or 1%, **When** the person records a payment from that cash account, **Then** no transfer commission is offered and saving does not add a fee.
21. **Given** Bank ABC has a 1% usual fee and a balance of 1,000 EGP, **When** the person records a payment of 200 EGP and leaves the starting fee unchanged, **Then** the fee shown is 2.00 EGP, the account decreases by 202 EGP, spending increases by 202 EGP, and the saved payment shows a money fee of 2.00 EGP, not a percentage.
22. **Given** a new payment of 200 EGP starts on a bank whose usual fee is 1%, **When** the person switches the paying account to a wallet whose usual fee is a fixed 3 EGP before saving, **Then** the fee shown becomes 3.00 EGP.

---

### User Story 3 - Move money between own accounts (Priority: P2)

A person records an internal move from one of their accounts to another, and can record a transfer commission on that same move. The commission can be a fixed amount or a percentage of the amount being moved. It starts from the source account’s usual fee: a fixed usual fee starts a fixed commission, and a percentage usual fee starts that percentage of the moved amount. The destination’s usual fee is not added. The destination receives the moved amount. The source loses the moved amount plus any commission. With no commission, overall money and spending stay the same. With a commission, overall money falls by the fee only, and spending rises by the fee only.

**Why this priority**: People split money across a bank, a wallet, and cash. If a move were treated as spending, totals and reports would be wrong. The fee is the only part of the move that really left their money. A percentage lets them record a rate, such as 1%, without calculating the money themselves.

**Independent Test**: With two included accounts, record a 1,000 EGP move with no commission and confirm the total is unchanged, then record a 1,000 EGP move at 1% and confirm the commission is 10 EGP and the total falls by 10 EGP.

**Acceptance Scenarios**:

1. **Given** Bank ABC and Vodafone Cash are both active and included in the total, **When** the person records a move of 1,000 EGP from Bank ABC to Vodafone Cash on a valid date with no commission, **Then** Bank ABC decreases by 1,000, Vodafone Cash increases by 1,000, total money is unchanged, and total expenses do not increase.
2. **Given** a move is recorded with no commission, **When** the person views income and expense reports, **Then** the move appears as a transfer, not as income and not as an expense.
3. **Given** the person edits the amount or either account, **When** they save, **Then** both balances and the total match the edited move.
4. **Given** the person deletes the move and confirms, **When** deletion completes, **Then** both balances return to what they were before that move. **When** they cancel, **Then** the move and both balances stay as they were.
5. **Given** the source and destination are the same account, or either account is deactivated, or the amount is not greater than zero, or the date is before either account’s opening date, **When** they try to save, **Then** the move is rejected with a clear reason.
6. **Given** a move between any two of the person’s accounts with no commission, **When** it is recorded, **Then** the source decreases, the destination increases, the home total is unchanged, and total expenses do not increase. The moved amount is not an expense.
7. **Given** Bank ABC has 25,000 EGP and Vodafone Cash has 0 EGP, **When** the person records a move of 1,000 EGP with a transfer commission of 5 EGP, **Then** Bank ABC decreases by 1,005 EGP, Vodafone Cash increases by 1,000 EGP, total money decreases by 5 EGP, and spending increases by 5 EGP under رسوم تحويل.
8. **Given** a saved move with a commission, **When** the person views it, **Then** the moved amount and the commission are separate figures.
9. **Given** the commission is negative, or the commission has more than two decimal places, **When** they try to save the move, **Then** the move is not saved and they are told why.
10. **Given** a saved move with a 5 EGP commission, **When** the person changes the commission to 0 EGP, **Then** the source balance rises by 5 EGP, total money rises by 5 EGP, and spending no longer includes that 5 EGP.
11. **Given** Bank ABC has a fixed usual fee of 5 EGP and Vodafone Cash has a fixed usual fee of 2 EGP, **When** the person starts a move from Bank ABC to Vodafone Cash and leaves the starting fee unchanged, **Then** the fee on that move is a fixed 5 EGP, not 2 EGP and not 7 EGP.
12. **Given** a new move starts from an account whose usual fee is a fixed 5 EGP and the commission is still a fixed amount, **When** the person changes the source to an account whose usual fee is zero before saving, **Then** the fee shown becomes zero.
13. **Given** a saved move used a 5 EGP fee, **When** the person later changes the source account’s usual fee to 8 EGP or to 1% and does not edit that move, **Then** the saved move still shows 5 EGP.
14. **Given** Bank ABC and Vodafone Cash are both active, **When** the person records a move of 1,000 EGP and chooses a commission of 1% of that amount, **Then** the commission shown before saving is 10.00 EGP. **When** they save, **Then** Bank ABC decreases by 1,010 EGP, Vodafone Cash increases by 1,000 EGP, total money decreases by 10 EGP, and spending increases by 10 EGP under رسوم تحويل.
15. **Given** a move is using a commission of 1%, **When** the person changes the moved amount from 1,000 EGP to 2,000 EGP before saving, **Then** the rate stays 1% and the commission becomes 20.00 EGP.
16. **Given** a fixed commission of 5 EGP on a move of 1,000 EGP, **When** the person changes the moved amount to 2,000 EGP and saves, **Then** the commission stays 5.00 EGP.
17. **Given** a new move shows a fixed usual fee of 5 EGP, **When** the person switches to a percentage and enters 1% of a 1,000 EGP move, **Then** the commission is 10.00 EGP and the 5 EGP usual fee is not added.
18. **Given** a move is using a percentage that the person set by hand, **When** the person changes the source account before saving, **Then** the percentage stays and is not replaced by the new source’s usual fee.
19. **Given** a move is using a percentage that shows 10.00 EGP, **When** the person switches back to a fixed amount and the current source’s usual fee is a fixed 5 EGP, **Then** the commission becomes 5 EGP and the percentage is no longer applied. **Given** instead the source’s usual fee is 1% and the shown fee is 10.00 EGP, **When** they switch to a fixed amount, **Then** the commission becomes a fixed 10.00 EGP.
20. **Given** the percentage is left blank or set to 0%, **When** they save, **Then** the commission is zero and no fee is shown on the saved move.
21. **Given** the percentage is negative, or has more than two decimal places, **When** they try to save, **Then** the move is not saved and they are told why.
22. **Given** the person enters 150% of a 1,000 EGP move, **When** they save, **Then** the commission is 1,500.00 EGP and the move is saved.
23. **Given** a saved move of 1,000 EGP at 1%, **When** the person opens it, changes the moved amount to 500 EGP, and saves, **Then** the rate stays 1%, the commission becomes 5.00 EGP, and both balances follow 500 EGP moved and 5 EGP charged.
24. **Given** a move saved before a percentage could be chosen, with a commission of 5 EGP, **When** the person opens it, **Then** it shows a fixed commission of 5.00 EGP and neither balance has changed because of the new choice alone.
25. **Given** Bank ABC has a 1% usual fee and Vodafone Cash has a fixed usual fee of 2 EGP, **When** the person starts a move of 1,000 EGP from Bank ABC and leaves the starting fee unchanged, **Then** the commission is a 1% rate showing 10.00 EGP, not 2 EGP and not 12 EGP.
26. **Given** a new move starts from an account whose usual fee is 1%, **When** the person changes the source to an account whose usual fee is a fixed 5 EGP before saving, **Then** the commission becomes a fixed 5 EGP.
27. **Given** a new move starts from an account whose usual fee is a fixed 5 EGP, **When** the person changes the source to an account whose usual fee is 1% before saving, **Then** the commission becomes 1% of the current moved amount.

---

### User Story 4 - Organize transactions by category (Priority: P2)

A person classifies income and expenses with categories and optional subcategories, starting from a ready-made set and adding their own. Disabling a category that was already used does not erase history.

**Why this priority**: Categories are how the person answers “where did the money go?”. Story 2 can be used with the ready-made set; this story adds control over that set.

**Independent Test**: Record an expense under مواصلات / وقود, add a custom category, disable a used category, and confirm old records still show the old name while new records cannot use the disabled category.

**Acceptance Scenarios**:

1. **Given** the person is recording an expense for the first time, **When** they open categories, **Then** a ready-made expense set is available, including مواصلات with subcategory وقود, and income categories are not offered for that expense.
2. **Given** the person is recording income, **When** they open categories, **Then** only income categories are offered.
3. **Given** the ready-made set, **When** the person adds, renames, or disables a category or subcategory, **Then** the list reflects that change for future records.
4. **Given** a category or subcategory already used on a past record, **When** the person disables it, **Then** past records still show that classification, and it cannot be chosen for a new record.
5. **Given** a custom category or subcategory that has never been used, **When** the person removes it, **Then** it disappears from the list.
6. **Given** a used category, **When** the person tries to erase it, **Then** the product disables it instead and keeps historical records readable.

---

### User Story 5 - Read the current month at a glance (Priority: P2)

A person opens the home screen and sees the money currently in every account, this calendar month’s income and expenses, how this month’s expenses split by category, and the latest transactions. The month’s net is not a separate row and is not the leading figure. Accounts are not listed here. Categories and backup are opened from Settings. From income, expenses, or a category they can open the matching transactions.

**Why this priority**: The home screen is the daily answer to “how much do I have, and how is this month going?”. It depends on Stories 1–4 and is the first screen that brings them together.

**Independent Test**: With known transactions inside and outside the current month, and with more than one account, open the home screen and confirm the leading figure is the sum of every account’s current balance, income and expenses cover only the current month, and expense categories are ordered from the largest share to the smallest.

**Acceptance Scenarios**:

1. **Given** transactions exist in the current calendar month and in earlier months, **When** the person opens the home screen, **Then** income and expenses include only the current calendar month, the moved amount of a transfer is not part of income or expenses, and a transfer commission dated in that month is part of expenses.
2. **Given** the person has several accounts, including one deactivated and one marked as excluded from the total, **When** they view the home screen, **Then** the leading figure is the sum of every account’s current balance, and no account list is shown.
3. **Given** the current month has expenses in more than one category, **When** the person views the expense split, **Then** each category shows its amount and its share of the month’s expenses, ordered from the largest share to the smallest.
4. **Given** the home screen is open, **When** the person looks at recent activity, **Then** they see the ten most recent transactions across all accounts, newest first.
5. **Given** income, expenses, or a category on the home screen, **When** the person opens it, **Then** they see the underlying transactions for that figure.
6. **Given** the current month has no transactions, **When** the person opens the home screen, **Then** income and expenses are zero, while the leading total still reflects opening balances and older transactions.
7. **Given** the home screen is open, **When** the person opens Settings, **Then** they can open categories and backup, and those two entries are not on the home screen.

---

### User Story 6 - Review any period (Priority: P2)

A person chooses a day, a week, a calendar month, or any start and end date, and reads income, spending, net result, category breakdowns, each account’s activity, and the list of transactions for that period.

**Why this priority**: Flexible periods are a stated reason the product exists. The dashboard covers “this month”; this story covers every other question about a period.

**Independent Test**: Record known income, expenses, and a transfer in September, then run the 1–30 September report and match every total by hand.

**Acceptance Scenarios**:

1. **Given** transactions exist from 1 to 30 September, **When** the person requests that custom range, **Then** they see total income, total expenses, and net result for those dates only, with the moved amount of transfers excluded from all three, and any transfer commission in those dates included in expenses and in the net result.
2. **Given** a chosen period, **When** they view expenses by category, **Then** each category and subcategory shows the amount and its percentage of period expenses.
3. **Given** a chosen period, **When** they view income by category, **Then** each income category shows the amount and its percentage of period income.
4. **Given** a chosen period and an account, **When** they view the account report, **Then** they see the balance at the start of the period, income, expenses, transfers in, transfers out, and the balance at the end of the period.
5. **Given** the account’s own opening date falls inside the period, **When** they view the account report, **Then** the period’s starting balance is that opening balance, and the opening balance is still not treated as income.
6. **Given** a chosen period, **When** they view the transaction list, **Then** they see the income, expenses, and transfers in that period.
7. **Given** a period with no transactions, **When** they open any report, **Then** totals are zero and lists are empty, without an error.
8. **Given** period expenses are zero, **When** percentages are shown, **Then** every expense percentage is 0%. The same rule applies to income percentages when period income is zero.
9. **Given** the person chooses “today”, “this week” (Saturday through Friday), or “this calendar month”, **When** the report opens, **Then** the range matches that preset and can still be replaced by a custom range.

---

### User Story 7 - Find a past transaction (Priority: P3)

A person searches by words in the description or notes, and narrows the list by date, account, transaction type, and category or subcategory. Filters combine, so each extra filter removes non-matches.

**Why this priority**: Finding a past record matters once history grows. Recording and reporting already deliver value before search is polished.

**Independent Test**: Create a small set of transactions that differ by notes, account, type, and category, then apply one filter at a time and two filters together.

**Acceptance Scenarios**:

1. **Given** transactions with descriptions and notes, **When** the person searches for a word that appears in a description, note, account name, category name, or subcategory name, **Then** only transactions containing that word in one of those fields are shown.
2. **Given** a list of transactions, **When** the person opens the filter control beside the search field, **Then** they can narrow by account, type (income, expense, or transfer), category, or subcategory, and the list shows only matches. The word search stays on the screen. A date range already chosen, such as the current month opened from home, stays applied.
3. **Given** several filters at once, **When** the list refreshes, **Then** a transaction must match every selected filter to appear.
4. **Given** filters that match nothing, **When** the list refreshes, **Then** the person sees an empty result, not an error.
5. **Given** the person clears search and filters, **When** the list refreshes, **Then** the full set for the current context is shown again.

---

### Edge Cases

- Opening balance is never income, including when a report’s period starts on the account’s opening date.
- Correcting an opening balance or opening date recalculates every later balance and report. The new opening date cannot be moved to after an existing transaction; the person is told which transactions block the change.
- Account type can change only before the first transaction. That change clears identifying labels that do not apply to the new type. After any transaction, the type stays as it is.
- A deactivated account remains in the account list and in historical reports for periods when it had activity. It is not a choice for new income, expenses, or transfers. Its current balance still counts in the home total. The home screen does not list accounts.
- A disabled category or subcategory remains visible on old transactions and disappears from choices for new ones.
- An expense or transfer larger than the current balance is allowed. The balance is shown as negative and stays mathematically consistent.
- A transfer with no commission does not change the home total, because every account’s current balance is included. The moved amount does not count as income or as an expense. A commission on that transfer decreases the home total by the fee only and counts as an expense.
- A commission may be larger than the moved or paid amount. The source or paying account decreases by principal plus commission. A negative balance remains allowed.
- A commission left blank is zero. Transactions saved before a commission existed keep a commission of zero until the person edits a qualifying transaction and enters a fee.
- A usual fee stored on an account is not spending until a saved record uses it. Changing the usual fee does not rewrite saved records. Accounts that already exist, and new accounts with the usual fee left blank, have a fixed usual fee of zero.
- On a new move, the commission starts from the source account’s usual fee only: a fixed usual fee starts a fixed commission, and a percentage usual fee starts that percentage of the moved amount. Switching the source before saving replaces the starting commission with the new source’s usual fee and basis while the commission is still following that start. If the person has already changed the move’s commission by hand (basis or rate) so it is no longer only that auto-filled start, changing the source leaves that hand-set value unchanged. Opening a saved move shows the fee that was saved, not the account’s current usual fee.
- A percentage that does not land on a whole 0.01 EGP is rounded half up to the nearest 0.01 EGP. One percent of 333.33 EGP is saved as 3.33 EGP. Half a percent of 1.00 EGP is saved as 0.01 EGP. One percent of 0.49 EGP is saved as 0.00 EGP and is not shown as a fee. The rate is still kept, so a later larger amount can produce a fee.
- A percentage applies only to the moved amount or, when starting a payment from a percentage usual fee, to the payment amount. It is not applied again to the fee, and it is not added on top of a fixed usual fee. Switching a move back to a fixed amount uses the current source account’s fixed usual fee when that usual fee is fixed. When the usual fee is a percentage, the fixed amount becomes the money amount currently shown for that percentage.
- On a new bank or wallet payment, the paying account’s usual fee is the starting fee. A fixed usual fee starts that money amount. A percentage usual fee starts the money amount that rate produces from the payment amount, and the saved payment still stores a money fee only. Switching to another bank or wallet before saving replaces it with that account’s usual fee. A cash or other payment still offers no fee. If the person then switches that payment onto a bank or wallet, the fee starts as that bank or wallet’s usual fee.
- The destination of a move is never shorted by the commission. The fee is always extra and is always taken from the source.
- Income does not take a transfer commission. A payment from cash, or from an account that is neither a bank account nor a digital wallet, cannot carry one.
- The recorded fee is the money amount the person entered, or the money amount produced by the percentage they entered. It is not claimed to match a bank’s or wallet’s live tariff.
- The same display name may be used for two accounts. The person can still tell them apart by type and identifying labels.
- Amounts are in Egyptian pounds with at most 2 decimal places. A third decimal place is rejected and is not rounded. Phase 0 does not convert between currencies, so every total is a plain sum of those EGP amounts. Opening balances follow the same 2-decimal rule.
- Dates may be in the future. They affect balances immediately and appear only in reports whose range includes that date.
- Searching or filtering does not change the person’s records.
- Canceling a confirmation to delete a transaction, delete an account with no transactions, or deactivate an account leaves the records, balances, and reports unchanged. Changing an amount does not ask for that confirmation.
- The recorded balance is the balance inside the product. It is not claimed to be the live balance at the bank or wallet.
- Closing and reopening the product shows the same accounts, transactions, categories, and balances the person last saved.
- With no internet connection, every Phase 0 story still works.

## Requirements *(mandatory)*

### Functional Requirements

**Accounts and opening balances**

- **FR-001**: The person MUST be able to create an account of type Bank Account, E-Wallet, Cash, or Other, with a name, an opening balance, an opening date, and an optional usual transfer commission as defined in FR-061.
- **FR-002**: A bank account MUST allow an optional bank name and an optional account number, kept only as labels that identify the account.
- **FR-003**: An e-wallet account MUST allow an optional linked phone number, kept only as a label that identifies the wallet.
- **FR-004**: Every amount in Phase 0, including opening balances, income, expenses, transfers, balances, and totals, MUST be in Egyptian pounds (EGP) with at most 2 decimal places. The person is not offered another currency. An amount with more than 2 decimal places MUST be rejected and MUST NOT be rounded. A commission calculated from a percentage (on a transfer in FR-062, or when a payment starts from a percentage usual fee in FR-061) is the exception: the result is rounded half up to the nearest 0.01 EGP.
- **FR-005**: The person MUST be able to edit an account’s name, type-specific labels, opening balance, opening date, usual transfer commission, and whether it is included in total money. The person MUST be able to change the account type only while that account has no transactions. Changing the type MUST clear identifying labels that do not apply to the new type. Once the account has any transaction, the type MUST stay unchanged. Changing the usual fee MUST NOT change the fee already saved on a record.
- **FR-006**: A new account MUST be included in total money by default. The person MUST be able to exclude or include it later.
- **FR-007**: The person MUST be able to deactivate an account. A deactivated account MUST NOT accept new income, expenses, or transfers. It MUST remain in the account list, where the person can still see it, reactivate it, or change whether it is included in total money. Its existing history MUST remain available in past views and reports. Its current balance MUST still count in the home total.
- **FR-008**: An account with no transactions MUST be removable. An account with transactions MUST NOT be permanently erased; deactivation is the way to retire it.
- **FR-009**: The current balance of an account MUST equal its opening balance, plus income, minus expenses, plus transfers in, minus transfers out.
- **FR-010**: The home total MUST equal the sum of the current balance of every account, whether or not the account is active and whether or not it is marked as included. The include flag remains on the account and MUST NOT remove that account from this figure.
- **FR-011**: The opening balance MUST NOT be counted as income in any total, dashboard, or report.
- **FR-012**: Changing an opening balance or opening date MUST recalculate affected balances and reports. The product MUST reject an opening date that falls after an existing transaction on that account.

**Income, expense, and transfer**

- **FR-013**: The person MUST be able to record income with a required amount, account, income category, and date, plus an optional subcategory and optional description or notes.
- **FR-014**: The person MUST be able to record an expense with a required amount, account, expense category, and date, plus an optional subcategory and optional description or notes. When the paying account is a bank account or a digital wallet, they MUST also be able to enter a transfer commission as defined in FR-055, starting from that account’s usual fee in FR-061. Cash and any other account type MUST NOT offer that commission.
- **FR-015**: Income MUST increase the chosen account’s balance. An expense MUST decrease it.
- **FR-016**: The person MUST be able to record a transfer with a required amount, source account, destination account, and date, plus optional notes and an optional transfer commission as defined in FR-055 and FR-062. The commission applies whichever account types are involved. On a new transfer the fee MUST start from the source account’s usual fee in FR-061: a fixed usual fee starts a fixed commission of that amount, and a percentage usual fee starts that percentage of the moved amount.
- **FR-017**: A transfer’s moved amount MUST decrease the source and increase the destination by the same amount. That moved amount MUST NOT be included in income totals or expense totals. Any commission on the transfer follows FR-056.
- **FR-018**: A transfer with no commission MUST leave the home total unchanged. A transfer with a commission MUST decrease the home total by that commission only.
- **FR-019**: The person MUST be able to edit and delete income, expenses, and transfers. After each confirmed change, balances, the dashboard, and reports MUST match the remaining records.
- **FR-020**: Income, expense, and transfer amounts MUST be greater than zero. A transfer commission MAY be zero. Opening balances MAY be positive, zero, or negative. A commission larger than the principal MUST be allowed.
- **FR-021**: A transfer MUST be rejected when the source and destination are the same account, or when either account is missing or deactivated.
- **FR-022**: A transaction date MUST be on or after the opening date of every account it touches.
- **FR-023**: The person MUST choose the category for income and for the payment amount of an expense. Phase 0 MUST NOT assign or rewrite those categories on its own. A transfer commission is the exception: it is classified under the ready-made category in FR-055, and the person does not pick a different category for it.
- **FR-024**: Before any account exists, the product MUST ask the person to add one and MUST NOT offer a way to save a transaction.

**Categories**

- **FR-025**: Income categories and expense categories MUST be separate. A category MUST NOT be usable for the other transaction type.
- **FR-026**: A category MAY have one or more subcategories. A subcategory belongs to exactly one category.
- **FR-027**: On first use, the product MUST offer a ready-made set the person can edit or disable. Labels are Arabic:
  - Income: راتب (Salary), عمل حر (Freelance), نشاط تجاري (Business), هدايا (Gifts), أخرى (Other).
  - Expense: طعام (Food), مواصلات (Transportation) with subcategory وقود (Fuel), تسوق (Shopping), فواتير (Bills), صحة (Health), تعليم (Education), ترفيه (Entertainment), أسرة (Family), رسوم تحويل (Transfer commission), أخرى (Other).
- **FR-028**: Until the person renames them, ready-made category and subcategory labels MUST appear as the Arabic words in FR-027.
- **FR-029**: The person MUST be able to add and rename categories and subcategories, for both the ready-made set and their own.
- **FR-030**: A category or subcategory that has been used MUST be disabled rather than erased. Disabled items MUST remain visible on historical transactions and MUST NOT be selectable for new transactions.
- **FR-031**: A category or subcategory that has never been used MAY be removed.

**Dashboard, reports, search**

- **FR-032**: The home screen MUST show, for the current calendar month, total income and total expenses. The moved amount of a transfer MUST be excluded from both. A transfer commission dated in that month MUST be included in expenses. The home screen MUST NOT show the month’s net result as its own row or as the leading figure.
- **FR-033**: The leading home figure MUST be the current money in every account, as defined in FR-010. The home screen MUST NOT list accounts.
- **FR-034**: The home screen MUST show the current month’s expenses by category, with amount and percentage share, ordered from the largest share to the smallest.
- **FR-035**: The home screen MUST show the ten most recent transactions, newest first.
- **FR-036**: From home income, home expenses, or a home category, the person MUST be able to open the transactions that make up that figure.
- **FR-036a**: Categories and backup MUST be opened from Settings. Settings MUST be reachable from the home screen. Those two entries MUST NOT appear as rows on the home screen.
- **FR-037**: The person MUST be able to run reports for a single day, the current week (Saturday through Friday), a calendar month, or a custom start and end date. The start and end dates are included.
- **FR-038**: The financial summary for a period MUST show total income, total expenses, and net result, excluding the moved amount of transfers. A transfer commission in the period MUST be included in expenses and in the net result.
- **FR-039**: Expenses by category MUST show, for the period, the amount and the percentage of period expenses for each category and subcategory that has activity.
- **FR-040**: Income by category MUST show, for the period, the amount and the percentage of period income for each income category that has activity.
- **FR-041**: When the relevant period total is zero, percentages MUST be shown as 0%.
- **FR-042**: The account report for a period MUST show starting balance, income, expenses, transfers in, transfers out, and ending balance. Starting balance is the account’s balance just before the period begins. If the account opens during the period, starting balance is its opening balance. Transfers in and transfers out MUST be moved amounts only. A commission MUST appear in the expenses of the source or paying account, not inside transfers in or transfers out.
- **FR-043**: The transaction report MUST list income, expenses, and transfers in the period. When a search or filters are active, the list MUST show only the transactions that match.
- **FR-044**: The leading home figure is the current sum of every account’s balance, not a figure limited to the current month. A report’s income, expenses, and net result stay limited to the chosen period.
- **FR-045**: A period or filter with no matching transactions MUST show zero totals and an empty list, without treating that as a failure.
- **FR-046**: The person MUST be able to search transactions by words in the description, notes, account name, category name, or subcategory name.
- **FR-047**: The person MUST be able to filter transactions by account, transaction type, and category or subcategory, and MUST be able to combine those filters with the word search and with a date range already in effect. Combined filters keep only transactions that match all of them. The word search stays on the screen. Account, type, category, and subcategory filters MUST open together from a filter control beside the search field.

**Privacy, trust, and availability**

- **FR-048**: The person MUST be able to complete every Phase 0 story with no internet connection.
- **FR-049**: Records MUST still be there after the product is closed and opened again.
- **FR-050**: The product MUST NOT ask for or keep a bank password, PIN, CVV, or bank sign-in details.
- **FR-051**: The product MUST NOT send, receive, or carry out a real payment, purchase, deposit, withdrawal, or bank transfer.
- **FR-052**: Phase 0 MUST serve one person on one device. It MUST NOT require sign-in.
- **FR-053**: Every screen the person uses in Phase 0 MUST be Arabic and laid out right to left.
- **FR-054**: The product MUST ask the person to confirm before deleting a transaction, deleting an account that has no transactions, or deactivating an account. If the person cancels, records, balances, and reports MUST stay unchanged. Editing an amount, category, date, notes, commission, or other account details MUST NOT require this confirmation.

**Transfer commission**

- **FR-055**: On an expense paid from a bank account or a digital wallet, a transfer commission is an optional amount the person types. On a transfer, it is either a fixed amount or a percentage of the moved amount, as defined in FR-062. In both cases the money amount MUST be zero or greater, in Egyptian pounds, with at most 2 decimal places. A blank commission means zero. A negative amount the person types, or a typed amount with more than 2 decimal places, MUST be rejected and MUST NOT be rounded. The commission MUST be classified as an expense under the ready-made category رسوم تحويل (Transfer commission). The person MUST be able to see the principal and the commission as separate figures. The rate itself MUST NOT be counted as a second charge.
- **FR-056**: On a transfer, the destination MUST increase by the moved amount only. The source MUST decrease by the moved amount plus the commission. Total money and expense totals MUST change by the commission only.
- **FR-057**: On an expense from a bank account or a digital wallet, the paying account MUST decrease by the payment amount plus the commission. Spending MUST increase by the payment amount plus the commission. The payment amount MUST stay in the category the person chose.
- **FR-058**: Income MUST NOT accept a transfer commission. An expense from cash, or from an account that is neither a bank account nor a digital wallet, MUST NOT accept one. Changing such a payment onto an account that cannot take a commission, while the commission is still greater than zero, MUST be rejected with a clear reason and MUST NOT drop the fee silently.
- **FR-059**: Editing a commission MUST update every affected balance and report. Deleting a transaction that includes a commission MUST remove both the principal effect and the commission, and MUST use the same confirmation as any other delete.
- **FR-060**: A transaction that has no commission, including every transaction saved before this amendment, MUST keep a commission of zero and MUST keep its existing effect on balances and reports until the person edits it.
- **FR-061**: Each account MUST be able to store a usual transfer commission as either a fixed amount or a percentage, using only one basis at a time. A fixed usual fee MUST be zero or more Egyptian pounds, with at most 2 decimal places. A percentage usual fee MUST be zero or more, with at most 2 decimal places, and MAY be greater than 100%. A blank usual fee or blank usual rate means zero on a fixed basis. A negative usual fee, a negative usual rate, or more than 2 decimal places MUST be rejected and MUST NOT be rounded. The usual fee MUST NOT by itself change the account balance, total money, income, or expenses. It MUST NOT be looked up from a bank or wallet. Accounts that already exist, and accounts saved with the usual fee left blank, MUST keep a fixed usual fee of zero until the person sets one. Accounts that already stored only a money usual fee MUST be treated as a fixed usual fee equal to that money. On a new payment from a bank account or a digital wallet, the fee MUST start from that paying account’s usual fee: a fixed usual fee starts that money amount, and a percentage usual fee starts the money amount that rate produces from the payment amount, rounded half up to the nearest 0.01 EGP. The saved payment MUST keep a money fee only. On a new transfer, the fee MUST start from the source account’s usual fee only: a fixed usual fee starts a fixed commission of that amount, and a percentage usual fee starts that percentage of the moved amount. Changing the paying account before saving MUST replace that starting fee with the newly chosen account’s usual fee when a fee is allowed on that payment. Changing the source of a transfer before saving MUST replace the starting commission with the new source’s usual fee and basis while the commission is still following that auto-filled start. If the person has already changed the transfer commission by hand (basis or rate), changing the source MUST leave that hand-set value unchanged. The person MUST be able to change or clear the starting fee before saving, and the saved record MUST keep the fee they left, not silently replace it later with the account’s usual fee. Opening a saved record MUST show the fee that was saved. A payment from cash, or from an account that is neither a bank account nor a digital wallet, MUST still offer no fee. Income MUST NOT use the usual fee.
- **FR-062**: On a transfer, the person MUST be able to set the commission as either a fixed amount or a percentage of the moved amount, and MUST use only one of those at a time. A percentage commission MUST equal the moved amount multiplied by the rate, rounded half up to the nearest 0.01 EGP. The person MUST see that money amount before saving. A rate of 1% on 1,000.00 EGP MUST produce a commission of 10.00 EGP. Changing the moved amount while a percentage is selected MUST keep the rate and update the commission. Changing the moved amount while a fixed amount is selected MUST leave that fixed amount unchanged. A blank percentage means zero. A negative percentage, or a percentage with more than 2 decimal places, MUST be rejected and MUST NOT be rounded. A percentage greater than 100% MUST be allowed. Switching from a fixed amount to a percentage MUST drop the fixed amount until a rate is entered, unless the start came from a percentage usual fee. Switching from a percentage back to a fixed amount MUST set the commission to the current source account’s fixed usual fee when that usual fee is fixed, and MUST set it to the money amount currently shown for that percentage when the usual fee is a percentage. Changing the source MUST replace the starting commission with the new source’s usual fee and basis while the commission is still following that auto-filled start, and MUST leave a hand-set commission unchanged, matching FR-061. A saved transfer MUST keep its basis. Reopening it MUST show the same fixed amount, or the same percentage and the commission that rate produces from the moved amount. Transfers saved before this choice existed MUST be treated as a fixed commission equal to the money already saved, and their balances MUST NOT change until the person edits them. A result that rounds to 0.00 EGP MUST NOT be shown as a fee, and the saved percentage MUST still be kept. A payment commission on a bank or wallet expense MUST remain a money amount when saved, even when it started from a percentage usual fee. The percentage MUST NOT be looked up from a bank or wallet. “Half up” means a result that lands exactly halfway rounds away from zero.

### Key Entities *(include if feature involves data)*

- **Account**: A place where the person’s money sits, such as a bank account, an electronic wallet, cash, or another place. Attributes include name, type (Bank Account, E-Wallet, Cash, or Other), optional identifying labels, currency (EGP in Phase 0), opening balance, opening date, an optional usual transfer commission that is either a fixed amount or a percentage, active or deactivated, and whether it counts toward total money.
- **Opening Balance**: The amount already in an account when tracking starts, in EGP with at most 2 decimal places. It belongs to the account. It is not income and not a transfer.
- **Transaction**: One recorded change. Types are Income, Expense, and Transfer. Income and expense point at one account and one category, with an optional subcategory, date, and notes. A transfer points at a source account and a destination account, with a date, amount, and optional notes. A transfer, and an expense paid from a bank account or a digital wallet, also have a transfer commission of zero or more.
- **Transfer Commission**: The fee the person records on one qualifying transaction. It is spending, separate from the moved amount or the payment amount, and it is taken from the source or paying account on top of that amount. The destination of a transfer does not receive less because of it. On a payment it is a money amount when saved. On a transfer it is either a fixed amount or a percentage of the moved amount, and balances use the resulting money amount only. It may start from the account’s usual fee, and the person can change that starting value before saving.
- **Usual Transfer Commission**: The starting fee stored on one account for the next qualifying record. It is either a fixed amount of zero or more Egyptian pounds, or a percentage of zero or more. It is not spending until a saved record uses the fee the person left on that record.
- **Category**: A classification for either income or expense, such as Salary or Food. It can be ready-made or added by the person, and it can be active or disabled.
- **Subcategory**: A finer classification under one category, such as Fuel under Transportation. It can be active or disabled.
- **Total Money**: The sum of the current balance of every account. It is a result, not a separate record the person edits. Marking an account as excluded does not remove it from this sum.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A person can add a new account, including its opening balance, start date, and an optional usual fee, in under 1 minute.
- **SC-002**: A person can record an expense (amount, account, category, and date) in under 30 seconds, and an income record in the same time.
- **SC-003**: In 100% of checked cases, after any add, edit, or delete, each affected account balance equals opening balance + income − expenses + transfers in − transfers out, and the home total equals the sum of every account’s current balance.
- **SC-004**: In 100% of checked transfers with no commission, both balances change by the same amount, the home total does not change, and expense totals do not change. In 100% of checked transfers with a commission, the destination changes by the moved amount only, the source changes by the moved amount plus the commission, and total money and expenses change by the commission only.
- **SC-011**: In 100% of checked payments from a bank account or digital wallet, that account and total spending each change by the payment amount plus the commission, and the chosen category changes by the payment amount only. In 100% of checked payments from cash or from any other account type, no commission is stored and the balance changes by the payment amount only.
- **SC-012**: A person who already knows the fee can enter it in the same sitting as the move or qualifying payment, in under 15 seconds beyond the time to record the transaction itself, without saving a second transaction.
- **SC-013**: In 100% of checked new payments from a bank account or digital wallet, and in 100% of checked new moves, the fee starts from the relevant account’s usual fee (the paying account, or the source account), including a percentage usual fee that becomes 10 EGP on a 1,000 EGP move or 2 EGP on a 200 EGP payment at 1%, and can still be changed or cleared before saving. In 100% of checked cases, changing an account’s usual fee does not change a fee already saved, and storing a usual fee does not by itself change that account’s balance.
- **SC-015**: A person can save an account with a fixed usual fee or a 1% usual fee in the same sitting as the opening balance. In 100% of checked cases, a usual fee that was only a money amount before this choice existed opens as a fixed usual fee and does not change balances by itself.
- **SC-005**: A person can go from an empty product to seeing total money across at least two accounts, after one income and one expense, in under 5 minutes.
- **SC-006**: For any chosen day, week, month, or custom range, the person can see income, expenses, and net result in one step. For a personal history of up to 5,000 transactions, that result appears within 2 seconds.
- **SC-007**: Opening balance never appears in an income total, across the dashboard and every report, in 100% of checked cases.
- **SC-008**: A person can complete adding an account, recording a transaction, and reading the dashboard and a monthly report with the device offline, with no missing or blocked step.
- **SC-009**: Across a full pass of Phase 0 screens, the product never asks for a bank password, PIN, CVV, or bank sign-in.
- **SC-010**: At least 90% of first-time users in a moderated trial correctly state that a transfer with no commission did not increase their spending, and that a transfer with a commission increased spending by that fee only.
- **SC-014**: In 100% of checked transfers at 1% of 1,000 EGP, the commission is 10.00 EGP, the destination changes by 1,000 EGP only, and the source changes by 1,010 EGP. In 100% of checked percentage transfers, changing only the moved amount updates the commission from the same rate. In 100% of checked transfers saved before a percentage could be chosen, the commission and the balances stay unchanged until the person edits them.

## Assumptions

**Phase 0 boundary.** This specification is the MVP in BRD v1.0 section 20.1 only. The business source is Personal Finance Manager BRD v1.0, dated 6 October 2026, status Draft / Baseline.

**Included in Phase 0**

- Accounts: bank, e-wallet, cash, and other, with opening balances and an optional usual transfer commission on each account.
- Income, expense, and internal transfers, including edit and delete.
- A transfer commission on each internal transfer, and on each payment from a bank account or digital wallet. On a transfer the person chooses a fixed amount or a percentage of the moved amount. On a payment they type or keep a money amount. The fee is extra. A blank fee is zero. It is filed under رسوم تحويل. A usual fee stored on an account is either a fixed amount or a percentage that fills the next qualifying record and can be changed before saving.
- Categories and subcategories, including a ready-made set and disable-instead-of-delete.
- Home screen for the current calendar month, with the money currently in every account, a path from income, expenses, or a category to the matching transactions, and Settings for categories and backup.
- Reports: financial summary, expenses by category, income by category, account report, and transaction list, over a day, week, month, or custom range.
- Search on the screen, with account, type, category, and subcategory filters opened together beside it.
- Records kept on the device that work with no internet connection.
- Arabic, right-to-left presentation.
- Egyptian pounds only, with at most 2 decimal places (piastres).

**Not in Phase 0**

- Real bank transfers, payments, purchases, deposits, or withdrawals.
- Open banking or any live link to a bank or wallet.
- Storing bank passwords, PINs, CVVs, or sign-in details.
- Managing payment cards as a way to execute transactions.
- Multi-device sync.
- Sign-in, accounts for multiple people, and sharing.
- Any currency other than EGP, and any exchange-rate conversion.
- An in-app lock or passcode. Phase 0 relies on the device’s own lock. (The BRD requires protection of local data appropriate to the product; a separate app lock was not required for the MVP.)
- Cloud or other online backup, manual backup, scheduled backup, restore, and export/import. These are BRD Phase 2. Until that phase exists, there is no second copy of the data.
- Suggested categories, local classification rules, and learning from the person’s corrections. These are BRD Phase 3. In Phase 0 the person always chooses the category, except the transfer commission, which is always رسوم تحويل.
- Bank-looked-up fee schedules. A percentage on a transfer, or as an account’s usual fee, is a rate the person enters, not a tariff. A payment commission stays a money amount when saved. The destination is not charged instead of the source. Income has no commission.
- Budgets, advanced analytics, financial insights, and a natural-language money assistant (questions such as “how much did I spend on food this month?”, comparisons, pattern detection, and narrative summaries). These are BRD Phase 4.
- The following BRD data concepts are deferred with those phases: backup settings, and classification suggestions, confidence, and corrections.

**Defaults chosen where the BRD left room**

- One person, one device, no sign-in. The BRD’s “owner of the data and settings” is this single local person, not a registered profile.
- The home screen’s period for income and expenses is the current calendar month. The leading total is not limited to that month.
- A “week” preset is Saturday through Friday. Any other week shape is done with a custom range.
- The ready-made categories are the set named in FR-027, shown in Arabic. The BRD required categories and gave examples (Food, Salary, Transportation / Fuel) but did not list a full starter catalog.
- Recent activity on the home screen is the ten newest transactions. Expense categories there are ordered from the largest share to the smallest.
- Negative balances are allowed so an incomplete history does not block recording.
- Unused categories may be removed; used ones are disabled. The BRD said disabling is preferred so history stays intact.
- Accounts with history are deactivated rather than erased, for the same reason.
- Duplicate account names are allowed.
- Future-dated transactions are allowed.
- Optional notes are allowed on transfers, matching income and expense, even though the BRD only required amount, source, destination, and date.
- Search covers description, notes, account name, category name, and subcategory name. The BRD said “description, notes, or related data.”
- Total money ignores deactivated accounts unless the person explicitly includes them.
- Recorded balances are only as complete as what the person entered. The product never presents them as the institution’s live balance.
- The largest business risk called out in the BRD — a wrong balance when opening balances, transfers, edits, or deletes are handled incorrectly — is covered by SC-003, SC-004, SC-007, and SC-011.
- A transfer commission is money the person was charged, not a live tariff. Recording it does not send a payment or contact a bank or wallet.
- A usual fee belongs to the account that pays it: the source of a move, or the bank or wallet that pays an expense. The destination’s usual fee is not added. Saved records keep their own fee when the usual fee later changes. The usual fee may be a fixed amount or a percentage. On a new move it starts that same choice. On a new payment a percentage usual fee only starts the computed money amount. On a transfer the person may also change the commission basis by hand; that choice replaces the starting usual fee for that move and is not added on top of it. A calculated percentage is rounded half up to the nearest 0.01 EGP. Amounts and rates the person types still reject a third decimal place rather than rounding what they typed.
