import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../entities/report_data.dart';

abstract interface class ReportsRepository {
  Future<Either<Failure, ReportData>> getReport({required DateRange range});
}
