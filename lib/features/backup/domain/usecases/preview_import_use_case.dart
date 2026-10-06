import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/import_preview.dart';
import '../repositories/backup_repository.dart';

class PreviewImportUseCase extends UseCase<ImportPreview, NoParams> {
  PreviewImportUseCase(this._repository);

  final BackupRepository _repository;

  @override
  Future<Either<Failure, ImportPreview>> call(NoParams params) {
    return _repository.previewImport();
  }
}
