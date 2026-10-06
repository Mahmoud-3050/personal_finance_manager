import 'package:equatable/equatable.dart';

enum BackupSchedule { off, daily, weekly, monthly }

enum BackupOutcome { succeeded, failed, waiting }

enum BackupOrigin { manualCloud, automaticCloud, export }

class BackupSettings extends Equatable {
  const BackupSettings({
    this.schedule = BackupSchedule.off,
    this.lastAttemptAt,
    this.lastSuccessAt,
    this.lastOutcome,
    this.lastOrigin,
  });

  final BackupSchedule schedule;
  final DateTime? lastAttemptAt;
  final DateTime? lastSuccessAt;
  final BackupOutcome? lastOutcome;
  final BackupOrigin? lastOrigin;

  BackupSettings copyWith({
    BackupSchedule? schedule,
    DateTime? lastAttemptAt,
    DateTime? lastSuccessAt,
    BackupOutcome? lastOutcome,
    BackupOrigin? lastOrigin,
  }) {
    return BackupSettings(
      schedule: schedule ?? this.schedule,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastOutcome: lastOutcome ?? this.lastOutcome,
      lastOrigin: lastOrigin ?? this.lastOrigin,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    schedule,
    lastAttemptAt,
    lastSuccessAt,
    lastOutcome,
    lastOrigin,
  ];
}
