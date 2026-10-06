# Feature Specification: Phase 2 — Backup and Restore

**Feature Branch**: `002-phase2-backup`

**Created**: 2026-10-06

**Status**: Draft

**Input**: User description: "We will work on Phase 2: Firebase/Cloud Backup, Manual Backup, Automatic Backup, Restore, Export/Import"

## Clarifications

### Session 2026-10-06

- Q: Must the person identify themselves, and for what? → A: Recording never requires an account. Identification is required only to send or retrieve a cloud copy. Export and import do not require it.
- Q: How many successful cloud copies are kept? → A: The five most recent. A sixth success removes the oldest.
- Q: Does an exported file have its own lock? → A: No. It is a complete copy, and the person chooses where to keep it. Import does not ask for a passphrase.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Keep a cloud copy on demand (Priority: P1)

A person who already tracks money on the device can, at any moment, send a complete copy of that book to their cloud backup. They can see when the last copy was made and whether it succeeded. Recording money does not wait for that copy, and a failed copy does not change the book on the device.

**Why this priority**: The commercial risk named in the product brief is losing the only copy of the person’s records. A manual cloud copy is the smallest action that creates a second copy they can ask for.

**Independent Test**: With known accounts and transactions on the device, run a manual backup while connected, then confirm the last-backup date and a successful status. Turn the connection off, run it again, and confirm the book on the device is unchanged and the status says the copy was not sent.

**Acceptance Scenarios**:

1. **Given** the person has accounts and transactions saved on the device, **When** they start a manual backup while connected, **Then** a complete cloud copy is stored and the screen shows the time of that copy and a successful status.
2. **Given** the device has no connection, **When** they start a manual backup, **Then** no success is shown, the book on the device is unchanged, and they are told the copy could not be sent.
3. **Given** the person is recording an expense, **When** a backup has not been sent or the last backup failed, **Then** they can still save the expense on the device.
4. **Given** a backup is in progress, **When** it finishes, **Then** the copy contains the records already saved on the device, not a half-saved change.
5. **Given** the person has not identified themselves, **When** they record money or export a file, **Then** both succeed without identification. **When** they start a cloud backup or open their cloud copies, **Then** they are asked to identify themselves first. Cancelling that step leaves the book on the device unchanged.

---

### User Story 2 - Restore a copy on purpose (Priority: P1)

A person who lost the book on this device, or who wants to return to an earlier copy, can choose a cloud copy and put it back. Before anything is replaced, they see the date of that copy and that their current accounts, transactions, and categories will be replaced. If they cancel, nothing changes.

**Why this priority**: A backup that cannot be restored does not protect the person. Restore is independently testable once any copy exists.

**Independent Test**: Save a known book, make a cloud copy, change or delete records, restore that copy after confirming, and match every account, transaction, and category to the copy. Repeat the restore and cancel; the later edits remain.

**Acceptance Scenarios**:

1. **Given** a cloud copy from a known date, **When** the person chooses it and confirms restore, **Then** the book on the device matches that copy, including balances that follow from its opening balances and transactions.
2. **Given** the person has newer records than the copy, **When** restore is offered, **Then** they are told that those current records will be replaced, and they must confirm before anything is removed.
3. **Given** restore is offered, **When** the person cancels, **Then** accounts, transactions, categories, balances, and reports stay as they were.
4. **Given** several successful cloud copies, **When** the person looks at the list, **Then** they see at most the five most recent, each with its date and that it came from the cloud, and they choose which one to restore.
5. **Given** five successful cloud copies already exist, **When** another cloud backup succeeds, **Then** the oldest of those five is no longer offered and the new copy is.
6. **Given** a restore finishes, **When** they record a new expense, **Then** that expense is saved on the device as usual and the cloud copy is not required for the save.

---

### User Story 3 - Send a copy on a schedule (Priority: P2)

A person can turn on an automatic cloud copy and choose daily, weekly, or monthly. They can turn it off. The product shows the last attempt: succeeded, failed, or waiting for a connection. Automatic copies never replace the book on the device.

**Why this priority**: People forget to back up. A schedule reduces that risk after they can already back up and restore by hand.

**Independent Test**: Turn automatic backup on for daily, open the product on a connected device after the last success was yesterday, and confirm a new successful copy. Set the schedule to off and confirm no further automatic copy is sent.

**Acceptance Scenarios**:

1. **Given** automatic backup is off, **When** the person uses the product, **Then** no cloud copy is sent unless they start a manual backup or export a file.
2. **Given** automatic backup is daily, **When** they open the product on a new calendar day while connected and the last success was on an earlier day, **Then** a cloud copy is sent and the last-backup status becomes successful.
3. **Given** automatic backup is weekly, **When** a new Saturday–Friday week has started since the last success and they are connected, **Then** a cloud copy is sent. **Given** it is monthly, **When** a new calendar month has started since the last success, **Then** a cloud copy is sent.
4. **Given** a scheduled copy is due but the device is offline, **When** they open the product, **Then** the status says the copy is waiting for a connection, the book on the device is unchanged, and a later connected open retries that copy.
5. **Given** automatic backup is on, **When** they switch it to off, **Then** scheduled copies stop and the last successful copy remains available to restore.

---

### User Story 4 - Export a file and bring it back (Priority: P2)

A person can save a file of their book and later bring that file back, including onto a device that is not connected to the cloud. Import uses the same warning as restore: current records are replaced only after confirmation. A file that is not a valid copy does not change the book.

**Why this priority**: Export and import move the book without relying on the cloud, which matches the rule that the device remains the working copy. It is testable without a cloud account.

**Independent Test**: Export a known book to a file, delete the book on the device, import the file after confirming, and match the original accounts, transactions, and categories. Import a file that is not a backup and confirm the current book is unchanged.

**Acceptance Scenarios**:

1. **Given** the person has a saved book, **When** they export, **Then** they receive a complete file they can keep or move, with no passphrase asked, and the book on the device is unchanged.
2. **Given** the device is offline, **When** they export, **Then** the file is still created.
3. **Given** an exported file from a known book, **When** they import it and confirm, **Then** the book on the device matches that file. Import does not ask for a passphrase.
4. **Given** import or a file restore is offered, **When** they cancel, **Then** the current book is unchanged.
5. **Given** a file that is missing, unreadable, or not a backup of this product, **When** they try to import it, **Then** the current book is unchanged and they are told the file could not be used.

---

### Edge Cases

- A backup is a complete copy of the records already saved. It does not include a change that has not been saved yet.
- Manual backup, automatic backup, and export never delete or replace the book on the device.
- Restore and import replace the whole current book. They do not merge with it and they do not restore a single account by itself.
- The person is told, before restore or import, the date of the copy and that current accounts, transactions, and categories will be replaced. Cancel leaves the current book unchanged.
- If the cloud copy cannot be sent or retrieved, the book on the device stays as it is and the status explains the failure.
- An automatic copy that is due while offline waits. It does not mark itself successful. The next time the product is open and connected, that due copy is tried again.
- Turning automatic backup off does not delete cloud copies already made or files the person already exported.
- The product keeps the five most recent successful cloud copies. A sixth success removes the oldest cloud copy from the list. Exported files are not part of that count and are not removed by a newer cloud backup.
- An exported file has no passphrase and no separate lock. The person chooses where to keep it. Import does not ask for a passphrase.
- A backup contains the same records the person already keeps on the device, including account labels such as bank name, account number, and wallet phone. It contains no bank password, PIN, CVV, or bank sign-in, because the product never asks for those.
- After restore or import, balances and reports follow the restored opening balances and transactions. The cloud copy does not stay in charge of later recording.
- Two accounts may still share a display name after restore, as they could before.
- The same Saturday–Friday week used for reports defines a weekly automatic backup. A monthly automatic backup follows the calendar month.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The book on the device remains the working copy. The person MUST be able to record and review money with no successful backup and with no connection.
- **FR-002**: The person MUST be able to start a manual cloud backup at any time.
- **FR-003**: A manual cloud backup MUST store a complete copy of the saved accounts, transactions, categories, and subcategories. It MUST NOT change those records on the device.
- **FR-004**: If a cloud backup cannot be sent, the product MUST say so, MUST NOT present it as successful, and MUST leave the book on the device unchanged.
- **FR-005**: The person MUST be able to turn automatic cloud backup on or off, and MUST be able to choose daily, weekly, monthly, or off.
- **FR-006**: Automatic backup MUST be off until the person turns it on.
- **FR-007**: While automatic backup is daily, weekly, or monthly, the product MUST send a cloud copy when that period has started since the last successful cloud copy and a connection is available. Weekly uses Saturday through Friday. Monthly uses the calendar month.
- **FR-008**: If an automatic copy is due and there is no connection, the product MUST show that it is waiting and MUST retry on a later open once a connection is available.
- **FR-009**: The person MUST be able to see the time of the last backup attempt, whether it succeeded, failed, or is waiting for a connection, and whether that copy was a manual cloud backup, an automatic cloud backup, or an exported file.
- **FR-010**: The person MUST be able to choose one of the five most recent successful cloud copies and restore it. A newly successful cloud copy MUST drop the oldest of those five from the list. Failed or waiting attempts MUST NOT take a place in those five.
- **FR-011**: Before restore or import replaces the current book, the product MUST explain that current accounts, transactions, and categories will be replaced and MUST show the date of the copy being applied. The replacement MUST NOT start until the person confirms.
- **FR-012**: If the person cancels restore or import, the current book MUST stay unchanged.
- **FR-013**: A confirmed restore or import MUST make the device book match the chosen copy, and later recording MUST continue on the device without requiring another backup first.
- **FR-014**: The person MUST be able to export a file of the current book with no connection and without a passphrase, without changing the book on the device. Import MUST NOT ask for a passphrase.
- **FR-015**: The person MUST be able to import an exported file. Import follows the same confirmation rules as restore.
- **FR-016**: An unreadable file, or a file that is not a backup of this product, MUST be rejected. The current book MUST stay unchanged, and the person MUST be told the file could not be used.
- **FR-017**: A backup, export, restore, or import MUST include the records needed to recreate the book and MUST NOT include a bank password, PIN, CVV, or bank sign-in.
- **FR-018**: Only the person who can open their cloud backup may retrieve that cloud copy. An exported file is theirs to keep; the product MUST NOT send that file to the cloud unless they separately run a cloud backup.
- **FR-021**: Recording, reviewing, and exporting money MUST NOT require the person to identify themselves. Sending or retrieving a cloud copy MUST ask them to identify themselves first. Cancelling that identification MUST leave the book on the device unchanged. Importing a file MUST NOT require identification.
- **FR-019**: Recording, editing, and deleting money MUST keep working when backup is off, failing, or waiting. Backup MUST NOT become the place where new transactions are entered.
- **FR-020**: This phase MUST NOT add category suggestions, budgets, insights, a financial assistant, a connection to a bank, or a real payment.

### Key Entities *(include if feature involves data)*

- **Backup copy**: A complete snapshot of the saved book. It has the time it was created, a source (manual cloud, automatic cloud, or exported file), and a status (succeeded, failed, or waiting for a connection). At most five successful cloud copies are listed for restore. An exported file is a copy the person holds and is not counted in those five.
- **Backup settings**: Whether automatic backup is off, daily, weekly, or monthly, plus the last attempt time, the last successful time, and the last status. These settings tell the person what will happen next; they are not a second ledger.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A person with an existing book can start a manual cloud backup and see a success or a clear failure in under 1 minute on a normal connection.
- **SC-002**: In 100% of checked cases, a failed or cancelled backup, restore, or import leaves every current account, transaction, and category unchanged.
- **SC-003**: In 100% of checked cases, a confirmed restore or import reproduces the accounts, transactions, categories, and resulting balances of the chosen copy, with no leftover mix of old and new records.
- **SC-004**: A person can export a file and import it back with no connection, and can record a new transaction immediately afterward without sending a backup.
- **SC-005**: With automatic backup set to daily, the next connected open on a new calendar day produces one new successful cloud copy, and a day that is still the same as the last success does not send another copy solely because the product was opened again.
- **SC-006**: At least 90% of people in a moderated check can say, before they confirm, that restore will replace the book currently on the device.

## Assumptions

- Phase 0 already exists: one person, one device, Arabic and right to left, Egyptian pounds, and the device book as the only working copy. This phase adds copies of that book. It does not add a second place to enter transactions.
- The cloud copy is kept for the identified person by the cloud backup service selected for this phase. The rules above stay the same if that service is replaced.
- Automatic backup is off for someone who has never chosen a schedule.
- A weekly automatic backup uses the same Saturday–Friday week as the person’s reports. A monthly automatic backup uses the calendar month. The check happens when they open the product, not at a hidden clock time while the product is closed.
- Restore and import replace the entire current book. They do not merge two books and they do not restore one account at a time.
- Exported files remain the person’s to keep or delete outside the product. A newer cloud backup does not delete them.
- Account labels already stored on the device, including an optional bank name, account number, and wallet phone, are part of the copy because otherwise the restored book would be incomplete. Secrets the product never collects are not part of the copy.
- Category suggestions, budgets, insights, and a financial assistant remain out of scope, as do live bank balances and real payments.
