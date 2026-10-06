import '../entities/backup_copy.dart';
import '../entities/backup_settings.dart';

const int keptCloudCopyCount = 5;

List<BackupCopy> copiesToDrop(List<BackupCopy> copies) {
  final List<BackupCopy> successful =
      copies
          .where((BackupCopy copy) => copy.outcome == BackupOutcome.succeeded)
          .toList()
        ..sort(
          (BackupCopy left, BackupCopy right) =>
              right.createdAt.compareTo(left.createdAt),
        );
  if (successful.length <= keptCloudCopyCount) {
    return const <BackupCopy>[];
  }
  return successful.sublist(keptCloudCopyCount);
}

List<BackupCopy> newestCloudCopies(List<BackupCopy> copies) {
  final List<BackupCopy> successful =
      copies
          .where((BackupCopy copy) => copy.outcome == BackupOutcome.succeeded)
          .toList()
        ..sort(
          (BackupCopy left, BackupCopy right) =>
              right.createdAt.compareTo(left.createdAt),
        );
  if (successful.length <= keptCloudCopyCount) {
    return successful;
  }
  return successful.sublist(0, keptCloudCopyCount);
}
