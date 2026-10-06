import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/get_categories_use_case.dart';

part 'get_categories_states.dart';

class GetCategoriesCubit extends Cubit<GetCategoriesState> {
  GetCategoriesCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final GetCategoriesUseCase _useCase;

  Future<void> fGetCategories() async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(const NoParams());
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
