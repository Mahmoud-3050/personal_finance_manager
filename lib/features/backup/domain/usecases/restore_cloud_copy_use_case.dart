import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/finance_records.dart';
import '../repositories/backup_repository.dart';

class RestoreCloudCopyParams extends Params {
  const RestoreCloudCopyParams({
    required this.copyId,
    required this.confirmed,
    this.cancellation,
  });

  final String copyId;
  final bool confirmed;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'copyId': copyId,
    'confirmed': confirmed,
  };

  @override
  List<Object?> get props => <Object?>[copyId, confirmed, cancellation];
}

class RestoreCloudCopyUseCase
    extends UseCase<FinanceRecords, RestoreCloudCopyParams> {
  RestoreCloudCopyUseCase(this._repository);

  final BackupRepository _repository;

  @override
  Future<Either<Failure, FinanceRecords>> call(RestoreCloudCopyParams params) {
    return _repository.restoreCloudCopy(
      copyId: params.copyId,
      confirmed: params.confirmed,
    );
  }
}
