import 'package:flutter_test/flutter_test.dart';

import '../support/memory_backup.dart';

void main() {
  test('uploading a sixth copy keeps the five newest', () async {
    final BackupHarness harness = BackupHarness();
    for (int day = 1; day <= 6; day++) {
      final result = await harness.repository.runManualBackup(
        now: DateTime.utc(2026, 10, day),
      );
      expect(result.isRight, isTrue);
    }

    final listed = await harness.repository.listCloudCopies();
    listed.fold((_) => fail('expected the newest copies'), (copies) {
      expect(copies, hasLength(5));
      expect(copies.first.createdAt, DateTime.utc(2026, 10, 6));
      expect(copies.last.createdAt, DateTime.utc(2026, 10, 2));
    });
    expect(harness.cloud.stored.length, 5);
    expect(
      harness.cloud.stored.keys,
      isNot(contains(DateTime.utc(2026, 10).toIso8601String())),
    );
  });
}
