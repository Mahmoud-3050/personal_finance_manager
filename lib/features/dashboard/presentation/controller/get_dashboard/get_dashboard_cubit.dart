import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/dashboard_data.dart';
import '../../../domain/usecases/get_dashboard_use_case.dart';

part 'get_dashboard_states.dart';

class GetDashboardCubit extends Cubit<GetDashboardState> {
  GetDashboardCubit(this._useCase)
    : super(const ApiCallHolding<DashboardData>());

  final GetDashboardUseCase _useCase;

  Future<void> fGetDashboard() async {
    emit(const ApiCallLoading<DashboardData>());
    final result = await _useCase(const NoParams());
    result.fold(
      (failure) =>
          emit(ApiCallError<DashboardData>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<DashboardData>(data: data)),
    );
  }
}
