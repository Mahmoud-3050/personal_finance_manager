import 'package:finzomanager/features/backup/domain/entities/backup_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_backup.dart';

void main() {
  test('a failed upload does not replace the book', () async {
    final BackupHarness harness = BackupHarness();
    harness.cloud.failUpload = true;

    final result = await harness.repository.runManualBackup(
      now: DateTime.utc(2026, 10, 6),
    );

    expect(result.isLeft, isTrue);
    expect(harness.books.replacements, 0);
    expect(harness.settings.current.lastOutcome, BackupOutcome.failed);
  });
}
