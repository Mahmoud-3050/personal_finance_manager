import 'package:either/either.dart';
import 'package:finzomanager/core/error/exceptions.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/services/network/netwok_info.dart';
import 'package:finzomanager/features/backup/data/datasources/backup_settings_data_source.dart';
import 'package:finzomanager/features/backup/data/datasources/book_snapshot_data_source.dart';
import 'package:finzomanager/features/backup/data/datasources/cloud_backup_data_source.dart';
import 'package:finzomanager/features/backup/data/datasources/export_file_data_source.dart';
import 'package:finzomanager/features/backup/data/models/book_snapshot_model.dart';
import 'package:finzomanager/features/backup/data/repositories/backup_repository_impl.dart';
import 'package:finzomanager/features/backup/domain/entities/backup_copy.dart';
import 'package:finzomanager/features/backup/domain/entities/backup_settings.dart';
import 'package:finzomanager/features/backup/domain/entities/import_preview.dart';
import 'package:finzomanager/features/backup/domain/repositories/backup_repository.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';

class MemoryBooks implements BookSnapshotDataSource {
  MemoryBooks(this.records);

  FinanceRecords records;
  int replacements = 0;

  @override
  Future<FinanceRecords> read() async => records;

  @override
  Future<void> replace(FinanceRecords next) async {
    replacements += 1;
    records = next;
  }
}

class MemorySettings implements BackupSettingsStore {
  BackupSettings current = const BackupSettings();

  @override
  Future<BackupSettings> read() async => current;

  @override
  Future<void> write(BackupSettings settings) async {
    current = settings;
  }
}

class MemoryCloud implements CloudBackupDataSource {
  MemoryCloud({this.signedIn = true});

  bool signedIn;
  bool cancelSignIn = false;
  bool failUpload = false;
  final Map<String, BookSnapshotModel> stored = <String, BookSnapshotModel>{};

  @override
  bool get isSignedIn => signedIn;

  @override
  Future<void> signIn() async {
    if (cancelSignIn) {
      throw const SocialSignInCancelledException();
    }
    signedIn = true;
  }

  @override
  Future<BackupCopy> upload(BookSnapshotModel snapshot) async {
    if (failUpload) {
      throw const ServerException(message: 'upload_failed');
    }
    final String id = snapshot.createdAt.toIso8601String();
    stored[id] = snapshot;
    return BackupCopy(
      id: id,
      createdAt: snapshot.createdAt,
      origin: snapshot.origin,
      outcome: BackupOutcome.succeeded,
    );
  }

  @override
  Future<List<BackupCopy>> listCopies() async {
    return stored.entries
        .map(
          (MapEntry<String, BookSnapshotModel> entry) => BackupCopy(
            id: entry.key,
            createdAt: entry.value.createdAt,
            origin: entry.value.origin,
            outcome: BackupOutcome.succeeded,
          ),
        )
        .toList();
  }

  @override
  Future<BookSnapshotModel> download(String copyId) async {
    final BookSnapshotModel? snapshot = stored[copyId];
    if (snapshot == null) {
      throw const CacheException(message: 'missing_backup');
    }
    return snapshot;
  }

  @override
  Future<void> delete(String copyId) async {
    stored.remove(copyId);
  }
}

class MemoryFiles implements ExportFileDataSource {
  BookSnapshotModel? shared;
  BookSnapshotModel? picked;
  bool cancel = false;
  bool reject = false;

  @override
  Future<void> share(BookSnapshotModel snapshot) async {
    shared = snapshot;
  }

  @override
  Future<BookSnapshotModel> pick() async {
    if (cancel) {
      throw const RequestCancelledException();
    }
    if (reject || picked == null) {
      throw const ValidationException(message: 'invalid_backup');
    }
    return picked!;
  }
}

class MemoryNetwork implements NetworkInfo {
  MemoryNetwork({this.online = true});

  bool online;

  @override
  Future<bool> get isConnected async => online;
}

class BackupHarness {
  BackupHarness({
    FinanceRecords? book,
    bool online = true,
    bool signedIn = true,
  }) : books = MemoryBooks(book ?? FinanceRecords.empty()),
       settings = MemorySettings(),
       cloud = MemoryCloud(signedIn: signedIn),
       files = MemoryFiles(),
       network = MemoryNetwork(online: online) {
    repository = BackupRepositoryImpl(
      books: books,
      settings: settings,
      cloud: cloud,
      files: files,
      network: network,
    );
  }

  final MemoryBooks books;
  final MemorySettings settings;
  final MemoryCloud cloud;
  final MemoryFiles files;
  final MemoryNetwork network;
  late final BackupRepositoryImpl repository;
}

class ScriptedBackupRepository implements BackupRepository {
  ScriptedBackupRepository({this.error});

  final Failure? error;
  int restores = 0;
  int imports = 0;
  BackupSettings status = const BackupSettings();

  Either<Failure, T> _result<T>(T value) {
    final Failure? failure = error;
    if (failure != null) {
      return Left<Failure, T>(failure);
    }
    return Right<Failure, T>(value);
  }

  @override
  Future<Either<Failure, BackupSettings>> getStatus() async {
    return _result(status);
  }

  @override
  Future<Either<Failure, BackupSettings>> signIn() async {
    return _result(const BackupSettings());
  }

  @override
  Future<Either<Failure, BackupSettings>> runManualBackup({
    required DateTime now,
  }) async {
    return _result(
      BackupSettings(
        lastSuccessAt: now,
        lastOutcome: BackupOutcome.succeeded,
        lastOrigin: BackupOrigin.manualCloud,
      ),
    );
  }

  @override
  Future<Either<Failure, BackupSettings>> setSchedule(
    BackupSchedule schedule,
  ) async {
    return _result(BackupSettings(schedule: schedule));
  }

  @override
  Future<Either<Failure, BackupSettings>> runAutomaticBackup({
    required DateTime now,
  }) async {
    return _result(
      BackupSettings(
        schedule: BackupSchedule.daily,
        lastSuccessAt: now,
        lastOutcome: BackupOutcome.succeeded,
      ),
    );
  }

  @override
  Future<Either<Failure, List<BackupCopy>>> listCloudCopies() async {
    return _result(<BackupCopy>[
      BackupCopy(
        id: 'copy-1',
        createdAt: DateTime.utc(2026, 10, 6),
        origin: BackupOrigin.manualCloud,
        outcome: BackupOutcome.succeeded,
      ),
    ]);
  }

  @override
  Future<Either<Failure, FinanceRecords>> restoreCloudCopy({
    required String copyId,
    required bool confirmed,
  }) async {
    if (confirmed) {
      restores += 1;
    }
    return _result(FinanceRecords.empty());
  }

  @override
  Future<Either<Failure, BackupSettings>> exportBook({
    required DateTime now,
  }) async {
    status = BackupSettings(
      lastAttemptAt: now,
      lastOutcome: BackupOutcome.succeeded,
      lastOrigin: BackupOrigin.export,
    );
    return _result(status);
  }

  @override
  Future<Either<Failure, ImportPreview>> previewImport() async {
    return _result(
      ImportPreview(
        createdAt: DateTime.utc(2026, 10, 6),
        records: FinanceRecords.empty(),
      ),
    );
  }

  @override
  Future<Either<Failure, FinanceRecords>> importBook({
    required bool confirmed,
    FinanceRecords? replacement,
  }) async {
    if (confirmed) {
      imports += 1;
    }
    return _result(replacement ?? FinanceRecords.empty());
  }
}
