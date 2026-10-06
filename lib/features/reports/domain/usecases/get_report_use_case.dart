import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../entities/report_data.dart';
import '../repositories/reports_repository.dart';

class GetReportParams extends Params {
  const GetReportParams(this.range, {this.cancellation});

  final DateRange range;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'start': range.start.toIso(),
    'end': range.end.toIso(),
  };

  @override
  List<Object?> get props => <Object?>[range];
}

class GetReportUseCase extends UseCase<ReportData, GetReportParams> {
  GetReportUseCase(this._repository);

  final ReportsRepository _repository;

  @override
  Future<Either<Failure, ReportData>> call(GetReportParams params) {
    return _repository.getReport(range: params.range);
  }
}
