# Feature Specification: Phase 0 MVP — Personal Money Tracking

**Feature Branch**: `001-phase0-mvp`

**Created**: 2026-10-06

**Status**: Draft

**Input**: User description: "This is the BRD for Personal Finance Manager (BRD v1.0, 6 October 2026, Draft / Baseline). Read it and collect the project details. Create Phase 0 (MVP) for now."

Phase 0 is the first usable version of a personal money-tracking product for one person. The person records where money sits and how it moves. The product does not connect to banks, does not move real money, and does not ask for bank secrets. Everything the person records stays on the device and works with no internet connection.

This specification covers only the MVP described in BRD section 20.1: accounts and opening balances, income, expense, and internal transfers, categories and subcategories, a basic dashboard, basic reports over a chosen date range, search and filters, and recording that stays on the device. Later phases are listed under Assumptions so they are not lost, and they are not part of this specification.

## Clarifications

### Session 2026-10-06

- Q: How precise are money amounts in Phase 0? → A: Egyptian pounds and piastres, at most 2 decimal places (for example 12.50). More than 2 decimal places is rejected, not rounded.
- Q: Which accounts does the dashboard list when some are deactivated? → A: Active accounts only. Deactivated accounts stay in the account list and in past reports, and are not offered for new transactions.
- Q: Which days does “this week” include? → A: Saturday through Friday.
- Q: Can the account type change after creation? → A: Only while the account has no transactions. After that, the type is fixed.
- Q: Which destructive actions ask for confirmation? → A: Deleting a transaction, deleting an account with no transactions, and deactivating an account. Cancel leaves everything unchanged. Amount edits do not ask.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See where money sits (Priority: P1)

A person adds each account that holds money — a bank account, an electronic wallet, cash, or another account — and records how much was there when they started tracking it. They can then see each account’s current balance and the total of the accounts they choose to include.

**Why this priority**: Without accounts and a starting balance, later income, spending, and reports have nothing to attach to. This story alone already answers “how much money do I have, and where is it?”

**Independent Test**: Add two accounts with opening balances and confirm each balance and the combined total, with no income or expense recorded yet.

**Acceptance Scenarios**:

1. **Given** the person has no accounts yet, **When** they add “Bank ABC” as a bank account with an opening balance of 25,000 EGP and a start date, **Then** that account shows a current balance of 25,000 EGP, and that 25,000 is not counted as income.
2. **Given** a bank account is being added, **When** the person enters a bank name and an account number, **Then** those values are kept only as labels that identify the account.
3. **Given** an electronic wallet is being added, **When** the person enters the linked phone number, **Then** that number is kept only as a label that identifies the wallet.
4. **Given** two active accounts are included in the total, **When** the person views their money, **Then** the total equals the sum of those two current balances.
5. **Given** an account is excluded from the total, **When** the person views total money, **Then** that account’s balance is omitted from the total and remains visible on the account itself.
6. **Given** an account already has history, **When** the person deactivates it and confirms, **Then** its past records stay unchanged, it disappears from the dashboard, it remains in the account list, it cannot be used for new transactions, and it stays out of the total unless the person includes it again. **When** they cancel, **Then** the account stays active and nothing changes.
7. **Given** an account has no transactions, **When** the person removes it and confirms, **Then** it disappears. **When** they cancel, **Then** the account remains. **Given** an account has transactions, **When** the person tries to remove it permanently, **Then** the product offers deactivation instead and keeps the history.
8. **Given** an account has no transactions, **When** the person changes its type, **Then** the type changes and identifying labels that do not apply to the new type are cleared.
9. **Given** an account already has a transaction, **When** the person tries to change its type, **Then** the type stays unchanged and they are told that the type is fixed once transactions exist.

---

### User Story 2 - Record income and spending (Priority: P1)

A person records money coming in and money going out against a chosen account, category, and date, with optional notes. Each record immediately changes that account’s balance. They can correct or remove a record, and the balance follows the correction.

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

---

### User Story 3 - Move money between own accounts (Priority: P2)

A person records an internal move from one of their accounts to another. The source goes down, the destination goes up, and their overall money and their spending total stay the same.

**Why this priority**: People split money across a bank, a wallet, and cash. If a move were treated as spending, totals and reports would be wrong. This story is what makes multi-account tracking trustworthy.

**Independent Test**: With two included accounts, record a 1,000 EGP move and confirm the two balances, the overall total, and the expense total.

**Acceptance Scenarios**:

1. **Given** Bank ABC and Vodafone Cash are both active and included in the total, **When** the person records a move of 1,000 EGP from Bank ABC to Vodafone Cash on a valid date, **Then** Bank ABC decreases by 1,000, Vodafone Cash increases by 1,000, total money is unchanged, and total expenses do not increase.
2. **Given** a move is recorded, **When** the person views income and expense reports, **Then** the move appears as a transfer, not as income and not as an expense.
3. **Given** the person edits the amount or either account, **When** they save, **Then** both balances and the total match the edited move.
4. **Given** the person deletes the move and confirms, **When** deletion completes, **Then** both balances return to what they were before that move. **When** they cancel, **Then** the move and both balances stay as they were.
5. **Given** the source and destination are the same account, or either account is deactivated, or the amount is not greater than zero, or the date is before either account’s opening date, **When** they try to save, **Then** the move is rejected with a clear reason.
6. **Given** only the source account is included in the total, **When** a move is recorded to an excluded account, **Then** total money decreases by the amount, because the destination is outside the total. The move is still not an expense.

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

A person opens the dashboard and sees this calendar month’s income, expenses, and net result, plus total money, each active account’s balance, how expenses split by category, and the latest transactions. From any summary they can open the matching detail. Deactivated accounts are not on the dashboard.

**Why this priority**: The dashboard is the daily answer to “how is this month going?”. It depends on Stories 1–4 and is the first screen that brings them together.

**Independent Test**: With known transactions inside and outside the current month, open the dashboard and confirm only the current month is summarized, then open one summary and land on the matching detail.

**Acceptance Scenarios**:

1. **Given** transactions exist in the current calendar month and in earlier months, **When** the person opens the dashboard, **Then** income, expenses, and net result include only the current calendar month, and transfers are not part of income or expenses.
2. **Given** the dashboard is open, **When** the person looks at accounts, **Then** each active account shows its current balance, deactivated accounts are absent, and total money matches the included accounts.
3. **Given** the current month has expenses in more than one category, **When** the person views the expense split, **Then** each category shows its amount and its share of the month’s expenses.
4. **Given** the dashboard is open, **When** the person looks at recent activity, **Then** they see the ten most recent transactions across all accounts, newest first.
5. **Given** a summary figure or category on the dashboard, **When** the person opens it, **Then** they see the underlying transactions for that figure.
6. **Given** the current month has no transactions, **When** the person opens the dashboard, **Then** income, expenses, and net result are zero and the empty state is clear, while account balances still reflect opening balances and older transactions.

---

### User Story 6 - Review any period (Priority: P2)

A person chooses a day, a week, a calendar month, or any start and end date, and reads income, spending, net result, category breakdowns, each account’s activity, and the list of transactions for that period.

**Why this priority**: Flexible periods are a stated reason the product exists. The dashboard covers “this month”; this story covers every other question about a period.

**Independent Test**: Record known income, expenses, and a transfer in September, then run the 1–30 September report and match every total by hand.

**Acceptance Scenarios**:

1. **Given** transactions exist from 1 to 30 September, **When** the person requests that custom range, **Then** they see total income, total expenses, and net result for those dates only, with transfers excluded from all three.
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
2. **Given** a list of transactions, **When** the person filters by a date range, an account, a type (income, expense, or transfer), or a category or subcategory, **Then** the list shows only matches for that filter.
3. **Given** several filters at once, **When** the list refreshes, **Then** a transaction must match every selected filter to appear.
4. **Given** filters that match nothing, **When** the list refreshes, **Then** the person sees an empty result, not an error.
5. **Given** the person clears search and filters, **When** the list refreshes, **Then** the full set for the current context is shown again.

---

### Edge Cases

- Opening balance is never income, including when a report’s period starts on the account’s opening date.
- Correcting an opening balance or opening date recalculates every later balance and report. The new opening date cannot be moved to after an existing transaction; the person is told which transactions block the change.
- Account type can change only before the first transaction. That change clears identifying labels that do not apply to the new type. After any transaction, the type stays as it is.
- A deactivated account remains in the account list and in historical reports for periods when it had activity. It does not appear on the dashboard and it is not a choice for new income, expenses, or transfers. If the person includes it in total money, its balance counts in the total even though the dashboard does not list it.
- A disabled category or subcategory remains visible on old transactions and disappears from choices for new ones.
- An expense or transfer larger than the current balance is allowed. The balance is shown as negative and stays mathematically consistent.
- A transfer into an account that is excluded from total money changes total money, because money left the included set. It still does not count as an expense.
- A transfer out of an excluded account into an included account increases total money and still does not count as income.
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

- **FR-001**: The person MUST be able to create an account of type Bank Account, E-Wallet, Cash, or Other, with a name, an opening balance, and an opening date.
- **FR-002**: A bank account MUST allow an optional bank name and an optional account number, kept only as labels that identify the account.
- **FR-003**: An e-wallet account MUST allow an optional linked phone number, kept only as a label that identifies the wallet.
- **FR-004**: Every amount in Phase 0, including opening balances, income, expenses, transfers, balances, and totals, MUST be in Egyptian pounds (EGP) with at most 2 decimal places. The person is not offered another currency. An amount with more than 2 decimal places MUST be rejected and MUST NOT be rounded.
- **FR-005**: The person MUST be able to edit an account’s name, type-specific labels, opening balance, opening date, and whether it is included in total money. The person MUST be able to change the account type only while that account has no transactions. Changing the type MUST clear identifying labels that do not apply to the new type. Once the account has any transaction, the type MUST stay unchanged.
- **FR-006**: A new account MUST be included in total money by default. The person MUST be able to exclude or include it later.
- **FR-007**: The person MUST be able to deactivate an account. A deactivated account MUST NOT accept new income, expenses, or transfers, and MUST NOT appear on the dashboard. It MUST remain in the account list, where the person can still see it, reactivate it, or change whether it is included in total money. Its existing history MUST remain available in past views and reports.
- **FR-008**: An account with no transactions MUST be removable. An account with transactions MUST NOT be permanently erased; deactivation is the way to retire it.
- **FR-009**: The current balance of an account MUST equal its opening balance, plus income, minus expenses, plus transfers in, minus transfers out.
- **FR-010**: Total money MUST equal the sum of the current balances of accounts marked as included. Deactivated accounts stay excluded unless the person includes them.
- **FR-011**: The opening balance MUST NOT be counted as income in any total, dashboard, or report.
- **FR-012**: Changing an opening balance or opening date MUST recalculate affected balances and reports. The product MUST reject an opening date that falls after an existing transaction on that account.

**Income, expense, and transfer**

- **FR-013**: The person MUST be able to record income with a required amount, account, income category, and date, plus an optional subcategory and optional description or notes.
- **FR-014**: The person MUST be able to record an expense with a required amount, account, expense category, and date, plus an optional subcategory and optional description or notes.
- **FR-015**: Income MUST increase the chosen account’s balance. An expense MUST decrease it.
- **FR-016**: The person MUST be able to record a transfer with a required amount, source account, destination account, and date, plus optional notes.
- **FR-017**: A transfer MUST decrease the source and increase the destination by the same amount. It MUST NOT be included in income totals or expense totals.
- **FR-018**: When both accounts in a transfer are included in total money, the transfer MUST leave total money unchanged.
- **FR-019**: The person MUST be able to edit and delete income, expenses, and transfers. After each confirmed change, balances, the dashboard, and reports MUST match the remaining records.
- **FR-020**: Income, expense, and transfer amounts MUST be greater than zero. Opening balances MAY be positive, zero, or negative.
- **FR-021**: A transfer MUST be rejected when the source and destination are the same account, or when either account is missing or deactivated.
- **FR-022**: A transaction date MUST be on or after the opening date of every account it touches.
- **FR-023**: The person MUST choose the category themselves. Phase 0 MUST NOT assign or rewrite a category on its own.
- **FR-024**: Before any account exists, the product MUST ask the person to add one and MUST NOT offer a way to save a transaction.

**Categories**

- **FR-025**: Income categories and expense categories MUST be separate. A category MUST NOT be usable for the other transaction type.
- **FR-026**: A category MAY have one or more subcategories. A subcategory belongs to exactly one category.
- **FR-027**: On first use, the product MUST offer a ready-made set the person can edit or disable. Labels are Arabic:
  - Income: راتب (Salary), عمل حر (Freelance), نشاط تجاري (Business), هدايا (Gifts), أخرى (Other).
  - Expense: طعام (Food), مواصلات (Transportation) with subcategory وقود (Fuel), تسوق (Shopping), فواتير (Bills), صحة (Health), تعليم (Education), ترفيه (Entertainment), أسرة (Family), أخرى (Other).
- **FR-028**: Until the person renames them, ready-made category and subcategory labels MUST appear as the Arabic words in FR-027.
- **FR-029**: The person MUST be able to add and rename categories and subcategories, for both the ready-made set and their own.
- **FR-030**: A category or subcategory that has been used MUST be disabled rather than erased. Disabled items MUST remain visible on historical transactions and MUST NOT be selectable for new transactions.
- **FR-031**: A category or subcategory that has never been used MAY be removed.

**Dashboard, reports, search**

- **FR-032**: The dashboard MUST show, for the current calendar month: total income, total expenses, and net result (income minus expenses). Transfers MUST be excluded from these three figures.
- **FR-033**: The dashboard MUST show total money and each active account with its current balance. It MUST NOT list deactivated accounts.
- **FR-034**: The dashboard MUST show the current month’s expenses by category, with amount and percentage share.
- **FR-035**: The dashboard MUST show the ten most recent transactions, newest first.
- **FR-036**: From a dashboard total, category, or account, the person MUST be able to open the transactions that make up that figure.
- **FR-037**: The person MUST be able to run reports for a single day, the current week (Saturday through Friday), a calendar month, or a custom start and end date. The start and end dates are included.
- **FR-038**: The financial summary for a period MUST show total income, total expenses, and net result, excluding transfers.
- **FR-039**: Expenses by category MUST show, for the period, the amount and the percentage of period expenses for each category and subcategory that has activity.
- **FR-040**: Income by category MUST show, for the period, the amount and the percentage of period income for each income category that has activity.
- **FR-041**: When the relevant period total is zero, percentages MUST be shown as 0%.
- **FR-042**: The account report for a period MUST show starting balance, income, expenses, transfers in, transfers out, and ending balance. Starting balance is the account’s balance just before the period begins. If the account opens during the period, starting balance is its opening balance.
- **FR-043**: The transaction report MUST list income, expenses, and transfers in the period. When a search or filters are active, the list MUST show only the transactions that match.
- **FR-044**: Total money on reports and the dashboard is the current sum of included accounts, not a figure limited to the report period.
- **FR-045**: A period or filter with no matching transactions MUST show zero totals and an empty list, without treating that as a failure.
- **FR-046**: The person MUST be able to search transactions by words in the description, notes, account name, category name, or subcategory name.
- **FR-047**: The person MUST be able to filter transactions by date range, account, transaction type, and category or subcategory, and MUST be able to combine those filters. Combined filters keep only transactions that match all of them.

**Privacy, trust, and availability**

- **FR-048**: The person MUST be able to complete every Phase 0 story with no internet connection.
- **FR-049**: Records MUST still be there after the product is closed and opened again.
- **FR-050**: The product MUST NOT ask for or keep a bank password, PIN, CVV, or bank sign-in details.
- **FR-051**: The product MUST NOT send, receive, or carry out a real payment, purchase, deposit, withdrawal, or bank transfer.
- **FR-052**: Phase 0 MUST serve one person on one device. It MUST NOT require sign-in.
- **FR-053**: Every screen the person uses in Phase 0 MUST be Arabic and laid out right to left.
- **FR-054**: The product MUST ask the person to confirm before deleting a transaction, deleting an account that has no transactions, or deactivating an account. If the person cancels, records, balances, and reports MUST stay unchanged. Editing an amount, category, date, notes, or other account details MUST NOT require this confirmation.

### Key Entities *(include if feature involves data)*

- **Account**: A place where the person’s money sits, such as a bank account, an electronic wallet, cash, or another place. Attributes include name, type (Bank Account, E-Wallet, Cash, or Other), optional identifying labels, currency (EGP in Phase 0), opening balance, opening date, active or deactivated, and whether it counts toward total money.
- **Opening Balance**: The amount already in an account when tracking starts, in EGP with at most 2 decimal places. It belongs to the account. It is not income and not a transfer.
- **Transaction**: One recorded change. Types are Income, Expense, and Transfer. Income and expense point at one account and one category, with an optional subcategory, date, and notes. A transfer points at a source account and a destination account, with a date, amount, and optional notes.
- **Category**: A classification for either income or expense, such as Salary or Food. It can be ready-made or added by the person, and it can be active or disabled.
- **Subcategory**: A finer classification under one category, such as Fuel under Transportation. It can be active or disabled.
- **Total Money**: The sum of current balances for accounts included in the total. It is a result, not a separate record the person edits.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A person can add a new account, including its opening balance and start date, in under 1 minute.
- **SC-002**: A person can record an expense (amount, account, category, and date) in under 30 seconds, and an income record in the same time.
- **SC-003**: In 100% of checked cases, after any add, edit, or delete, each affected account balance equals opening balance + income − expenses + transfers in − transfers out, and total money equals the sum of included balances.
- **SC-004**: In 100% of checked transfers between two included accounts, both balances change by the same amount, total money does not change, and expense totals do not change.
- **SC-005**: A person can go from an empty product to seeing total money across at least two accounts, after one income and one expense, in under 5 minutes.
- **SC-006**: For any chosen day, week, month, or custom range, the person can see income, expenses, and net result in one step. For a personal history of up to 5,000 transactions, that result appears within 2 seconds.
- **SC-007**: Opening balance never appears in an income total, across the dashboard and every report, in 100% of checked cases.
- **SC-008**: A person can complete adding an account, recording a transaction, and reading the dashboard and a monthly report with the device offline, with no missing or blocked step.
- **SC-009**: Across a full pass of Phase 0 screens, the product never asks for a bank password, PIN, CVV, or bank sign-in.
- **SC-010**: At least 90% of first-time users in a moderated trial correctly state that a transfer between their own accounts did not increase their spending.

## Assumptions

**Phase 0 boundary.** This specification is the MVP in BRD v1.0 section 20.1 only. The business source is Personal Finance Manager BRD v1.0, dated 6 October 2026, status Draft / Baseline.

**Included in Phase 0**

- Accounts: bank, e-wallet, cash, and other, with opening balances.
- Income, expense, and internal transfers, including edit and delete.
- Categories and subcategories, including a ready-made set and disable-instead-of-delete.
- Dashboard for the current calendar month, with a path from summary to detail.
- Reports: financial summary, expenses by category, income by category, account report, transaction list, and total money, over a day, week, month, or custom range.
- Search and combined filters.
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
- Suggested categories, local classification rules, and learning from the person’s corrections. These are BRD Phase 3. In Phase 0 the person always chooses the category.
- Budgets, advanced analytics, financial insights, and a natural-language money assistant (questions such as “how much did I spend on food this month?”, comparisons, pattern detection, and narrative summaries). These are BRD Phase 4.
- The following BRD data concepts are deferred with those phases: backup settings, and classification suggestions, confidence, and corrections.

**Defaults chosen where the BRD left room**

- One person, one device, no sign-in. The BRD’s “owner of the data and settings” is this single local person, not a registered profile.
- The dashboard’s “current period” is the current calendar month.
- A “week” preset is Saturday through Friday. Any other week shape is done with a custom range.
- The ready-made categories are the set named in FR-027, shown in Arabic. The BRD required categories and gave examples (Food, Salary, Transportation / Fuel) but did not list a full starter catalog.
- Recent activity on the dashboard is the ten newest transactions.
- Negative balances are allowed so an incomplete history does not block recording.
- Unused categories may be removed; used ones are disabled. The BRD said disabling is preferred so history stays intact.
- Accounts with history are deactivated rather than erased, for the same reason.
- Duplicate account names are allowed.
- Future-dated transactions are allowed.
- Optional notes are allowed on transfers, matching income and expense, even though the BRD only required amount, source, destination, and date.
- Search covers description, notes, account name, category name, and subcategory name. The BRD said “description, notes, or related data.”
- Total money ignores deactivated accounts unless the person explicitly includes them.
- Recorded balances are only as complete as what the person entered. The product never presents them as the institution’s live balance.
- The largest business risk called out in the BRD — a wrong balance when opening balances, transfers, edits, or deletes are handled incorrectly — is covered by SC-003, SC-004, and SC-007.
