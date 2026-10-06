import 'package:equatable/equatable.dart';

import 'backup_settings.dart';

class BackupCopy extends Equatable {
  const BackupCopy({
    required this.id,
    required this.createdAt,
    required this.origin,
    required this.outcome,
  });

  final String id;
  final DateTime createdAt;
  final BackupOrigin origin;
  final BackupOutcome outcome;

  @override
  List<Object?> get props => <Object?>[id, createdAt, origin, outcome];
}
