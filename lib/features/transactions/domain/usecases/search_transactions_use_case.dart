import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/finance_records.dart';
import '../repositories/transactions_repository.dart';

class SearchTransactionsParams extends Params {
  const SearchTransactionsParams({
    this.query,
    this.range,
    this.accountId,
    this.type,
    this.categoryId,
    this.subcategoryId,
    this.excludeTransfers = false,
    this.cancellation,
  });
  final String? query;
  final DateRange? range;
  final String? accountId;
  final MoneyTransactionType? type;
  final String? categoryId;
  final String? subcategoryId;
  final bool excludeTransfers;
  @override
  final Object? cancellation;
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'query': query};
  @override
  List<Object?> get props => <Object?>[
    query,
    range,
    accountId,
    type,
    categoryId,
    subcategoryId,
    excludeTransfers,
  ];
}

class SearchTransactionsUseCase
    extends UseCase<List<MoneyTransaction>, SearchTransactionsParams> {
  SearchTransactionsUseCase(this._repository);
  final TransactionsRepository _repository;
  @override
  Future<Either<Failure, List<MoneyTransaction>>> call(
    SearchTransactionsParams params,
  ) async {
    final Either<Failure, FinanceRecords> loaded = await _repository.load();
    return loaded.map(
      (FinanceRecords book) => book.search(
        query: params.query,
        range: params.range,
        accountId: params.accountId,
        type: params.type,
        categoryId: params.categoryId,
        subcategoryId: params.subcategoryId,
        excludeTransfers: params.excludeTransfers,
      ),
    );
  }
}
