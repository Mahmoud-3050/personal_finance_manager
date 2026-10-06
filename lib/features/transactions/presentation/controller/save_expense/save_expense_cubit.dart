import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/save_expense_use_case.dart';

part 'save_expense_states.dart';

class SaveExpenseCubit extends Cubit<SaveExpenseState> {
  SaveExpenseCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final SaveExpenseUseCase _useCase;

  Future<void> fSaveExpense(SaveExpenseParams params) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
