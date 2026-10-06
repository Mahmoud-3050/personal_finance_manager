import 'package:finzomanager/features/backup/domain/entities/backup_settings.dart';
import 'package:finzomanager/features/backup/domain/services/backup_schedule.dart';
import 'package:finzomanager/features/backup/domain/usecases/run_automatic_backup_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_backup.dart';

void main() {
  test('daily is due on a new calendar day and skipped the same day', () {
    final DateTime morning = DateTime(2026, 10, 6, 8);
    final DateTime evening = DateTime(2026, 10, 6, 21);
    final DateTime nextDay = DateTime(2026, 10, 7, 1);
    expect(
      backupIsDue(
        schedule: BackupSchedule.daily,
        lastSuccessAt: morning,
        now: evening,
      ),
      isFalse,
    );
    expect(
      backupIsDue(
        schedule: BackupSchedule.daily,
        lastSuccessAt: morning,
        now: nextDay,
      ),
      isTrue,
    );
  });

  test('weekly follows Saturday to Friday', () {
    final DateTime friday = DateTime(2026, 10, 2);
    final DateTime saturday = DateTime(2026, 10, 3);
    expect(
      backupIsDue(
        schedule: BackupSchedule.weekly,
        lastSuccessAt: friday,
        now: DateTime(2026, 10, 2, 18),
      ),
      isFalse,
    );
    expect(
      backupIsDue(
        schedule: BackupSchedule.weekly,
        lastSuccessAt: friday,
        now: saturday,
      ),
      isTrue,
    );
  });

  test('monthly follows the calendar month', () {
    expect(
      backupIsDue(
        schedule: BackupSchedule.monthly,
        lastSuccessAt: DateTime(2026, 10),
        now: DateTime(2026, 10, 31),
      ),
      isFalse,
    );
    expect(
      backupIsDue(
        schedule: BackupSchedule.monthly,
        lastSuccessAt: DateTime(2026, 10, 31),
        now: DateTime(2026, 11),
      ),
      isTrue,
    );
  });

  test('an offline automatic run waits and does not upload', () async {
    final BackupHarness harness = BackupHarness(online: false);
    harness.settings.current = const BackupSettings(
      schedule: BackupSchedule.daily,
    );
    final result = await RunAutomaticBackupUseCase(harness.repository)(
      RunAutomaticBackupParams(now: DateTime(2026, 10, 6)),
    );

    result.fold((_) => fail('expected a waiting status'), (settings) {
      expect(settings.lastOutcome, BackupOutcome.waiting);
    });
    expect(harness.cloud.stored, isEmpty);
  });
}
