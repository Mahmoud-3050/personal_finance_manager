import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/save_category_use_case.dart';

part 'save_category_states.dart';

class SaveCategoryCubit extends Cubit<SaveCategoryState> {
  SaveCategoryCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final SaveCategoryUseCase _useCase;

  Future<void> fSaveCategory(SaveCategoryParams params) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
