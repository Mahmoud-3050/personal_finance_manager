# Finzo Manager

**Business Requirements Document** — product scope, business rules, requirements, acceptance criteria, and delivery roadmap.

| | |
|---|---|
| Version | 1.0 |
| Status | Draft for Review |
| Platforms | Android + iOS |
| Source | `brd.html` (English is the default language of that document) |

| Functional requirements | MVP priorities | Estimated delivery |
|---|---|---|
| 19 (Must, Should, and Could) | 15 core requirements | 14–20 weeks, one full-time developer |

---

## 01. Executive Summary

Finzo Manager is a personal finance management application for Android and iOS. It enables users to record income, expenses, and internal transfers; manage accounts, obligations, and savings goals; and use smart transaction capture from receipts and voice.

**Local-first principle.** The local database is the primary operational source of truth. Firebase is used for backup and restore. The app does not execute payments or real financial transfers.

## 02. Goals & Product Vision

- Provide a reliable, understandable view of personal finances.
- Reduce transaction-entry effort while keeping the user in control.
- Provide Safe-to-Spend after considering obligations, savings, and reserves.
- Use AI to interpret and explain information, not to perform core financial arithmetic.
- Keep core account and transaction management available offline.

## 03. Stakeholders & Users

| Stakeholder | Role |
|---|---|
| End User | Records transactions and manages accounts, obligations, and savings goals. |
| Product Owner | Defines scope, priorities, and business rules. |
| Developer | Implements, tests, and releases the product; initial plan assumes one developer. |

## 04. Platforms & Product Strategy

- Platforms: Android and iOS, using one shared application.
- Balanced MVP: dependable financial core plus smart transaction capture.
- Hybrid AI: local rules and user history, with cloud AI when needed.
- Backup is available from the first release, including backup-now and restore.
- Arabic and English, including RTL support for Arabic.

## 05. MVP Scope — In Scope

- Multiple accounts: bank accounts, e-wallets, and physical cash.
- Opening balance for each account.
- Income, expenses, and internal transfers.
- Categories and subcategories.
- Manual transaction entry.
- Preliminary transaction-data extraction from receipt photos.
- Voice-to-text and extraction of transaction fields.
- Review and edit screen before saving extracted information.
- Category suggestions using local rules and history, with cloud AI when needed.
- Dashboard and reports for a week, month, or selected date range.
- Basic recurring obligations and savings goals.
- Safe-to-Spend indicator with an explanation.
- Local storage and offline operation.
- Firebase backup and restore.
- Warnings for potentially duplicate transactions.

## 06. Out of Scope for MVP

- Executing payments, bank transfers, or Instapay transfers.
- Bank connectivity for executing transactions or directly reading balances.
- Automatic reading of bank SMS messages or notifications.
- Full real-time synchronization across multiple devices.
- Training a proprietary AI model from scratch.
- Investment management or investment recommendations.
- Business accounting or shared multi-user accounts.
- Advanced forecasting, decision simulation, and a comprehensive AI financial coach.

## 07. Functional Requirements

Priorities indicate what must be included in the MVP and what may be deferred.

| ID | Requirement | Priority |
|---|---|---|
| FR-001 | Manage multiple financial accounts. | Must |
| FR-002 | Support bank accounts, e-wallets, and physical cash. | Must |
| FR-003 | Set an opening balance for each account. | Must |
| FR-004 | Record income, expenses, and internal transfers. | Must |
| FR-005 | Manage categories and subcategories. | Must |
| FR-006 | Enter transactions manually. | Must |
| FR-007 | Extract preliminary transaction data from receipt images. | Must |
| FR-008 | Convert voice input into proposed transaction data. | Must |
| FR-009 | Review and edit extracted data before saving. | Must |
| FR-010 | Suggest categories using local rules and AI when needed. | Must |
| FR-011 | Show a dashboard and reports for a selected date range. | Must |
| FR-012 | Manage basic obligations and savings goals. | Must |
| FR-013 | Calculate Safe-to-Spend and explain the result. | Must |
| FR-014 | Store data locally and support offline operation. | Must |
| FR-015 | Support backup and restore through Firebase. | Must |
| FR-016 | Detect and warn about potentially duplicate transactions. | Should |
| FR-017 | Forecast cash flow until the next salary date. | Should |
| FR-018 | Simulate the potential impact of a hypothetical financial decision. | Could |
| FR-019 | Provide an AI financial assistant. | Could |

## 08. Business Rules

### BR-001 — Local-first

Transactions must be saved locally first. Recording must not require an external service connection.

### BR-002 — Account balance

Opening balance + income + incoming transfers − expenses − outgoing transfers, following defined date and status rules.

### BR-003 — Internal transfers

A transfer links source and destination accounts. It is not income or expense when calculating the user's overall money position.

### BR-004 — Safe-to-Spend

Show the starting balance and account for obligations, planned savings, and reserves without double-counting; explain excluded or uncertain balances.

### BR-005 — Human review

Any amount, date, account, or category extracted from image, voice, or AI must be reviewed before saving.

### BR-006 — No real transactions

The application records financial information only and does not execute payments or transfers.

### BR-007 — Sensitive credentials

Do not store bank passwords, PINs, CVVs, or bank login credentials.

### BR-008 — Restore safety

Validate backups and explain restore impact. Do not merge data arbitrarily.

### BR-009 — Accounting is authoritative

The accounting engine is the source of truth; AI extracts, suggests, classifies, or explains information but does not determine final balances.

## 09. Non-Functional Requirements

| ID | Name | Requirement |
|---|---|---|
| NFR-001 | Offline operation | Core account and transaction functions remain available without internet access. |
| NFR-002 | Data integrity | Account balances, transfer links, and transaction records remain consistent. |
| NFR-003 | Privacy | Minimize data sent to cloud services and explain when external services are used. |
| NFR-004 | Backup protection | Apply appropriate protection to backup data in transit and at rest. |
| NFR-005 | Compatibility | Support the Android and iOS versions selected during implementation planning. |
| NFR-006 | Usability | Minimize entry steps and clearly identify errors and fields requiring review. |
| NFR-007 | AI cost control | Prefer local rules, use cloud AI only when needed, and provide a fallback when unavailable. |
| NFR-008 | Provider flexibility | Avoid tightly coupling business logic to a single AI provider. |
| NFR-009 | Restore verification | Validate restored data and clearly report the result. |

## 10. Initial Data Requirements

These are preliminary business-analysis entities, not a finalized database schema. Relationships, constraints, indexes, and integrity rules belong in the separate Database Design document.

| Entity | Contents |
|---|---|
| Accounts | Account name, type, associated institution or phone number where relevant, and opening balance. |
| Transactions | Income, expenses, and transfers, including amount, date, account links, category, and status. |
| Categories | Categories and subcategories. |
| Recurring Obligations | Recurring obligations and due dates. |
| Savings Goals | Target amounts and progress. |
| Capture Records | Receipt or voice extraction records and review status. |
| AI Rules & Feedback | Categorization rules and optional user feedback. |
| Backup Metadata | Backup versions, timestamps, and status information. |

## 11. Acceptance Criteria

- **AC-001:** Each account balance matches its opening balance and recorded transactions under the defined rules.
- **AC-002:** An internal transfer updates both account balances without changing the user's total money position.
- **AC-003:** A user can record a transaction while offline.
- **AC-004:** Extracted receipt or voice data is not saved until reviewed and confirmed.
- **AC-005:** Reports consistently include transactions within the selected date range.
- **AC-006:** Safe-to-Spend explains which amounts were included or excluded.
- **AC-007:** Backup and restore succeed, and restored data is validated.
- **AC-008:** Potential duplicates trigger a warning without unauthorized automatic deletion or merging.
- **AC-009:** Service secret keys are not exposed insecurely inside the client application.
- **AC-010:** Core financial functions are tested on Android and iOS before release.

## 12. Main User Scenarios

### Add an account

1. The user chooses an account type.
2. The user enters an account name and, where relevant, the institution or associated phone number.
3. The user enters an opening balance.
4. The app saves the account locally and displays it.

### Record an expense manually

1. The user opens transaction entry.
2. The user selects an account, amount, date, and category.
3. The user confirms and saves the transaction.
4. The app updates the relevant balance and reports.

### Record an expense from a receipt

1. The user captures or selects a receipt image.
2. The app extracts possible transaction fields.
3. The app displays extracted data for review.
4. The user edits and confirms the data.
5. The app saves the transaction locally.

### Record a transaction by voice

1. The user speaks a transaction description.
2. The app converts speech into text and proposed fields.
3. The user reviews and edits the proposed data.
4. The app saves only after confirmation.

### Transfer between accounts

1. The user selects source and destination accounts.
2. The user enters amount and date.
3. The app creates a linked internal transfer.
4. Both account balances update without counting the transfer as income or expense overall.

### Create a backup

1. The user selects “Back up now.”
2. The app creates and uploads the backup.
3. The app reports whether the operation succeeded.

### Restore a backup

1. The user selects an available backup.
2. The app validates it and displays its information and expected impact.
3. The user confirms the restore.
4. The app restores the data and reports the result.

## 13. Indicative Implementation Roadmap

These are rough estimates for one full-time developer. Actual duration depends on extraction quality, provider selection, security, and release requirements.

| Phase | Work | Duration |
|---|---|---|
| A | Requirements, UX, data concepts, and accounting rules | 1–2 weeks |
| B | Financial core: accounts, transactions, categories, reports, and tests | Weeks 3–6 |
| C | Smart capture: voice, receipts, review flow, and local categorization | Weeks 7–10 |
| D | Safe-to-Spend, obligations, and savings goals | Weeks 11–13 |
| E | Backup/restore and AI integration where needed | Weeks 14–16 |
| F | End-to-end testing, refinement, and release preparation | Weeks 17–20 |

## 14. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| MVP scope grows too large | Freeze Must-have scope and defer advanced features. |
| AI service costs rise | Prefer local rules, set usage limits, and monitor costs. |
| Receipt or voice extraction is inaccurate | Require review before saving and highlight uncertain fields. |
| Financial forecasts mislead users | Explain assumptions and distinguish actual figures from estimates. |
| Data is lost | Provide verifiable backups and test restore regularly. |
| Backup versions conflict | Define restore and versioning rules before introducing multi-device sync. |
| Privacy is compromised | Minimize off-device data and never store sensitive bank credentials. |

## 15. Decisions to Confirm

- Which currencies must be supported in the first release?
- Should balances and reports support multiple currencies, and how should exchange rates be handled?
- Which receipt languages and formats must be supported initially?
- Should receipt images and voice recordings be retained after extraction, or deleted by default?
- What encryption and authentication requirements apply to backups?
- What should happen when restoring over existing local data: replace, create a recovery copy first, or offer a controlled merge?
- Which recurring obligation types and reminder options are required for MVP?
- How should Safe-to-Spend treat pending transactions, overdue obligations, savings allocations, and cash reserves?
- Which minimum Android and iOS versions will be supported?
- Which AI and OCR providers are acceptable based on cost, privacy, and availability?

## 16. Recommended Next Steps

1. Review and approve the MVP scope and outstanding decisions.
2. Finalize the BRD with requirements, business rules, scenarios, and acceptance criteria.
3. Create Database Design with relationships, constraints, indexes, integrity, and backup/restore rules.
4. Create a prioritized implementation backlog with estimates and acceptance criteria.
5. Begin implementation after the requirements and financial calculation rules are agreed; test Android and iOS early.

**Document note.** This BRD captures the current proposed scope and assumptions. Should/Could requirements and open decisions may change after product-owner review.

---

*Finzo Manager · Business Requirements Document · Version 1.0*

---

# النسخة العربية

نفس الوثيقة باللغة العربية، كما تظهر في `brd.html` عند اختيار العربية.

| | |
|---|---|
| الإصدار | 1.0 |
| الحالة | مسودة للمراجعة |
| المنصات | Android + iOS |

| المتطلبات الوظيفية | أولويات MVP | مدة التنفيذ المقدرة |
|---|---|---|
| 19 (Must وShould وCould) | 15 متطلباً أساسياً | 14–20 أسبوعاً · مطور بدوام كامل |

## 01. الملخص التنفيذي

Finzo Manager تطبيق لإدارة الأموال الشخصية على Android وiOS. يتيح تسجيل الدخل والمصروفات والتحويلات الداخلية، وإدارة الحسابات والالتزامات وأهداف الادخار، مع إدخال ذكي للعمليات من الإيصالات والصوت.

**مبدأ التخزين المحلي أولاً.** قاعدة البيانات المحلية هي المصدر التشغيلي الأساسي. تُستخدم Firebase للنسخ الاحتياطي والاستعادة. لا ينفذ التطبيق مدفوعات أو تحويلات مالية حقيقية.

## 02. الأهداف ورؤية المنتج

- تقديم صورة موثوقة وواضحة عن الوضع المالي الشخصي.
- تقليل الوقت اللازم لتسجيل العمليات مع إبقاء التحكم بيد المستخدم.
- تقديم مؤشر Safe-to-Spend بعد احتساب الالتزامات والادخار والاحتياطي.
- استخدام الذكاء الاصطناعي لفهم البيانات وشرحها، وليس لإجراء الحسابات المالية الأساسية.
- إتاحة إدارة الحسابات والعمليات الأساسية دون اتصال بالإنترنت.

## 03. أصحاب المصلحة والمستخدمون

| صاحب المصلحة | الدور |
|---|---|
| المستخدم النهائي | يسجل العمليات ويدير الحسابات والالتزامات وأهداف الادخار. |
| مالك المنتج | يحدد النطاق والأولويات وقواعد العمل. |
| المطور | ينفذ المنتج ويختبره ويجهزه للإصدار؛ والخطة تفترض مطوراً واحداً. |

## 04. المنصات واستراتيجية المنتج

- المنصات: Android وiOS من خلال تطبيق مشترك.
- إصدار MVP متوازن يجمع النواة المالية الموثوقة والإدخال الذكي للعمليات.
- ذكاء اصطناعي هجين: قواعد وسجل محليان مع AI سحابي عند الحاجة.
- النسخ الاحتياطي متاح من الإصدار الأول، مع النسخ الآن والاستعادة.
- دعم العربية والإنجليزية واتجاه RTL للغة العربية.

## 05. نطاق MVP — المشمول

- إدارة حسابات متعددة: حسابات بنكية ومحافظ إلكترونية ونقد يدوي.
- تحديد رصيد افتتاحي لكل حساب.
- تسجيل الدخل والمصروفات والتحويلات الداخلية.
- إدارة التصنيفات والتصنيفات الفرعية.
- إدخال العمليات يدوياً.
- استخراج أولي لبيانات العمليات من صور الإيصالات.
- تحويل الصوت إلى نص واستخراج حقول العملية.
- شاشة لمراجعة البيانات المستخرجة وتعديلها قبل الحفظ.
- اقتراح التصنيفات بالقواعد والسجل المحليين، مع AI سحابي عند الحاجة.
- لوحة معلومات وتقارير لأسبوع أو شهر أو فترة يحددها المستخدم.
- إدارة الالتزامات المتكررة وأهداف الادخار الأساسية.
- مؤشر Safe-to-Spend مع شرح طريقة الحساب.
- التخزين المحلي والعمل دون اتصال.
- النسخ الاحتياطي والاستعادة عبر Firebase.
- تنبيهات للعمليات المحتمل تكرارها.

## 06. خارج نطاق MVP

- تنفيذ المدفوعات أو التحويلات البنكية أو تحويلات Instapay.
- الاتصال بالبنوك لتنفيذ العمليات أو قراءة الأرصدة مباشرة.
- قراءة رسائل SMS البنكية أو الإشعارات تلقائياً.
- المزامنة الفورية الكاملة بين عدة أجهزة.
- تدريب نموذج ذكاء اصطناعي خاص من الصفر.
- إدارة الاستثمارات أو تقديم توصيات استثمارية.
- المحاسبة التجارية أو الحسابات المشتركة متعددة المستخدمين.
- التوقع المالي المتقدم ومحاكاة القرارات والمساعد المالي الشامل.

## 07. المتطلبات الوظيفية

توضح الأولويات ما يجب أن يتضمنه الإصدار الأول وما يمكن تأجيله.

| المعرف | المتطلب | الأولوية |
|---|---|---|
| FR-001 | إدارة عدة حسابات مالية. | أساسي (Must) |
| FR-002 | دعم الحسابات البنكية والمحافظ الإلكترونية والنقد. | أساسي (Must) |
| FR-003 | تحديد رصيد افتتاحي لكل حساب. | أساسي (Must) |
| FR-004 | تسجيل الدخل والمصروفات والتحويلات الداخلية. | أساسي (Must) |
| FR-005 | إدارة التصنيفات والتصنيفات الفرعية. | أساسي (Must) |
| FR-006 | إدخال العمليات يدوياً. | أساسي (Must) |
| FR-007 | استخراج بيانات أولية من صور الإيصالات. | أساسي (Must) |
| FR-008 | تحويل الصوت إلى بيانات عملية مقترحة. | أساسي (Must) |
| FR-009 | مراجعة وتعديل البيانات المستخرجة قبل الحفظ. | أساسي (Must) |
| FR-010 | اقتراح التصنيفات بالقواعد المحلية وAI عند الحاجة. | أساسي (Must) |
| FR-011 | عرض لوحة معلومات وتقارير لفترة محددة. | أساسي (Must) |
| FR-012 | إدارة الالتزامات وأهداف الادخار الأساسية. | أساسي (Must) |
| FR-013 | حساب Safe-to-Spend وشرح النتيجة. | أساسي (Must) |
| FR-014 | التخزين المحلي والعمل دون اتصال. | أساسي (Must) |
| FR-015 | دعم النسخ الاحتياطي والاستعادة عبر Firebase. | أساسي (Must) |
| FR-016 | كشف العمليات المحتمل تكرارها والتنبيه بشأنها. | مهم (Should) |
| FR-017 | توقع التدفق النقدي حتى موعد الراتب التالي. | مهم (Should) |
| FR-018 | محاكاة أثر قرار مالي افتراضي. | اختياري (Could) |
| FR-019 | تقديم مساعد مالي بالذكاء الاصطناعي. | اختياري (Could) |

## 08. قواعد العمل

### BR-001 — التخزين المحلي أولاً

يجب حفظ العمليات محلياً أولاً، ولا يتطلب تسجيل العملية اتصالاً بخدمة خارجية.

### BR-002 — رصيد الحساب

الرصيد الافتتاحي + الدخل + التحويلات الواردة − المصروفات − التحويلات الصادرة، وفق قواعد التاريخ والحالة المحددة.

### BR-003 — التحويلات الداخلية

يربط التحويل بين حساب مصدر وحساب وجهة، ولا يُحتسب دخلاً أو مصروفاً عند حساب إجمالي أموال المستخدم.

### BR-004 — Safe-to-Spend

يوضح الرصيد الأساسي ويحتسب الالتزامات والادخار والاحتياطي دون ازدواجية، مع شرح الأرصدة المستبعدة أو غير المؤكدة.

### BR-005 — مراجعة المستخدم

يجب مراجعة أي مبلغ أو تاريخ أو حساب أو تصنيف مستخرج من صورة أو صوت أو AI قبل الحفظ.

### BR-006 — عدم تنفيذ عمليات حقيقية

يسجل التطبيق المعلومات المالية فقط ولا ينفذ المدفوعات أو التحويلات.

### BR-007 — بيانات الاعتماد الحساسة

يُمنع تخزين كلمات المرور أو PIN أو CVV أو بيانات الدخول البنكية.

### BR-008 — أمان الاستعادة

التحقق من النسخة وشرح أثر الاستعادة، وعدم دمج البيانات عشوائياً.

### BR-009 — محرك الحسابات هو المرجع

محرك الحسابات هو مصدر الحقيقة؛ يساعد AI في الاستخراج والاقتراح والتصنيف والشرح دون تحديد الأرصدة النهائية.

## 09. المتطلبات غير الوظيفية

| المعرف | الاسم | المتطلب |
|---|---|---|
| NFR-001 | العمل دون اتصال | تظل الوظائف الأساسية للحسابات والعمليات متاحة دون إنترنت. |
| NFR-002 | سلامة البيانات | الحفاظ على اتساق الأرصدة وروابط التحويلات وسجلات العمليات. |
| NFR-003 | الخصوصية | تقليل البيانات المرسلة إلى الخدمات السحابية وتوضيح استخدام الخدمات الخارجية. |
| NFR-004 | حماية النسخ الاحتياطية | تطبيق حماية مناسبة للنسخ أثناء النقل والتخزين. |
| NFR-005 | التوافق | دعم إصدارات Android وiOS التي يتم تحديدها في التخطيط. |
| NFR-006 | سهولة الاستخدام | تقليل خطوات الإدخال وتوضيح الأخطاء والحقول التي تحتاج إلى مراجعة. |
| NFR-007 | التحكم في تكلفة AI | تفضيل القواعد المحلية واستخدام AI السحابي عند الحاجة مع بديل عند تعطل الخدمة. |
| NFR-008 | مرونة المزود | تجنب ربط منطق العمل بمزود AI واحد بصورة يصعب تغييرها. |
| NFR-009 | التحقق من الاستعادة | التحقق من البيانات المستعادة وإبلاغ المستخدم بالنتيجة. |

## 10. متطلبات البيانات الأولية

هذه كيانات أولية للتحليل وليست مخطط قاعدة بيانات نهائياً. ستُحدد العلاقات والقيود والفهارس وقواعد سلامة البيانات في وثيقة مستقلة لتصميم قاعدة البيانات.

| الكيان | المحتوى |
|---|---|
| Accounts — الحسابات | اسم الحساب ونوعه والجهة أو رقم الهاتف عند الحاجة والرصيد الافتتاحي. |
| Transactions — العمليات | الدخل والمصروفات والتحويلات والمبلغ والتاريخ والحسابات والتصنيف والحالة. |
| Categories — التصنيفات | التصنيفات والتصنيفات الفرعية. |
| Recurring Obligations — الالتزامات | الالتزامات المتكررة ومواعيد الاستحقاق. |
| Savings Goals — أهداف الادخار | المبالغ المستهدفة والتقدم. |
| Capture Records — سجلات الاستخراج | سجلات استخراج بيانات الإيصالات أو الصوت وحالة المراجعة. |
| AI Rules & Feedback — قواعد AI | قواعد التصنيف وملاحظات المستخدم الاختيارية. |
| Backup Metadata — بيانات النسخ | إصدارات النسخ الاحتياطية وتواريخها وحالتها. |

## 11. معايير القبول

- **AC-001:** يتطابق رصيد كل حساب مع رصيده الافتتاحي والعمليات المسجلة وفق القواعد المحددة.
- **AC-002:** يحدّث التحويل الداخلي الحسابين دون تغيير إجمالي أموال المستخدم.
- **AC-003:** يستطيع المستخدم تسجيل عملية دون اتصال بالإنترنت.
- **AC-004:** لا تُحفظ بيانات الإيصال أو الصوت قبل مراجعتها وتأكيدها.
- **AC-005:** تعرض التقارير العمليات الواقعة ضمن الفترة المختارة بصورة متسقة.
- **AC-006:** يوضح Safe-to-Spend المبالغ التي أُضيفت أو استُبعدت من الحساب.
- **AC-007:** تنجح عملية النسخ والاستعادة مع التحقق من البيانات المستعادة.
- **AC-008:** يصدر تحذير عند الاشتباه بالتكرار دون حذف أو دمج تلقائي غير مصرح به.
- **AC-009:** لا تُكشف مفاتيح الخدمات السرية بصورة غير آمنة داخل التطبيق.
- **AC-010:** تُختبر الوظائف المالية الأساسية على Android وiOS قبل الإصدار.

## 12. سيناريوهات الاستخدام الرئيسية

### إضافة حساب

1. يختار المستخدم نوع الحساب.
2. يدخل اسم الحساب والجهة أو رقم الهاتف عند الحاجة.
3. يدخل الرصيد الافتتاحي.
4. يحفظ التطبيق الحساب محلياً ويعرضه.

### تسجيل مصروف يدوياً

1. يفتح المستخدم شاشة تسجيل العملية.
2. يحدد الحساب والمبلغ والتاريخ والتصنيف.
3. يؤكد المستخدم الحفظ.
4. يحدّث التطبيق الرصيد والتقارير المرتبطة.

### تسجيل مصروف من إيصال

1. يلتقط المستخدم صورة الإيصال أو يختار صورة.
2. يستخرج التطبيق الحقول المحتملة.
3. يعرض التطبيق البيانات للمراجعة.
4. يعدل المستخدم البيانات ويؤكدها.
5. يحفظ التطبيق العملية محلياً.

### تسجيل عملية بالصوت

1. ينطق المستخدم وصف العملية.
2. يحول التطبيق الصوت إلى نص وحقول مقترحة.
3. يراجع المستخدم البيانات ويعدلها.
4. يحفظ التطبيق العملية بعد التأكيد فقط.

### التحويل بين الحسابات

1. يحدد المستخدم حساب المصدر والوجهة.
2. يدخل المبلغ والتاريخ.
3. ينشئ التطبيق تحويلاً داخلياً مرتبطاً.
4. يحدّث الحسابين دون احتساب التحويل دخلاً أو مصروفاً إجمالياً.

### إنشاء نسخة احتياطية

1. يختار المستخدم «نسخ احتياطي الآن».
2. ينشئ التطبيق النسخة ويرفعها.
3. يعرض التطبيق نتيجة العملية.

### استعادة نسخة احتياطية

1. يختار المستخدم نسخة متاحة.
2. يتحقق التطبيق منها ويعرض معلوماتها وأثر الاستعادة.
3. يؤكد المستخدم الاستعادة.
4. يستعيد التطبيق البيانات ويعرض النتيجة.

## 13. خطة التنفيذ التقديرية

هذه تقديرات تقريبية لمطور واحد بدوام كامل. تعتمد المدة الفعلية على جودة استخراج البيانات ومزودي الخدمات ومتطلبات الأمان والإصدار.

| المرحلة | العمل | المدة |
|---|---|---|
| A | تحليل المتطلبات وتجربة المستخدم ومفاهيم البيانات وقواعد الحساب | 1–2 أسبوع |
| B | النواة المالية: الحسابات والعمليات والتصنيفات والتقارير والاختبارات | الأسبوع 3–6 |
| C | الإدخال الذكي: الصوت والإيصالات والمراجعة والتصنيف المحلي | الأسبوع 7–10 |
| D | Safe-to-Spend والالتزامات وأهداف الادخار | الأسبوع 11–13 |
| E | النسخ والاستعادة ودمج AI عند الحاجة | الأسبوع 14–16 |
| F | الاختبارات الشاملة والتحسين وتجهيز الإصدار | الأسبوع 17–20 |

## 14. المخاطر وطرق المعالجة

| الخطر | طريقة المعالجة |
|---|---|
| اتساع نطاق MVP | تثبيت متطلبات Must وتأجيل الميزات المتقدمة. |
| ارتفاع تكلفة AI | تفضيل القواعد المحلية ووضع حدود للاستخدام ومراقبة التكلفة. |
| عدم دقة استخراج الإيصالات أو الصوت | إلزام المراجعة قبل الحفظ وإبراز الحقول غير المؤكدة. |
| تضليل المستخدم بتوقعات مالية | شرح الافتراضات والتمييز بين القيم الفعلية والتقديرية. |
| فقدان البيانات | توفير نسخ قابلة للتحقق واختبار الاستعادة بانتظام. |
| تعارض النسخ الاحتياطية | تعريف قواعد الاستعادة والإصدارات قبل إضافة المزامنة بين الأجهزة. |
| مخاطر الخصوصية | تقليل البيانات الخارجة من الجهاز وعدم تخزين بيانات الاعتماد البنكية الحساسة. |

## 15. قرارات مطلوب حسمها

- ما العملات المطلوب دعمها في الإصدار الأول؟
- هل ستدعم الأرصدة والتقارير عملات متعددة؟ وكيف ستُعالج أسعار الصرف؟
- ما لغات وأشكال الإيصالات المطلوب دعمها أولاً؟
- هل تُحفظ صور الإيصالات والتسجيلات الصوتية بعد الاستخراج أم تُحذف افتراضياً؟
- ما متطلبات التشفير والمصادقة للنسخ الاحتياطية؟
- ماذا يحدث عند الاستعادة فوق بيانات موجودة: استبدال أم إنشاء نسخة استرداد أم دمج مضبوط؟
- ما أنواع الالتزامات المتكررة والتنبيهات المطلوبة في MVP؟
- كيف يعالج Safe-to-Spend العمليات المعلقة والالتزامات المتأخرة ومخصصات الادخار والاحتياطي النقدي؟
- ما أقل إصدارات Android وiOS التي ستُدعم؟
- ما مزودو AI وOCR المقبولون من حيث التكلفة والخصوصية والتوفر؟

## 16. الخطوات التالية المقترحة

1. مراجعة نطاق MVP والقرارات المعلقة واعتمادهما.
2. اعتماد BRD نهائياً متضمناً المتطلبات وقواعد العمل والسيناريوهات ومعايير القبول.
3. إعداد تصميم قاعدة البيانات شاملاً العلاقات والقيود والفهارس وسلامة البيانات والنسخ والاستعادة.
4. إعداد قائمة تنفيذ مرتبة حسب الأولوية مع التقديرات ومعايير القبول.
5. بدء التنفيذ بعد اعتماد المتطلبات وقواعد الحساب المالي، مع اختبار Android وiOS مبكراً.

**ملاحظة الوثيقة.** تعكس هذه الوثيقة النطاق والافتراضات المقترحة حالياً. قد تتغير متطلبات Should وCould والقرارات المفتوحة بعد مراجعة مالك المنتج.

*Finzo Manager · وثيقة متطلبات العمل · الإصدار 1.0*
