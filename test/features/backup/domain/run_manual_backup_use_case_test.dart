import 'package:finzomanager/features/backup/domain/entities/backup_settings.dart';
import 'package:finzomanager/features/backup/domain/usecases/run_manual_backup_use_case.dart';
import 'package:finzomanager/features/backup/domain/usecases/sign_in_for_backup_use_case.dart';
import 'package:finzomanager/core/usecases/usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_backup.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 10, 6, 9);

  test('a connected manual backup records success', () async {
    final BackupHarness harness = BackupHarness();
    final result = await RunManualBackupUseCase(harness.repository)(
      RunManualBackupParams(now: now),
    );

    expect(result.isRight, isTrue);
    result.fold((_) => fail('expected success'), (BackupSettings settings) {
      expect(settings.lastOutcome, BackupOutcome.succeeded);
      expect(settings.lastOrigin, BackupOrigin.manualCloud);
    });
    expect(harness.cloud.stored, hasLength(1));
    expect(harness.cloud.stored.values.single.formatVersion, 1);
    expect(
      harness.cloud.stored.values.single.toJson().containsKey('passphrase'),
      isFalse,
    );
    expect(harness.books.replacements, 0);
  });

  test(
    'an offline manual backup does not succeed or change the book',
    () async {
      final BackupHarness harness = BackupHarness(online: false);
      final result = await RunManualBackupUseCase(harness.repository)(
        RunManualBackupParams(now: now),
      );

      expect(result.isLeft, isTrue);
      expect(harness.cloud.stored, isEmpty);
      expect(harness.books.replacements, 0);
      expect(harness.settings.current.lastOutcome, BackupOutcome.waiting);
    },
  );

  test('a cancelled sign-in leaves the book unchanged', () async {
    final BackupHarness harness = BackupHarness(signedIn: false);
    harness.cloud.cancelSignIn = true;
    final result = await SignInForBackupUseCase(harness.repository)(
      const NoParams(),
    );

    expect(result.isLeft, isTrue);
    expect(harness.books.replacements, 0);
    expect(harness.cloud.stored, isEmpty);
  });
}
