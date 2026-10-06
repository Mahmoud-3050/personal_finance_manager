# Contract: Backup screens

Arabic, right to left. The device book is what later screens edit. These screens only copy or replace that book.

## Status

Reached from Settings. Shows the schedule (`off`, daily, weekly, monthly), the last attempt time, the last status (`succeeded`, `failed`, `waiting`), and the last source when one exists.

- Manual backup: asks the person to identify themselves if they have not. Connected → success with the new time. Offline or upload failure → failed or waiting, book unchanged.
- Schedule change: saved on the device immediately. `off` sends nothing further.
- Export: writes a version-1 file with no passphrase, online or offline, book unchanged. The person picks where the file goes.
- Empty book: backup and export still succeed with an empty snapshot.

## Cloud copies

Lists at most five successful cloud copies, newest first, each with its date.

- Opening the list asks for identification if needed. Cancel returns to status and does not change the book.
- Restore asks for confirmation and shows the copy date plus the statement that current accounts, transactions, and categories will be replaced. Confirm replaces the book. Cancel does not.
- A sixth successful cloud backup removes the oldest row from this list.

## Import

The person picks a file.

- A version-1 backup file opens the same confirmation as restore, using the file’s `createdAt`.
- Any other file shows that it could not be used. The book is unchanged.
- Import does not ask for a passphrase and does not ask the person to identify themselves.

## Automatic check

When the finance shell opens, if the schedule is due and the device is connected, one cloud copy is sent and the status updates. If it is due and offline, the status becomes waiting. This check does not open a screen and does not block recording.
