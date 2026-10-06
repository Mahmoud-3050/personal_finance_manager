# Phase 2 Quickstart: Backup and Restore

Prove the backup spec on a device. The book under test is the Phase 0 book (accounts, transactions, categories). Details of the file are in [contracts/export-file.md](contracts/export-file.md). Screen behavior is in [contracts/backup-screens.md](contracts/backup-screens.md).

## Before you start

1. The app already has a book with at least two accounts, one income, one expense, and one transfer.
2. Note total money and one account balance.
3. Cloud checks need a connection and a Google sign-in. Export checks do not.

## Manual cloud backup

1. Open backup status and start a manual backup. Sign in when asked.
2. Expect a success time and status.
3. Turn the connection off and start another manual backup.
4. Expect a failure or waiting status. Total money and the noted balance are unchanged.

## Five copies

1. While connected, run six successful manual backups.
2. Open the cloud list.
3. Expect five rows, newest first. The oldest of the six is gone.

## Restore

1. Change an account name after the latest copy.
2. Choose that copy. Read the date and the replace warning. Cancel.
3. Expect the new name to remain.
4. Choose the copy again and confirm.
5. Expect the previous name, the original transactions, and the original balances.

## Automatic

1. Set the schedule to daily. Confirm a success if none exists for today.
2. Open the app again the same day. Expect no second success caused only by opening it.
3. Set the schedule to off. Open the app on the next day while connected. Expect no new cloud copy.

## Export and import

1. Turn the connection off. Export. Expect a file and an unchanged book. No passphrase prompt.
2. Delete one transaction.
3. Import the file, read the warning, cancel. Expect the transaction to stay deleted.
4. Import again and confirm. Expect the transaction to return.
5. Import a text file that is not version 1. Expect an unusable-file message and no change to the book.

## Still local

After any of the above, add an expense while offline. Expect it to save. The cloud copy is not required.
