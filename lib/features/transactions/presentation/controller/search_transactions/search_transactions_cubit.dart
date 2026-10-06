import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/entities/money_transaction.dart';
import '../../../domain/usecases/search_transactions_use_case.dart';

part 'search_transactions_states.dart';

class SearchTransactionsCubit extends Cubit<SearchTransactionsState> {
  SearchTransactionsCubit(this._useCase)
    : super(const ApiCallHolding<List<MoneyTransaction>>());

  final SearchTransactionsUseCase _useCase;

  Future<void> fSearchTransactions(SearchTransactionsParams params) async {
    emit(const ApiCallLoading<List<MoneyTransaction>>());
    final result = await _useCase(params);
    result.fold(
      (failure) => emit(
        ApiCallError<List<MoneyTransaction>>(message: failure.message ?? ''),
      ),
      (data) => emit(ApiCallSuccess<List<MoneyTransaction>>(data: data)),
    );
  }
}
