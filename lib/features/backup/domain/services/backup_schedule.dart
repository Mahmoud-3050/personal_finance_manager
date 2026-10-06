import '../../../../shared/domain/entities/calendar_date.dart';
import '../entities/backup_settings.dart';

bool backupIsDue({
  required BackupSchedule schedule,
  required DateTime? lastSuccessAt,
  required DateTime now,
}) {
  switch (schedule) {
    case BackupSchedule.off:
      return false;
    case BackupSchedule.daily:
      if (lastSuccessAt == null) {
        return true;
      }
      return CalendarDate.fromDateTime(lastSuccessAt) !=
          CalendarDate.fromDateTime(now);
    case BackupSchedule.weekly:
      if (lastSuccessAt == null) {
        return true;
      }
      final lastWeek = CalendarDate.weekContaining(
        CalendarDate.fromDateTime(lastSuccessAt),
      );
      final thisWeek = CalendarDate.weekContaining(
        CalendarDate.fromDateTime(now),
      );
      return lastWeek.start != thisWeek.start;
    case BackupSchedule.monthly:
      if (lastSuccessAt == null) {
        return true;
      }
      return lastSuccessAt.year != now.year || lastSuccessAt.month != now.month;
  }
}
