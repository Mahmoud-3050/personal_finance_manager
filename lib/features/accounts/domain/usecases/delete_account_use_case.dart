import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/finance_records.dart';
import '../repositories/accounts_repository.dart';

class DeleteAccountParams extends Params {
  const DeleteAccountParams(this.id, {this.cancellation});
  final String id;
  @override
  final Object? cancellation;
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'id': id};
  @override
  List<Object?> get props => <Object?>[id];
}

class DeleteAccountUseCase
    extends UseCase<FinanceRecords, DeleteAccountParams> {
  DeleteAccountUseCase(this._repository);
  final AccountsRepository _repository;
  @override
  Future<Either<Failure, FinanceRecords>> call(DeleteAccountParams params) {
    return _repository.deleteAccount(params.id);
  }
}
