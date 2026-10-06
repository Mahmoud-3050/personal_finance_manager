# Contract: Export file version 1

A file the person keeps. No passphrase. Not sent to the cloud unless they also run a cloud backup.

## Required fields

| Field | Rule |
|---|---|
| `formatVersion` | Number `1`. Any other value is rejected |
| `createdAt` | Timestamp of the export or cloud copy |
| `source` | `manualCloud`, `automaticCloud`, or `export` |
| `accounts` | Array of saved account records |
| `categories` | Array of saved category records |
| `subcategories` | Array of saved subcategory records |
| `transactions` | Array of saved transaction records |

Account, category, subcategory, and transaction objects use the same JSON as the existing data models (`toJson` / `fromJson`). Amounts stay integer piastres. Dates stay calendar dates. A transfer stays one record with source and destination.

## Reject

Missing required fields, a different `formatVersion`, or JSON that is not this object. Rejection does not write the device book.

## Cloud object

The same document, stored for the signed-in person, named by `createdAt`. Only `succeeded` uploads are kept, and only the five newest.
