import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/backup_settings.dart';
import '../repositories/backup_repository.dart';

class ExportBookParams extends Params {
  const ExportBookParams({required this.now, this.cancellation});

  final DateTime now;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'now': now.toIso8601String(),
  };

  @override
  List<Object?> get props => <Object?>[now, cancellation];
}

class ExportBookUseCase extends UseCase<BackupSettings, ExportBookParams> {
  ExportBookUseCase(this._repository);

  final BackupRepository _repository;

  @override
  Future<Either<Failure, BackupSettings>> call(ExportBookParams params) {
    return _repository.exportBook(now: params.now);
  }
}
