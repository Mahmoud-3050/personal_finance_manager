import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/finance_records.dart';
import '../repositories/transactions_repository.dart';

class SaveIncomeParams extends Params {
  const SaveIncomeParams({
    required this.amountMinor,
    required this.date,
    this.id,
    this.accountId,
    this.categoryId,
    this.subcategoryId,
    this.fromAccountId,
    this.toAccountId,
    this.description,
    this.notes,
    this.cancellation,
  });
  final String? id;
  final int amountMinor;
  final CalendarDate date;
  final String? accountId;
  final String? categoryId;
  final String? subcategoryId;
  final String? fromAccountId;
  final String? toAccountId;
  final String? description;
  final String? notes;
  @override
  final Object? cancellation;
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'amount': amountMinor};
  @override
  List<Object?> get props => <Object?>[
    id,
    amountMinor,
    date,
    accountId,
    categoryId,
  ];
}

class SaveIncomeUseCase extends UseCase<FinanceRecords, SaveIncomeParams> {
  SaveIncomeUseCase(this._repository);
  final TransactionsRepository _repository;
  @override
  Future<Either<Failure, FinanceRecords>> call(SaveIncomeParams params) {
    return _repository.saveMovement(
      id: params.id,
      type: MoneyTransactionType.income,
      amountMinor: params.amountMinor,
      date: params.date,
      accountId: params.accountId,
      categoryId: params.categoryId,
      subcategoryId: params.subcategoryId,
      fromAccountId: params.fromAccountId,
      toAccountId: params.toAccountId,
      description: params.description,
      notes: params.notes,
    );
  }
}
