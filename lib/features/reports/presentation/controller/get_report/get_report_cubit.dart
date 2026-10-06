import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../domain/entities/report_data.dart';
import '../../../domain/usecases/get_report_use_case.dart';

part 'get_report_states.dart';

class GetReportCubit extends Cubit<GetReportState> {
  GetReportCubit(this._useCase) : super(const ApiCallHolding<ReportData>());

  final GetReportUseCase _useCase;

  Future<void> fGetReport(GetReportParams params) async {
    emit(const ApiCallLoading<ReportData>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<ReportData>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<ReportData>(data: data)),
    );
  }
}
