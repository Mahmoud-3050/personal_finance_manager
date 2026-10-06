import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/finance_records.dart';
import '../repositories/backup_repository.dart';

class ImportBookParams extends Params {
  const ImportBookParams({
    required this.confirmed,
    this.replacement,
    this.cancellation,
  });

  final bool confirmed;
  final FinanceRecords? replacement;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'confirmed': confirmed};

  @override
  List<Object?> get props => <Object?>[confirmed, replacement, cancellation];
}

class ImportBookUseCase extends UseCase<FinanceRecords, ImportBookParams> {
  ImportBookUseCase(this._repository);

  final BackupRepository _repository;

  @override
  Future<Either<Failure, FinanceRecords>> call(ImportBookParams params) {
    return _repository.importBook(
      confirmed: params.confirmed,
      replacement: params.replacement,
    );
  }
}
