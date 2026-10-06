import 'package:finzomanager/features/backup/data/models/book_snapshot_model.dart';
import 'package:finzomanager/features/backup/domain/entities/backup_settings.dart';
import 'package:finzomanager/core/usecases/usecase.dart';
import 'package:finzomanager/features/backup/domain/usecases/export_book_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/import_book_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/preview_import_use_case.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_backup.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 10, 6);
  final Account account = Account(
    id: 'cash',
    name: 'Cash',
    type: AccountType.cash,
    openingBalanceMinor: 1500,
    openingDate: const CalendarDate(2026, 10, 1),
    isActive: true,
    includeInTotal: true,
    createdAt: now,
    updatedAt: now,
  );
  final FinanceRecords book = FinanceRecords(
    accounts: <Account>[account],
    categories: const [],
    subcategories: const [],
    transactions: const [],
  );

  test('export works offline and has no passphrase', () async {
    final BackupHarness harness = BackupHarness(book: book, online: false);
    final result = await ExportBookUseCase(harness.repository)(
      ExportBookParams(now: now),
    );

    expect(result.isRight, isTrue);
    final BookSnapshotModel snapshot = harness.files.shared!;
    expect(snapshot.formatVersion, 1);
    expect(snapshot.origin, BackupOrigin.export);
    expect(snapshot.toJson().containsKey('passphrase'), isFalse);
    expect(snapshot.records.accounts.single.name, 'Cash');
    expect(harness.cloud.stored, isEmpty);
    expect(harness.settings.current.lastOrigin, BackupOrigin.export);
    expect(harness.settings.current.lastOutcome, BackupOutcome.succeeded);
    expect(harness.settings.current.lastSuccessAt, isNull);
  });

  test('preview shows the file date before the book is replaced', () async {
    final BackupHarness harness = BackupHarness();
    harness.files.picked = BookSnapshotModel.fromRecords(
      records: book,
      createdAt: now,
      origin: BackupOrigin.export,
    );
    final preview = await PreviewImportUseCase(harness.repository)(
      const NoParams(),
    );

    preview.fold((_) => fail('expected a preview'), (value) {
      expect(value.createdAt, now);
      expect(value.records.accounts.single.name, 'Cash');
    });
    expect(harness.books.replacements, 0);

    final imported = await ImportBookUseCase(harness.repository)(
      ImportBookParams(
        confirmed: true,
        replacement: preview.fold(
          (_) => FinanceRecords.empty(),
          (value) => value.records,
        ),
      ),
    );
    expect(imported.isRight, isTrue);
    expect(harness.books.records.accounts.single.name, 'Cash');
  });

  test('a confirmed import replaces the book', () async {
    final BackupHarness harness = BackupHarness();
    harness.files.picked = BookSnapshotModel.fromRecords(
      records: book,
      createdAt: now,
      origin: BackupOrigin.export,
    );
    final result = await ImportBookUseCase(harness.repository)(
      const ImportBookParams(confirmed: true),
    );

    expect(result.isRight, isTrue);
    expect(harness.books.records.accounts.single.openingBalanceMinor, 1500);
  });

  test('a cancelled import leaves the book unchanged', () async {
    final BackupHarness harness = BackupHarness(book: book);
    harness.files.cancel = true;
    final result = await ImportBookUseCase(harness.repository)(
      const ImportBookParams(confirmed: false),
    );

    expect(result.isRight, isTrue);
    expect(harness.books.replacements, 0);
    expect(harness.books.records.accounts.single.name, 'Cash');
  });

  test('a rejected file does not replace the book', () async {
    final BackupHarness harness = BackupHarness(book: book);
    harness.files.reject = true;
    final result = await ImportBookUseCase(harness.repository)(
      const ImportBookParams(confirmed: true),
    );

    expect(result.isLeft, isTrue);
    expect(harness.books.replacements, 0);
  });

  test('snapshot json rejects an unknown version', () {
    expect(
      () => BookSnapshotModel.fromJson(<String, dynamic>{
        'formatVersion': 2,
        'createdAt': now.toIso8601String(),
        'source': 'export',
        'accounts': <Object>[],
        'categories': <Object>[],
        'subcategories': <Object>[],
        'transactions': <Object>[],
      }),
      throwsA(isA<Exception>()),
    );
  });
}
