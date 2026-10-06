import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/delete_category_use_case.dart';

part 'delete_category_states.dart';

class DeleteCategoryCubit extends Cubit<DeleteCategoryState> {
  DeleteCategoryCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final DeleteCategoryUseCase _useCase;

  Future<void> fDeleteCategory(DeleteCategoryParams params) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
