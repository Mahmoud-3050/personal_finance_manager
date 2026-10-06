import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/finance_records.dart';
import '../entities/backup_copy.dart';
import '../entities/backup_settings.dart';
import '../entities/import_preview.dart';

abstract interface class BackupRepository {
  Future<Either<Failure, BackupSettings>> getStatus();

  Future<Either<Failure, BackupSettings>> signIn();

  Future<Either<Failure, BackupSettings>> runManualBackup({
    required DateTime now,
  });

  Future<Either<Failure, BackupSettings>> setSchedule(BackupSchedule schedule);

  Future<Either<Failure, BackupSettings>> runAutomaticBackup({
    required DateTime now,
  });

  Future<Either<Failure, List<BackupCopy>>> listCloudCopies();

  Future<Either<Failure, ImportPreview>> previewImport();

  Future<Either<Failure, FinanceRecords>> restoreCloudCopy({
    required String copyId,
    required bool confirmed,
  });

  Future<Either<Failure, BackupSettings>> exportBook({required DateTime now});

  Future<Either<Failure, FinanceRecords>> importBook({
    required bool confirmed,
    FinanceRecords? replacement,
  });
}
