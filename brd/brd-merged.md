# Finzo Manager — Merged Product BRD

**Business Requirements Document** — Finzo Manager’s product advantages combined with the product advantages described for Monevro.

| | |
|---|---|
| Version | 1.0 |
| Status | Draft for Review |
| Platforms | Android + iOS |
| Sources | `brd/brd.md` (Finzo Manager) and the public Monevro description in [Mohamed Hamdy’s post](https://www.linkedin.com/feed/update/urn:li:activity:7511850211976327168/) |
| Supersedes | Nothing. `brd/brd.md` stays the current approved draft until this document is reviewed. |

| Functional requirements | MVP (Must) | Estimated delivery |
|---|---|---|
| 32 (21 Must, 9 Should, 2 Could) | 21 requirements | 20–28 weeks for Must, one full-time developer. Should items are a following release. |

---

## 00. Merge decisions

Where the two products describe the same job, this document keeps one rule. Where they differ, the choice below is the requirement.

| Topic | Choice in this BRD | Taken from |
|---|---|---|
| Source of truth | The on-device ledger is the operational source of truth. Firebase stores the signed-in user’s backup and account data. | Finzo, with Monevro’s signed-in cloud identity |
| Offline use | Accounts, transactions, budgets, goals, and reports work without a network. | Finzo |
| Capture | Receipt photo and voice both produce a draft. The user reviews it before anything is saved. | Finzo voice and review; Monevro receipt fields (merchant, amount, category) |
| Captured media | The receipt image and the voice recording are deleted when the review flow is confirmed or cancelled. | Monevro |
| Categories | Categories, subcategories, and a budget per category. | Finzo subcategories; Monevro budgets |
| Goals | Savings goals track progress. A category budget can be linked to a goal. | Both, link from Monevro |
| Obligations | Recurring obligations with due dates stay separate from budgets. | Finzo |
| Safe-to-Spend | Shown with an explanation, after obligations, planned savings, and reserves, without double-counting a linked budget. | Finzo |
| Alerts | Warn when a budget is nearly used, a goal reaches a milestone, or an obligation is due. | Monevro, plus Finzo obligations |
| AI role | Local rules first. Cloud AI extracts, suggests, explains, and drafts a plan. The ledger calculates balances. | Finzo rule; Monevro planning assistant |
| AI access | A free quota and a higher Premium quota, with a fallback if the provider fails. The provider can be replaced. | Monevro quotas; Finzo provider flexibility |
| Identity | The app can be used locally with no account. Email, Google sign-in, backup, restore, and Premium require an account. | Monevro account; Finzo offline core |
| App lock | Optional fingerprint or face unlock on the device. | Monevro |
| Money model | Several accounts (bank, e-wallet, cash), opening balances, and internal transfers. | Finzo |
| Payees | A transaction can name a recipient. | Monevro |
| Currency | One primary currency in the first release. | Monevro setting; Finzo multi-currency stays Could |
| Reports | Dashboard and charts for a week, a month, or a chosen range, by category, period, and budget. | Both |
| Languages | Arabic and English, with RTL for Arabic. Receipt reading includes Arabic. | Both |
| Platforms | Android and iOS from the first release. | Finzo |
| Monetization | Free includes the financial core, receipt and voice capture within quota, budgets, and goals. Premium raises the AI quota and removes ads. | Monevro |

---

## 01. Executive Summary

Finzo Manager is a personal finance application for Android and iOS. The user keeps several accounts, records income, expenses, and internal transfers, and sees Safe-to-Spend after obligations, savings, and reserves. Capture from a receipt photo or from voice fills a draft; the user confirms it before it is stored. Category budgets, savings goals, and alerts show whether spending and saving are on track. An assistant can explain the picture and draft a plan from recorded habits. It does not post transactions or change balances.

The phone database is the working copy. A signed-in user can back that copy up to Firebase and restore it. Receipt images and voice recordings are removed at the end of the capture flow.

## 02. Goals & Product Vision

- Show a reliable picture of personal finances across accounts.
- Cut entry work through receipt and voice capture, and keep the user as the one who confirms the record.
- Show Safe-to-Spend after obligations, planned savings, and reserves.
- Let the user set a budget per category, a savings goal, and a link between them.
- Warn before a budget is exhausted, when a goal hits a milestone, and when an obligation is due.
- Use AI to read, classify, explain, and draft plans. Use the ledger for every balance.
- Keep the financial core available offline.
- Tie backup, restore, and Premium to an account the user can delete, taking cloud data with it.
- Offer a free plan that is useful, and a Premium plan with a higher AI quota and no ads.

## 03. Stakeholders & Users

| Stakeholder | Role |
|---|---|
| End User | Records transactions, manages accounts, budgets, obligations, and goals, and may subscribe. |
| Product Owner | Defines scope, priorities, prices, and business rules. |
| Developer | Implements, tests, and releases the product. The estimate assumes one full-time developer. |

## 04. Platforms & Product Strategy

- One shared Flutter application for Android and iOS.
- Local ledger first. Cloud backup, account identity, and subscriptions sit beside it.
- Hybrid AI: on-device rules and history, then a cloud model when the draft needs it. A second provider is the fallback. Quotas differ by plan.
- Backup and restore ship with the first release, for a signed-in user.
- Arabic and English, including RTL.
- Free and Premium. Premium is billed as a monthly or yearly subscription and can be restored on another device for the same account. Ads, when shown, stay off transaction entry, review, and Safe-to-Spend.

## 05. MVP Scope — In Scope (Must)

- Multiple accounts: bank, e-wallet, and cash, each with an opening balance.
- Income, expenses, and internal transfers.
- Categories, subcategories, and a budget amount per category for a period.
- One primary currency for amounts, budgets, goals, and reports.
- Manual entry.
- Receipt capture that proposes merchant, amount, date, and category, including Arabic receipts.
- Voice capture that proposes the same kind of fields.
- A review screen. Nothing from a photo, voice, or model is stored as a transaction until the user confirms it.
- Deletion of the receipt image and the voice recording when that flow ends.
- Category suggestions from local rules and history, then cloud AI when needed.
- Dashboard, charts, and reports for a week, a month, or a selected range, by category, period, and budget.
- Recurring obligations and savings goals with progress.
- Safe-to-Spend with a short explanation.
- Local storage and offline operation of the core.
- Optional account via email and password or Google. Backup, restore, and Premium require it.
- Firebase backup and restore, with validation and a clear statement of impact.
- Removal of that user’s cloud backup and stored files when the account is deleted.

## 06. Following release — In Scope (Should)

- Duplicate-transaction warning, with no automatic delete or merge.
- Cash-flow forecast through the next salary date, labeled as an estimate.
- Link from a category budget to a savings goal, without double-counting in Safe-to-Spend.
- Alerts for a budget threshold, a goal milestone, and an obligation due date.
- An in-app list of those alerts.
- A recipient on a transaction.
- Optional fingerprint or face unlock.
- An assistant that drafts a plan from recorded spending and states that the plan is advice.
- Free and Premium entitlements, AI quotas, an ad-free Premium plan, and subscription restore for the same account.

## 07. Could

- A simulation of a hypothetical decision, kept separate from actual balances.
- More than one currency, with an explicit exchange-rate rule.

## 08. Out of Scope

- Executing payments, bank transfers, or Instapay transfers.
- Bank connectivity that posts transactions or reads a live bank balance.
- Reading bank SMS or bank notifications.
- Using the cloud database as the live ledger.
- Training a proprietary model from scratch.
- Investment management or investment recommendations.
- Business accounting or shared multi-user books.
- Letting the model write a balance, a budget result, or Safe-to-Spend.

## 09. Functional Requirements

| ID | Requirement | Priority | Origin |
|---|---|---|---|
| FR-001 | Manage multiple financial accounts. | Must | Finzo |
| FR-002 | Support bank accounts, e-wallets, and cash. | Must | Finzo |
| FR-003 | Set an opening balance on each account. | Must | Finzo |
| FR-004 | Record income, expenses, and internal transfers. | Must | Finzo |
| FR-005 | Manage categories and subcategories. | Must | Finzo |
| FR-006 | Enter a transaction manually. | Must | Both |
| FR-007 | From a receipt image, propose merchant, amount, date, and category. Support Arabic receipts. | Must | Both |
| FR-008 | From speech, propose the same transaction fields. | Must | Finzo |
| FR-009 | Require review and edit before an extracted transaction is saved. | Must | Finzo |
| FR-010 | Suggest a category from local rules and history, and from cloud AI when local confidence is low. | Must | Finzo |
| FR-011 | Show a dashboard, charts, and reports for a week, a month, or a selected range, by category, period, and budget. | Must | Both |
| FR-012 | Manage recurring obligations and their due dates. | Must | Finzo |
| FR-013 | Manage savings goals and show progress against the target. | Must | Both |
| FR-014 | Calculate Safe-to-Spend and explain which amounts were included or excluded. | Must | Finzo |
| FR-015 | Store the ledger locally and operate the core offline. | Must | Finzo |
| FR-016 | Back up and restore through Firebase for a signed-in user. Validate the backup and explain the restore impact. | Must | Finzo |
| FR-017 | Set a budget amount for a category and a period, and show spending against it. | Must | Monevro |
| FR-018 | Use one primary currency for entry, balances, budgets, goals, and reports. | Must | Monevro |
| FR-019 | Delete the receipt image and the voice recording when the user confirms or cancels the capture flow. | Must | Monevro |
| FR-020 | Let the user create an account with email and password or with Google. Allow full local use without an account. Require an account for backup, restore, and Premium. | Must | Monevro |
| FR-021 | When an account is deleted, delete that user’s cloud backup, profile data, and stored files. | Must | Monevro |
| FR-022 | Warn about a possible duplicate transaction. Do not delete or merge it unless the user asks. | Should | Finzo |
| FR-023 | Forecast cash flow until the next salary date and label the result as an estimate. | Should | Finzo |
| FR-024 | Link a category budget to a savings goal and show progress without double-counting in Safe-to-Spend. | Should | Monevro |
| FR-025 | Notify the user near a budget limit, at a goal milestone, and when an obligation is due. | Should | Monevro |
| FR-026 | Keep an in-app list of those notifications. | Should | Monevro |
| FR-027 | Attach an optional recipient to a transaction. | Should | Monevro |
| FR-028 | Offer optional fingerprint or face unlock on the device. | Should | Monevro |
| FR-029 | Draft a financial plan from recorded spending. Present it as advice. Do not post transactions from it. | Should | Monevro |
| FR-030 | Enforce a free AI quota and a higher Premium quota. Premium removes ads and restores with the account on another device. | Should | Monevro |
| FR-031 | Simulate the effect of a hypothetical decision without changing the ledger. | Could | Finzo |
| FR-032 | Support additional currencies and a stated exchange-rate rule. | Could | Open in Finzo |

## 10. Business Rules

### BR-001 — Local-first

A transaction is saved on the device first. Recording, budgets, goals, and reports do not require a network.

### BR-002 — Account balance

Opening balance + income + incoming transfers − expenses − outgoing transfers, under the date and status rules. A budget does not change this balance.

### BR-003 — Internal transfers

A transfer links a source account and a destination account. It is not income and it is not an expense in the user’s overall position.

### BR-004 — Safe-to-Spend

Start from the balances that are safe to include. Subtract obligations, planned savings, and reserves once each. Explain any excluded or uncertain amount. A budget linked to a goal must not be subtracted a second time.

### BR-005 — Human review

An amount, date, account, category, or merchant that comes from an image, voice, or model is a draft until the user confirms it.

### BR-006 — No real movement of money

The application records information. It does not pay, collect, or transfer money.

### BR-007 — Sensitive credentials

Do not store bank passwords, PINs, CVVs, or bank login secrets. The app account password is handled by the authentication provider, not in the ledger.

### BR-008 — Restore safety

Validate the backup, show what will be replaced, and restore only after confirmation. Do not merge two ledgers by guessing.

### BR-009 — The ledger is authoritative

Balances, budget results, goal progress, and Safe-to-Spend are computed by the ledger. AI may extract, suggest, classify, explain, or draft a plan.

### BR-010 — Category budget

A budget is a limit for one category over a defined period. Spending in that category during the period is compared with the limit. Subcategory spending rolls up to the parent category.

### BR-011 — Capture media

After the user confirms or cancels a capture, the image file and the audio file are deleted from the device and are not uploaded as a kept copy.

### BR-012 — Account boundary

With no account, the ledger stays on that device. Backup, restore, Premium, and cloud deletion apply only to a signed-in user. Signing out does not delete the local ledger.

### BR-013 — Plans and forecasts are labeled

A forecast, a simulation, and an assistant plan are estimates. The screen says so, and none of them rewrite posted transactions.

### BR-014 — Quotas

Cloud AI calls count against the active plan. When the quota is spent, capture still opens the review screen so the user can finish the entry by hand. Local rules keep working.

### BR-015 — Alerts

An alert informs. It does not recategorize, block a transaction, or change a goal.

## 11. Non-Functional Requirements

| ID | Name | Requirement |
|---|---|---|
| NFR-001 | Offline operation | Account, transaction, budget, goal, and report functions work without a network. Cloud AI, backup, and purchase refresh wait for a connection. |
| NFR-002 | Data integrity | Balances, transfer links, budget totals, and goal progress stay consistent after every save. |
| NFR-003 | Privacy | Send only the fields a cloud call needs. Say when a call leaves the device. Do not keep receipt images or voice recordings after the flow ends. |
| NFR-004 | Backup protection | Protect backup data in transit and at rest. |
| NFR-005 | Compatibility | Support the Android and iOS versions chosen in implementation planning. |
| NFR-006 | Usability | Keep entry short. Mark fields that need review. Keep charts readable in Arabic and English. |
| NFR-007 | AI cost control | Prefer local rules. Count cloud calls. Fall back to another provider, then to manual entry. |
| NFR-008 | Provider flexibility | Keep ledger rules independent of a single AI vendor, a single billing vendor, and a single ad vendor. |
| NFR-009 | Restore verification | Validate restored data and report the result. |
| NFR-010 | App lock | The biometric lock stays on the device. A failed unlock does not send biometric data to the server. |
| NFR-011 | Account deletion | Cloud deletion finishes or reports failure. The user is told what remains. |
| NFR-012 | Subscription identity | The subscription follows the same account across devices and after a reinstall. |

## 12. Initial Data Requirements

These are analysis entities, not a schema. Relationships, constraints, indexes, and integrity rules belong in the database design.

| Entity | Contents |
|---|---|
| Accounts | Name, type, institution or phone number when relevant, opening balance, currency. |
| Transactions | Type, amount, date, account links, category, optional recipient, merchant, status. |
| Categories | Category, subcategory, and the parent used for budget rollup. |
| Budgets | Category, period, limit amount, amount spent, link to a goal when set. |
| Recurring Obligations | Name, amount, due rule, next due date. |
| Savings Goals | Name, target, progress, optional linked budget. |
| Recipients | Display name and optional note. |
| Capture Drafts | Proposed fields and review status. The media file is not a stored entity after the flow ends. |
| AI Rules & Feedback | Local categorization rules and optional user corrections. |
| Plans | Advisory text, the period it describes, and the label that it is not a posted transaction. |
| Notifications | Kind, subject, time, and read status. |
| Backup Metadata | Version, time, status, and the account it belongs to. |
| Entitlements | Plan, quota window, quota used, and subscription status. |

## 13. Acceptance Criteria

- **AC-001:** Each account balance equals its opening balance plus the posted transactions under the balance rule.
- **AC-002:** An internal transfer updates both accounts and leaves the user’s total position unchanged.
- **AC-003:** The user can record a transaction, edit a budget, and open reports while offline.
- **AC-004:** Receipt and voice drafts stay unsaved until the user confirms them.
- **AC-005:** Reports include the transactions in the selected range and can be read by category, period, and budget.
- **AC-006:** Safe-to-Spend lists what was included, what was excluded, and does not subtract a linked budget twice.
- **AC-007:** Backup and restore succeed for the signed-in user, and the restored ledger is validated.
- **AC-008:** A possible duplicate raises a warning and stays in the ledger until the user decides.
- **AC-009:** Service secrets are not embedded insecurely in the client.
- **AC-010:** The financial core is tested on Android and iOS before release.
- **AC-011:** A category budget shows the limit and the spending in that period, including subcategory rollup.
- **AC-012:** Confirming or cancelling capture removes the image and the audio from the device.
- **AC-013:** A user with no account can keep a local ledger and cannot upload a backup.
- **AC-014:** Deleting the account removes that user’s cloud backup and stored files, and the app reports the outcome.
- **AC-015:** A budget-threshold, goal-milestone, or obligation-due alert is visible in the in-app list.
- **AC-016:** After the free quota is spent, cloud extraction stops and manual completion still works.
- **AC-017:** Premium on one device is available on another device for the same account after restore.
- **AC-018:** An assistant plan and a cash-flow forecast are marked as estimates and do not change balances.

## 14. Main User Scenarios

### Add an account

1. The user chooses bank, e-wallet, or cash.
2. The user enters a name and, where it matters, an institution or phone number.
3. The user enters the opening balance in the primary currency.
4. The app saves the account on the device and shows it.

### Record an expense manually

1. The user opens entry.
2. The user sets account, amount, date, and category, and may set a recipient.
3. The user confirms.
4. The app updates the account balance, the category budget, and reports.

### Record an expense from a receipt

1. The user takes or chooses a photo.
2. The app proposes merchant, amount, date, and category.
3. The user edits the draft and confirms.
4. The app saves the transaction locally and deletes the image.

### Record a transaction by voice

1. The user speaks the transaction.
2. The app turns speech into text and proposed fields.
3. The user reviews the draft and confirms.
4. The app saves the transaction and deletes the recording.

### Transfer between accounts

1. The user picks the source and the destination.
2. The user enters the amount and the date.
3. The app posts one linked transfer.
4. Both balances change. Totals, budgets, and income reports treat it as neither income nor expense.

### Set a category budget and a goal

1. The user sets a limit and a period on a category.
2. The user sets a savings-goal target.
3. The user may link that budget to that goal.
4. Spending updates the budget. Progress toward the goal updates once. Safe-to-Spend uses that amount once.

### Back up

1. The user signs in, if they have not.
2. The user chooses Back up now.
3. The app uploads the backup and reports success or failure.

### Restore

1. The user signs in and chooses a backup.
2. The app validates it and describes the impact.
3. The user confirms.
4. The app replaces the local ledger and reports the result.

### Delete the cloud account

1. The user asks to delete the account.
2. The app states that the cloud backup and stored files will be removed and that the local ledger remains until the user erases it.
3. The user confirms.
4. The app deletes the cloud data and reports what finished.

## 15. Indicative Implementation Roadmap

Estimates are for one full-time developer. Must is the first release. Should is the next release. Could waits for a product decision.

| Phase | Work | Duration |
|---|---|---|
| A | Requirements, UX, ledger rules, budget rules | 1–2 weeks |
| B | Accounts, transactions, categories, transfers, currency, reports, charts, tests | Weeks 3–8 |
| C | Receipt and voice capture, review, media deletion, local categorization | Weeks 9–13 |
| D | Safe-to-Spend, obligations, goals, category budgets | Weeks 14–18 |
| E | Account, backup, restore, cloud deletion | Weeks 19–23 |
| F | Android and iOS test, polish, first release | Weeks 24–28 |
| G | Alerts, recipients, app lock, assistant, quotas, subscriptions | Following release, about 8–12 weeks |
| H | Duplicate warning, salary-date forecast | With phase G or immediately after |
| I | Decision simulation, extra currencies | After a product decision |

## 16. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| The merged Must set is larger than the original 15-item MVP | Ship Must only in the first release. Hold FR-022 through FR-030 for the following release. |
| AI cost grows with capture and the assistant | Local rules first, plan quotas, and a hard stop that still allows manual entry. |
| Receipt or voice drafts are wrong | Review is required. Uncertain fields are marked. Media is deleted either way. |
| Forecasts or plans are read as facts | Label them as estimates. Keep them out of the ledger. |
| The device is lost | Signed-in backup, a tested restore, and a clear restore impact. |
| Two devices diverge | The first release restores a whole backup. It does not live-merge two ledgers. |
| A subscription is lost on a new phone | Bind Premium to the account and support restore. |
| Privacy of receipts and voice | Delete media at the end of the flow. Keep capture payloads minimal. |
| Account deletion leaves cloud copies | FR-021 and NFR-011. Report any object that could not be removed. |

## 17. Decisions still open

- The minimum Android and iOS versions.
- The budget threshold and the goal milestones that fire an alert (for example 80 percent and 100 percent).
- Which obligation schedules are in the first release (weekly, monthly, custom).
- Whether free-plan ads are included in the first release or only when Premium ships.
- The numeric free quota and Premium quota.
- Which authentication, billing, and AI providers meet the cost, privacy, and replaceability rules.
- How Safe-to-Spend treats pending transactions, overdue obligations, and cash the user marks as a reserve.
- Whether restore always replaces the local ledger, or first keeps a recovery copy on the device.

## 18. Recommended Next Steps

1. Review section 00 and accept or edit the merge choices.
2. Freeze the Must list for the first release.
3. Update the database design for budgets, recipients, notifications, and entitlements.
4. Rebuild the implementation backlog from this document.
5. Start phase A only after the ledger and Safe-to-Spend rules are agreed.

**Document note.** This draft merges the two public product positions. It is not an implementation specification and it does not replace `brd/brd.md` until the product owner accepts it.

---

*Finzo Manager · Merged Product BRD · Version 1.0*

---

# النسخة العربية

نفس الوثيقة باللغة العربية.

| | |
|---|---|
| الإصدار | 1.0 |
| الحالة | مسودة للمراجعة |
| المنصات | Android + iOS |
| المصادر | `brd/brd.md` ووصف Monevro العلني في [منشور محمد حمدي](https://www.linkedin.com/feed/update/urn:li:activity:7511850211976327168/) |

| المتطلبات الوظيفية | إصدار Must | مدة التنفيذ المقدرة |
|---|---|---|
| 32 (21 أساسي، 9 مهم، 2 اختياري) | 21 متطلباً | 20–28 أسبوعاً لمتطلبات Must لمطور واحد. متطلبات Should في إصدار تالٍ. |

## 00. قرارات الدمج

| الموضوع | القرار في هذه الوثيقة | المصدر |
|---|---|---|
| مصدر الحقيقة | قاعدة الجهاز هي المصدر التشغيلي. Firebase يحتفظ بنسخة المستخدم المسجّل وبيانات حسابه. | Finzo، مع هوية Monevro السحابية |
| العمل دون اتصال | الحسابات والعمليات والميزانيات والأهداف والتقارير تعمل بلا شبكة. | Finzo |
| الالتقاط | صورة الإيصال والصوت ينتجان مسودة. المستخدم يراجعها قبل الحفظ. | صوت Finzo ومراجعته؛ حقول إيصال Monevro |
| وسائط الالتقاط | تُحذف صورة الإيصال والتسجيل الصوتي عند التأكيد أو الإلغاء. | Monevro |
| التصنيفات | تصنيفات وتصنيفات فرعية وميزانية لكل تصنيف. | التصنيفات الفرعية من Finzo؛ الميزانيات من Monevro |
| الأهداف | أهداف ادخار مع تقدم. يمكن ربط ميزانية تصنيف بهدف. | الاثنان، والربط من Monevro |
| الالتزامات | الالتزامات المتكررة مستقلة عن الميزانيات. | Finzo |
| Safe-to-Spend | يُعرض مع شرح بعد الالتزامات والادخار والاحتياطي بلا احتساب مزدوج. | Finzo |
| التنبيهات | قرب نفاد الميزانية، ومحطة في الهدف، واستحقاق التزام. | Monevro مع التزامات Finzo |
| دور الذكاء الاصطناعي | قواعد محلية أولاً. السحابة تستخرج وتقترح وتشرح وتضع خطة. الرصيد يحسبه دفتر الحسابات. | قاعدة Finzo؛ مساعد التخطيط من Monevro |
| الوصول إلى الذكاء الاصطناعي | حصة للمجاني وحصة أعلى لـ Premium، مع مزود بديل وإمكانية استبدال المزود. | حصص Monevro؛ مرونة Finzo |
| الهوية | الاستخدام المحلي بلا حساب. البريد أو Google والنسخ وPremium تحتاج حساباً. | حساب Monevro؛ النواة دون اتصال من Finzo |
| قفل التطبيق | فتح اختياري بالبصمة أو الوجه على الجهاز. | Monevro |
| نموذج المال | حسابات متعددة وأرصدة افتتاحية وتحويلات داخلية. | Finzo |
| المستلمون | يمكن ربط عملية بمستلم. | Monevro |
| العملة | عملة أساسية واحدة في الإصدار الأول. | إعداد Monevro؛ تعدد العملات يبقى اختيارياً كما في Finzo |
| التقارير | لوحة ورسوم لأسبوع أو شهر أو فترة، حسب التصنيف والفترة والميزانية. | الاثنان |
| اللغات | العربية والإنجليزية مع RTL، وقراءة إيصالات عربية. | الاثنان |
| المنصات | Android وiOS من الإصدار الأول. | Finzo |
| التسعير | المجاني يشمل النواة والالتقاط ضمن الحصة والميزانيات والأهداف. Premium يرفع حصة الذكاء الاصطناعي ويزيل الإعلانات. | Monevro |

## 01. الملخص التنفيذي

Finzo Manager تطبيق للمال الشخصي على Android وiOS. يحتفظ المستخدم بعدة حسابات، ويسجل الدخل والمصروف والتحويل الداخلي، ويرى Safe-to-Spend بعد الالتزامات والادخار والاحتياطي. صورة الإيصال أو الصوت تملأ مسودة، ولا تُحفظ قبل تأكيد المستخدم. ميزانية التصنيف وهدف الادخار والتنبيه يبيّنون هل الصرف والادخار يسيران كما خُطط. المساعد يشرح الوضع ويقترح خطة من العادات المسجلة، ولا يرحّل عملية ولا يغيّر رصيداً.

قاعدة الهاتف هي نسخة العمل. المستخدم المسجّل يستطيع نسخها إلى Firebase واستعادتها. تُحذف صور الإيصالات والتسجيلات الصوتية عند انتهاء مسار الالتقاط.

## 02. الأهداف ورؤية المنتج

- تقديم صورة موثوقة عن المال عبر الحسابات.
- تقليل الإدخال عبر الإيصال والصوت، مع إبقاء التأكيد بيد المستخدم.
- عرض Safe-to-Spend بعد الالتزامات والادخار المخطط والاحتياطي.
- السماح بميزانية لكل تصنيف وهدف ادخار وربط بينهما.
- التنبيه قبل نفاد الميزانية وعند محطة الهدف وعند استحقاق الالتزام.
- استخدام الذكاء الاصطناعي للقراءة والتصنيف والشرح ووضع الخطط، والدفتر لكل رصيد.
- إبقاء النواة المالية متاحة دون اتصال.
- ربط النسخ والاستعادة وPremium بحساب يستطيع المستخدم حذفه مع بياناته السحابية.
- خطة مجانية مفيدة، وخطة Premium بحصة ذكاء اصطناعي أعلى وبلا إعلانات.

## 03. أصحاب المصلحة

| صاحب المصلحة | الدور |
|---|---|
| المستخدم | يسجل العمليات ويدير الحسابات والميزانيات والالتزامات والأهداف، وقد يشترك. |
| مالك المنتج | يحدد النطاق والأولويات والسعر وقواعد العمل. |
| المطور | ينفذ ويختبر ويصدر. التقدير لمطور واحد بدوام كامل. |

## 04. المنصات واستراتيجية المنتج

- تطبيق Flutter واحد لـ Android وiOS.
- دفتر محلي أولاً. النسخ السحابي والهوية والاشتراك بجانبه.
- ذكاء اصطناعي هجين: قواعد الجهاز ثم نموذج سحابي عند الحاجة، ثم مزود بديل. الحصص تختلف حسب الخطة.
- النسخ والاستعادة في الإصدار الأول للمستخدم المسجّل.
- العربية والإنجليزية مع RTL.
- مجاني وPremium. Premium اشتراك شهري أو سنوي ويُستعاد على جهاز آخر لنفس الحساب. الإعلانات، إن وُجدت، تبقى خارج شاشات الإدخال والمراجعة وSafe-to-Spend.

## 05. نطاق MVP — Must

- حسابات متعددة: بنك ومحفظة ونقد، لكل منها رصيد افتتاحي.
- دخل ومصروف وتحويل داخلي.
- تصنيفات وتصنيفات فرعية وميزانية لكل تصنيف لفترة.
- عملة أساسية واحدة.
- إدخال يدوي.
- التقاط إيصال يقترح التاجر والمبلغ والتاريخ والتصنيف، بما فيه الإيصالات العربية.
- التقاط صوتي يقترح الحقول نفسها.
- شاشة مراجعة. لا تُحفظ عملية مستخرجة قبل التأكيد.
- حذف صورة الإيصال والتسجيل عند انتهاء المسار.
- اقتراح التصنيف محلياً ثم بالذكاء الاصطناعي عند ضعف الثقة.
- لوحة ورسوم وتقارير لأسبوع أو شهر أو فترة، حسب التصنيف والفترة والميزانية.
- التزامات متكررة وأهداف ادخار مع التقدم.
- Safe-to-Spend مع شرح قصير.
- تخزين محلي وعمل النواة دون اتصال.
- حساب اختياري بالبريد أو Google. النسخ والاستعادة وPremium تتطلب حساباً.
- نسخ واستعادة عبر Firebase مع التحقق وشرح الأثر.
- حذف النسخة السحابية وملفات المستخدم عند حذف الحساب.

## 06. الإصدار التالي — Should

- تنبيه تكرار بلا حذف أو دمج تلقائي.
- توقع التدفق حتى الراتب التالي مع وسمه كتقدير.
- ربط ميزانية تصنيف بهدف بلا احتساب مزدوج في Safe-to-Spend.
- تنبيهات حد الميزانية ومحطة الهدف واستحقاق الالتزام، مع قائمة داخل التطبيق.
- مستلم اختياري على العملية.
- قفل اختياري بالبصمة أو الوجه.
- مساعد يضع خطة من الصرف المسجل ويسمها نصيحة ولا يرحّل منها عمليات.
- استحقاقات المجاني وPremium وحصص الذكاء الاصطناعي وإزالة الإعلانات واستعادة الاشتراك.

## 07. Could

- محاكاة قرار افتراضي منفصلة عن الأرصدة الفعلية.
- أكثر من عملة مع قاعدة سعر صرف صريحة.

## 08. خارج النطاق

- تنفيذ مدفوعات أو تحويلات بنكية أو Instapay.
- ربط بنكي ينفّذ عملية أو يقرأ رصيداً حياً.
- قراءة رسائل البنك أو إشعاراته.
- جعل قاعدة السحابة دفتر العمل الحي.
- تدريب نموذج خاص من الصفر.
- إدارة الاستثمارات أو التوصية بها.
- محاسبة تجارية أو دفاتر مشتركة.
- السماح للنموذج بكتابة رصيد أو نتيجة ميزانية أو Safe-to-Spend.

## 09. المتطلبات الوظيفية

| المعرف | المتطلب | الأولوية | الأصل |
|---|---|---|---|
| FR-001 | إدارة عدة حسابات. | Must | Finzo |
| FR-002 | دعم البنك والمحفظة والنقد. | Must | Finzo |
| FR-003 | رصيد افتتاحي لكل حساب. | Must | Finzo |
| FR-004 | تسجيل الدخل والمصروف والتحويل الداخلي. | Must | Finzo |
| FR-005 | إدارة التصنيفات والتصنيفات الفرعية. | Must | Finzo |
| FR-006 | إدخال عملية يدوياً. | Must | الاثنان |
| FR-007 | من صورة إيصال: اقتراح التاجر والمبلغ والتاريخ والتصنيف، مع دعم العربية. | Must | الاثنان |
| FR-008 | من الصوت: اقتراح حقول العملية نفسها. | Must | Finzo |
| FR-009 | مراجعة وتعديل قبل حفظ العملية المستخرجة. | Must | Finzo |
| FR-010 | اقتراح التصنيف بالقواعد والسجل، ثم بالذكاء الاصطناعي عند انخفاض الثقة. | Must | Finzo |
| FR-011 | لوحة ورسوم وتقارير لأسبوع أو شهر أو فترة، حسب التصنيف والفترة والميزانية. | Must | الاثنان |
| FR-012 | إدارة الالتزامات المتكررة ومواعيد استحقاقها. | Must | Finzo |
| FR-013 | إدارة أهداف الادخار وإظهار التقدم. | Must | الاثنان |
| FR-014 | حساب Safe-to-Spend وشرح المبالغ الداخلة والمستبعدة. | Must | Finzo |
| FR-015 | دفتر محلي وعمل النواة دون اتصال. | Must | Finzo |
| FR-016 | نسخ واستعادة عبر Firebase للمستخدم المسجّل، مع التحقق وشرح الأثر. | Must | Finzo |
| FR-017 | ميزانية لتصنيف وفترة، وإظهار الصرف مقابلها. | Must | Monevro |
| FR-018 | عملة أساسية واحدة للإدخال والأرصدة والميزانيات والأهداف والتقارير. | Must | Monevro |
| FR-019 | حذف صورة الإيصال والتسجيل عند التأكيد أو الإلغاء. | Must | Monevro |
| FR-020 | حساب بالبريد أو Google. استخدام محلي كامل بلا حساب. الحساب لازم للنسخ والاستعادة وPremium. | Must | Monevro |
| FR-021 | عند حذف الحساب تُحذف نسخته السحابية وبيانات ملفه وملفاته المخزنة. | Must | Monevro |
| FR-022 | التحذير من تكرار محتمل بلا حذف أو دمج إلا بطلب المستخدم. | Should | Finzo |
| FR-023 | توقع التدفق حتى الراتب التالي ووسمه كتقدير. | Should | Finzo |
| FR-024 | ربط ميزانية تصنيف بهدف ادخار بلا احتساب مزدوج. | Should | Monevro |
| FR-025 | التنبيه قرب حد الميزانية وعند محطة الهدف وعند استحقاق الالتزام. | Should | Monevro |
| FR-026 | قائمة داخل التطبيق بهذه التنبيهات. | Should | Monevro |
| FR-027 | مستلم اختياري على العملية. | Should | Monevro |
| FR-028 | فتح اختياري بالبصمة أو الوجه على الجهاز. | Should | Monevro |
| FR-029 | خطة مالية من الصرف المسجل، تُعرض كنصيحة، ولا تُرحّل منها عمليات. | Should | Monevro |
| FR-030 | حصة ذكاء اصطناعي للمجاني وحصة أعلى لـ Premium. Premium بلا إعلانات ويُستعاد مع الحساب. | Should | Monevro |
| FR-031 | محاكاة قرار افتراضي بلا تغيير الدفتر. | Could | Finzo |
| FR-032 | عملات إضافية وقاعدة سعر صرف. | Could | سؤال مفتوح في Finzo |

## 10. قواعد العمل

### BR-001 — المحلي أولاً

تُحفظ العملية على الجهاز أولاً. التسجيل والميزانيات والأهداف والتقارير لا تحتاج شبكة.

### BR-002 — رصيد الحساب

الرصيد الافتتاحي + الدخل + التحويلات الواردة − المصروفات − التحويلات الصادرة. الميزانية لا تغيّر هذا الرصيد.

### BR-003 — التحويل الداخلي

يربط التحويل حساب مصدر بحساب وجهة. ليس دخلاً ولا مصروفاً في إجمالي وضع المستخدم.

### BR-004 — Safe-to-Spend

يبدأ من الأرصدة التي يصح إدخالها. يطرح الالتزامات والادخار المخطط والاحتياطي مرة واحدة لكل بند. يشرح أي مبلغ مستبعد أو غير مؤكد. الميزانية المربوطة بهدف لا تُطرح مرة ثانية.

### BR-005 — مراجعة المستخدم

أي مبلغ أو تاريخ أو حساب أو تصنيف أو تاجر آتٍ من صورة أو صوت أو نموذج يبقى مسودة حتى يؤكد المستخدم.

### BR-006 — لا حركة مال حقيقية

التطبيق يسجل المعلومات. لا يدفع ولا يحصّل ولا يحوّل مالاً.

### BR-007 — بيانات الاعتماد

يُمنع تخزين كلمات مرور البنوك أو PIN أو CVV أو أسرار الدخول البنكي. كلمة حساب التطبيق يديرها مزود المصادقة لا الدفتر.

### BR-008 — أمان الاستعادة

التحقق من النسخة، وإظهار ما سيُستبدل، والاستعادة بعد التأكيد فقط. لا دمج دفترين بالتخمين.

### BR-009 — الدفتر هو المرجع

الأرصدة ونتائج الميزانية وتقدم الهدف وSafe-to-Spend يحسبها الدفتر. الذكاء الاصطناعي يستخرج أو يقترح أو يصنّف أو يشرح أو يضع خطة.

### BR-010 — ميزانية التصنيف

الميزانية حد لتصنيف واحد خلال فترة محددة. يُقارن صرف ذلك التصنيف في الفترة بالحد. صرف التصنيف الفرعي يُجمّع إلى التصنيف الأب.

### BR-011 — وسائط الالتقاط

بعد التأكيد أو الإلغاء يُحذف ملف الصورة وملف الصوت من الجهاز ولا يُرفع كنسخة محفوظة.

### BR-012 — حد الحساب

بلا حساب يبقى الدفتر على الجهاز. النسخ والاستعادة وPremium والحذف السحابي تخص المستخدم المسجّل فقط. تسجيل الخروج لا يحذف الدفتر المحلي.

### BR-013 — الخطط والتوقعات موسومة

التوقع والمحاكاة وخطة المساعد تقديرات. الشاشة تقول ذلك، ولا تعيد أي منها كتابة عملية مرحّلة.

### BR-014 — الحصص

نداءات الذكاء الاصطناعي السحابي تُحتسب على الخطة النشطة. عند نفاد الحصة تبقى شاشة المراجعة ليكمل المستخدم الإدخال يدوياً. القواعد المحلية تبقى تعمل.

### BR-015 — التنبيهات

التنبيه يُعلم. لا يعيد التصنيف ولا يمنع عملية ولا يغيّر هدفاً.

## 11. المتطلبات غير الوظيفية

| المعرف | الاسم | المتطلب |
|---|---|---|
| NFR-001 | العمل دون اتصال | الحسابات والعمليات والميزانيات والأهداف والتقارير تعمل بلا شبكة. الذكاء الاصطناعي السحابي والنسخ وتحديث الشراء ينتظران الاتصال. |
| NFR-002 | سلامة البيانات | تتسق الأرصدة وروابط التحويل ومجاميع الميزانية وتقدم الأهداف بعد كل حفظ. |
| NFR-003 | الخصوصية | لا يُرسل إلا ما يحتاجه النداء السحابي. يُوضَّح متى يغادر النداء الجهاز. لا تُحفظ صور الإيصالات ولا التسجيلات بعد انتهاء المسار. |
| NFR-004 | حماية النسخ | حماية النسخة أثناء النقل والتخزين. |
| NFR-005 | التوافق | دعم إصدارات Android وiOS التي تُحدد في التخطيط. |
| NFR-006 | سهولة الاستخدام | إدخال قصير. تمييز الحقول التي تحتاج مراجعة. رسوم مقروءة بالعربية والإنجليزية. |
| NFR-007 | تكلفة الذكاء الاصطناعي | القواعد المحلية أولاً. عدّ النداءات السحابية. التحويل إلى مزود آخر ثم إلى الإدخال اليدوي. |
| NFR-008 | مرونة المزود | إبقاء قواعد الدفتر مستقلة عن بائع ذكاء اصطناعي واحد أو فوترة واحدة أو إعلانات واحدة. |
| NFR-009 | التحقق من الاستعادة | التحقق من البيانات المستعادة وإبلاغ النتيجة. |
| NFR-010 | قفل التطبيق | القفل الحيوي يبقى على الجهاز. فشل الفتح لا يرسل بيانات حيوية إلى الخادم. |
| NFR-011 | حذف الحساب | يكتمل الحذف السحابي أو يُبلَّغ الفشل. يُخبر المستخدم بما تبقى. |
| NFR-012 | هوية الاشتراك | الاشتراك يتبع الحساب نفسه عبر الأجهزة وبعد إعادة التثبيت. |

## 12. متطلبات البيانات الأولية

كيانات تحليل لا مخططاً نهائياً. العلاقات والقيود والفهارس في تصميم قاعدة البيانات.

| الكيان | المحتوى |
|---|---|
| الحسابات | الاسم والنوع والجهة أو الهاتف عند الحاجة والرصيد الافتتاحي والعملة. |
| العمليات | النوع والمبلغ والتاريخ وربط الحسابات والتصنيف والمستلم الاختياري والتاجر والحالة. |
| التصنيفات | التصنيف والتصنيف الفرعي والأب المستخدم لتجميع الميزانية. |
| الميزانيات | التصنيف والفترة والحد والمصروف والربط بهدف عند وجوده. |
| الالتزامات | الاسم والمبلغ وقاعدة الاستحقاق وموعد الاستحقاق التالي. |
| أهداف الادخار | الاسم والهدف والتقدم والميزانية المربوطة اختيارياً. |
| المستلمون | الاسم الظاهر وملاحظة اختيارية. |
| مسودات الالتقاط | الحقول المقترحة وحالة المراجعة. ملف الوسائط ليس كياناً مخزناً بعد انتهاء المسار. |
| قواعد الذكاء الاصطناعي | قواعد التصنيف المحلية وتصحيحات المستخدم الاختيارية. |
| الخطط | نص استشاري والفترة التي يصفها ووسم أنه ليس عملية مرحّلة. |
| التنبيهات | النوع والموضوع والوقت وحالة القراءة. |
| بيانات النسخ | الإصدار والوقت والحالة والحساب الذي تتبعه. |
| الاستحقاقات | الخطة ونافذة الحصة والمستخدم منها وحالة الاشتراك. |

## 13. معايير القبول

- **AC-001:** رصيد كل حساب يساوي رصيده الافتتاحي زائد العمليات المرحّلة وفق قاعدة الرصيد.
- **AC-002:** التحويل الداخلي يحدّث الحسابين ولا يغيّر إجمالي وضع المستخدم.
- **AC-003:** يستطيع المستخدم تسجيل عملية وتعديل ميزانية وفتح التقارير دون اتصال.
- **AC-004:** مسودات الإيصال والصوت لا تُحفظ قبل التأكيد.
- **AC-005:** التقارير تضم عمليات الفترة ويمكن قراءتها حسب التصنيف والفترة والميزانية.
- **AC-006:** يوضح Safe-to-Spend ما دُخل وما استُبعد ولا يطرح الميزانية المربوطة مرتين.
- **AC-007:** ينجح النسخ والاستعادة للمستخدم المسجّل ويُتحقق من الدفتر المستعاد.
- **AC-008:** التكرار المحتمل يصدر تحذيراً ويبقى في الدفتر حتى يقرر المستخدم.
- **AC-009:** لا تُغرس أسرار الخدمات في العميل بصورة غير آمنة.
- **AC-010:** تُختبر النواة المالية على Android وiOS قبل الإصدار.
- **AC-011:** تعرض ميزانية التصنيف الحد والصرف في الفترة، بما فيه تجميع التصنيفات الفرعية.
- **AC-012:** تأكيد الالتقاط أو إلغاؤه يزيل الصورة والصوت من الجهاز.
- **AC-013:** المستخدم بلا حساب يحتفظ بدفتر محلي ولا يستطيع رفع نسخة.
- **AC-014:** حذف الحساب يزيل النسخة السحابية والملفات المخزنة ويبلّغ التطبيق بالنتيجة.
- **AC-015:** تنبيه حد الميزانية أو محطة الهدف أو استحقاق الالتزام يظهر في القائمة داخل التطبيق.
- **AC-016:** بعد نفاد حصة المجاني يتوقف الاستخراج السحابي ويبقى الإكمال اليدوي.
- **AC-017:** Premium على جهاز يتاح على جهاز آخر لنفس الحساب بعد الاستعادة.
- **AC-018:** خطة المساعد وتوقع التدفق موسومان كتقدير ولا يغيّران الأرصدة.

## 14. سيناريوهات الاستخدام

### إضافة حساب

1. يختار المستخدم بنكاً أو محفظة أو نقداً.
2. يدخل الاسم، والجهة أو الهاتف عند الحاجة.
3. يدخل الرصيد الافتتاحي بالعملة الأساسية.
4. يحفظ التطبيق الحساب على الجهاز ويعرضه.

### تسجيل مصروف يدوياً

1. يفتح المستخدم الإدخال.
2. يحدد الحساب والمبلغ والتاريخ والتصنيف، ويمكنه تحديد مستلم.
3. يؤكد.
4. يحدّث التطبيق رصيد الحساب وميزانية التصنيف والتقارير.

### تسجيل مصروف من إيصال

1. يلتقط المستخدم صورة أو يختارها.
2. يقترح التطبيق التاجر والمبلغ والتاريخ والتصنيف.
3. يعدل المستخدم المسودة ويؤكد.
4. يحفظ التطبيق العملية محلياً ويحذف الصورة.

### تسجيل عملية بالصوت

1. ينطق المستخدم العملية.
2. يحوّل التطبيق الكلام إلى نص وحقول مقترحة.
3. يراجع المستخدم المسودة ويؤكد.
4. يحفظ التطبيق العملية ويحذف التسجيل.

### التحويل بين الحسابات

1. يختار المستخدم المصدر والوجهة.
2. يدخل المبلغ والتاريخ.
3. يرحّل التطبيق تحويلاً واحداً مرتبطاً.
4. يتغير الرصيدان. الإجماليات والميزانيات وتقارير الدخل لا تعدّه دخلاً ولا مصروفاً.

### ميزانية تصنيف وهدف

1. يضع المستخدم حداً وفترة على تصنيف.
2. يضع هدف ادخار.
3. يمكنه ربط تلك الميزانية بذلك الهدف.
4. الصرف يحدّث الميزانية. التقدم نحو الهدف يُحدَّث مرة واحدة. Safe-to-Spend يستخدم المبلغ مرة واحدة.

### النسخ الاحتياطي

1. يسجّل المستخدم الدخول إن لم يكن قد فعل.
2. يختار «نسخ احتياطي الآن».
3. يرفع التطبيق النسخة ويبلّغ بالنتيجة.

### الاستعادة

1. يسجّل المستخدم الدخول ويختار نسخة.
2. يتحقق التطبيق منها ويشرح الأثر.
3. يؤكد المستخدم.
4. يستبدل التطبيق الدفتر المحلي ويبلّغ بالنتيجة.

### حذف الحساب السحابي

1. يطلب المستخدم حذف الحساب.
2. يوضح التطبيق أن النسخة السحابية والملفات ستُزال وأن الدفتر المحلي يبقى حتى يمسحه المستخدم.
3. يؤكد المستخدم.
4. يحذف التطبيق البيانات السحابية ويبلّغ بما اكتمل.

## 15. خطة التنفيذ التقديرية

التقدير لمطور واحد بدوام كامل. Must هو الإصدار الأول. Should هو الإصدار التالي. Could ينتظر قرار المنتج.

| المرحلة | العمل | المدة |
|---|---|---|
| A | المتطلبات وتجربة الاستخدام وقواعد الدفتر والميزانية | 1–2 أسبوع |
| B | الحسابات والعمليات والتصنيفات والتحويلات والعملة والتقارير والرسوم والاختبارات | الأسبوع 3–8 |
| C | التقاط الإيصال والصوت والمراجعة وحذف الوسائط والتصنيف المحلي | الأسبوع 9–13 |
| D | Safe-to-Spend والالتزامات والأهداف وميزانيات التصنيف | الأسبوع 14–18 |
| E | الحساب والنسخ والاستعادة والحذف السحابي | الأسبوع 19–23 |
| F | اختبار Android وiOS والتحسين والإصدار الأول | الأسبوع 24–28 |
| G | التنبيهات والمستلمون وقفل التطبيق والمساعد والحصص والاشتراكات | إصدار تالٍ، نحو 8–12 أسبوعاً |
| H | تنبيه التكرار وتوقع موعد الراتب | مع المرحلة G أو بعدها مباشرة |
| I | محاكاة القرار والعملات الإضافية | بعد قرار المنتج |

## 16. المخاطر وطرق المعالجة

| الخطر | المعالجة |
|---|---|
| مجموعة Must أكبر من MVP الأصلي ذي 15 بنداً | إصدار Must فقط أولاً. إبقاء FR-022 إلى FR-030 للإصدار التالي. |
| ارتفاع تكلفة الذكاء الاصطناعي | القواعد المحلية أولاً، وحصص الخطط، وتوقف لا يمنع الإدخال اليدوي. |
| خطأ مسودات الإيصال أو الصوت | المراجعة إلزامية. تُميَّز الحقول غير المؤكدة. تُحذف الوسائط في الحالتين. |
| قراءة التوقع أو الخطة كحقيقة | وسمها كتقدير وإبقاؤها خارج الدفتر. |
| ضياع الجهاز | نسخ للمستخدم المسجّل واستعادة مُختبرة وشرح واضح للأثر. |
| اختلاف جهازين | الإصدار الأول يستعيد نسخة كاملة. لا يدمج دفترين بشكل حي. |
| ضياع الاشتراك على هاتف جديد | ربط Premium بالحساب ودعم الاستعادة. |
| خصوصية الإيصالات والصوت | حذف الوسائط عند انتهاء المسار. إبقاء حمولة الالتقاط في أدناها. |
| بقاء نسخ سحابية بعد حذف الحساب | FR-021 وNFR-011. الإبلاغ عن أي ملف تعذّر حذفه. |

## 17. قرارات ما زالت مفتوحة

- أقل إصدارات Android وiOS.
- حد الميزانية ومحطات الهدف التي تُطلق التنبيه.
- جداول الالتزامات في الإصدار الأول.
- هل تدخل إعلانات الخطة المجانية في الإصدار الأول أم مع إطلاق Premium فقط.
- الأرقام الفعلية لحصة المجاني وحصة Premium.
- مزودو المصادقة والفوترة والذكاء الاصطناعي الذين يحققون التكلفة والخصوصية وإمكانية الاستبدال.
- كيف يعامل Safe-to-Spend العمليات المعلقة والالتزامات المتأخرة والنقد الذي يعلّمه المستخدم احتياطياً.
- هل الاستعادة تستبدل الدفتر المحلي دائماً أم تحتفظ أولاً بنسخة استرداد على الجهاز.

## 18. الخطوات التالية

1. مراجعة القسم 00 وقبول قرارات الدمج أو تعديلها.
2. تثبيت قائمة Must للإصدار الأول.
3. تحديث تصميم قاعدة البيانات للميزانيات والمستلمين والتنبيهات والاستحقاقات.
4. إعادة بناء قائمة التنفيذ من هذه الوثيقة.
5. بدء المرحلة A بعد الاتفاق على قواعد الدفتر وSafe-to-Spend.

**ملاحظة الوثيقة.** تدمج هذه المسودة موقف المنتجين العلني. ليست مواصفة تنفيذ ولا تستبدل `brd/brd.md` حتى يقبلها مالك المنتج.

*Finzo Manager · وثيقة المتطلبات المدمجة · الإصدار 1.0*
