import 'package:either/either.dart';

import '../../../../core/data/repository_guard.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/network/netwok_info.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../domain/entities/backup_copy.dart';
import '../../domain/entities/backup_settings.dart';
import '../../domain/entities/import_preview.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/services/backup_retention.dart';
import '../../domain/services/backup_schedule.dart';
import '../datasources/backup_settings_data_source.dart';
import '../datasources/book_snapshot_data_source.dart';
import '../datasources/cloud_backup_data_source.dart';
import '../datasources/export_file_data_source.dart';
import '../models/book_snapshot_model.dart';

class BackupRepositoryImpl with RepositoryGuard implements BackupRepository {
  BackupRepositoryImpl({
    required BookSnapshotDataSource books,
    required BackupSettingsStore settings,
    required CloudBackupDataSource cloud,
    required ExportFileDataSource files,
    required NetworkInfo network,
  }) : _books = books,
       _settings = settings,
       _cloud = cloud,
       _files = files,
       _network = network;

  final BookSnapshotDataSource _books;
  final BackupSettingsStore _settings;
  final CloudBackupDataSource _cloud;
  final ExportFileDataSource _files;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, BackupSettings>> getStatus() {
    return guard(_settings.read, 'getBackupStatus');
  }

  @override
  Future<Either<Failure, BackupSettings>> signIn() {
    return guard(() async {
      if (!_cloud.isSignedIn) {
        await _cloud.signIn();
      }
      return _settings.read();
    }, 'signInForBackup');
  }

  @override
  Future<Either<Failure, BackupSettings>> runManualBackup({
    required DateTime now,
  }) {
    return guard(() async {
      if (!await _network.isConnected) {
        await _recordAttempt(
          now: now,
          outcome: BackupOutcome.waiting,
          origin: BackupOrigin.manualCloud,
        );
        throw const InternetConnectionException(message: 'offline');
      }
      if (!_cloud.isSignedIn) {
        await _recordAttempt(
          now: now,
          outcome: BackupOutcome.failed,
          origin: BackupOrigin.manualCloud,
        );
        throw const UnauthorizedException(message: 'sign_in_required');
      }
      try {
        return await _send(now: now, origin: BackupOrigin.manualCloud);
      } on AppException {
        await _recordAttempt(
          now: now,
          outcome: BackupOutcome.failed,
          origin: BackupOrigin.manualCloud,
        );
        rethrow;
      }
    }, 'runManualBackup');
  }

  @override
  Future<Either<Failure, BackupSettings>> setSchedule(BackupSchedule schedule) {
    return guard(() async {
      final BackupSettings next = (await _settings.read()).copyWith(
        schedule: schedule,
      );
      await _settings.write(next);
      return next;
    }, 'setBackupSchedule');
  }

  @override
  Future<Either<Failure, BackupSettings>> runAutomaticBackup({
    required DateTime now,
  }) {
    return guard(() async {
      final BackupSettings current = await _settings.read();
      if (!backupIsDue(
        schedule: current.schedule,
        lastSuccessAt: current.lastSuccessAt,
        now: now,
      )) {
        return current;
      }
      if (!await _network.isConnected) {
        final BackupSettings waiting = current.copyWith(
          lastAttemptAt: now,
          lastOutcome: BackupOutcome.waiting,
          lastOrigin: BackupOrigin.automaticCloud,
        );
        await _settings.write(waiting);
        return waiting;
      }
      if (!_cloud.isSignedIn) {
        final BackupSettings failed = current.copyWith(
          lastAttemptAt: now,
          lastOutcome: BackupOutcome.failed,
          lastOrigin: BackupOrigin.automaticCloud,
        );
        await _settings.write(failed);
        return failed;
      }
      return _send(now: now, origin: BackupOrigin.automaticCloud);
    }, 'runAutomaticBackup');
  }

  @override
  Future<Either<Failure, List<BackupCopy>>> listCloudCopies() {
    return guard(() async {
      await _requireOnline();
      return newestCloudCopies(await _cloud.listCopies());
    }, 'listCloudCopies');
  }

  @override
  Future<Either<Failure, FinanceRecords>> restoreCloudCopy({
    required String copyId,
    required bool confirmed,
  }) {
    return guard(() async {
      if (!confirmed) {
        return _books.read();
      }
      await _requireOnline();
      final BookSnapshotModel snapshot = await _cloud.download(copyId);
      await _books.replace(snapshot.records);
      return _books.read();
    }, 'restoreCloudCopy');
  }

  @override
  Future<Either<Failure, BackupSettings>> exportBook({required DateTime now}) {
    return guard(() async {
      final BookSnapshotModel snapshot = BookSnapshotModel.fromRecords(
        records: await _books.read(),
        createdAt: now.toUtc(),
        origin: BackupOrigin.export,
      );
      await _files.share(snapshot);
      return _recordAttempt(
        now: now,
        outcome: BackupOutcome.succeeded,
        origin: BackupOrigin.export,
      );
    }, 'exportBook');
  }

  @override
  Future<Either<Failure, ImportPreview>> previewImport() {
    return guard(() async {
      final BookSnapshotModel snapshot = await _files.pick();
      return ImportPreview(
        createdAt: snapshot.createdAt,
        records: snapshot.records,
      );
    }, 'previewImport');
  }

  @override
  Future<Either<Failure, FinanceRecords>> importBook({
    required bool confirmed,
    FinanceRecords? replacement,
  }) {
    return guard(() async {
      if (!confirmed) {
        return _books.read();
      }
      final FinanceRecords records =
          replacement ?? (await _files.pick()).records;
      await _books.replace(records);
      return _books.read();
    }, 'importBook');
  }

  Future<BackupSettings> _send({
    required DateTime now,
    required BackupOrigin origin,
  }) async {
    final BookSnapshotModel snapshot = BookSnapshotModel.fromRecords(
      records: await _books.read(),
      createdAt: now.toUtc(),
      origin: origin,
    );
    await _cloud.upload(snapshot);
    final List<BackupCopy> copies = await _cloud.listCopies();
    for (final BackupCopy extra in copiesToDrop(copies)) {
      await _cloud.delete(extra.id);
    }
    final BackupSettings next = (await _settings.read()).copyWith(
      lastAttemptAt: now,
      lastSuccessAt: now,
      lastOutcome: BackupOutcome.succeeded,
      lastOrigin: origin,
    );
    await _settings.write(next);
    return next;
  }

  Future<BackupSettings> _recordAttempt({
    required DateTime now,
    required BackupOutcome outcome,
    required BackupOrigin origin,
  }) async {
    final BackupSettings next = (await _settings.read()).copyWith(
      lastAttemptAt: now,
      lastOutcome: outcome,
      lastOrigin: origin,
    );
    await _settings.write(next);
    return next;
  }

  Future<void> _requireOnline() async {
    if (!await _network.isConnected) {
      throw const InternetConnectionException(message: 'offline');
    }
  }
}
