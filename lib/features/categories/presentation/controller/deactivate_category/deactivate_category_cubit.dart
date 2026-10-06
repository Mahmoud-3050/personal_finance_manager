import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/deactivate_category_use_case.dart';

part 'deactivate_category_states.dart';

class DeactivateCategoryCubit extends Cubit<DeactivateCategoryState> {
  DeactivateCategoryCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final DeactivateCategoryUseCase _useCase;

  Future<void> fDeactivateCategory(DeactivateCategoryParams params) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
