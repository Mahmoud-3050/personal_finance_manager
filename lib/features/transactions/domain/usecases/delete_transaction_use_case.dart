import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/finance_records.dart';
import '../repositories/transactions_repository.dart';

class DeleteTransactionParams extends Params {
  const DeleteTransactionParams(this.id, {this.cancellation});
  final String id;
  @override
  final Object? cancellation;
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'id': id};
  @override
  List<Object?> get props => <Object?>[id];
}

class DeleteTransactionUseCase
    extends UseCase<FinanceRecords, DeleteTransactionParams> {
  DeleteTransactionUseCase(this._repository);
  final TransactionsRepository _repository;
  @override
  Future<Either<Failure, FinanceRecords>> call(DeleteTransactionParams params) {
    return _repository.deleteTransaction(params.id);
  }
}
