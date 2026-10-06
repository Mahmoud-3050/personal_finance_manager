import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_data.dart';

abstract interface class DashboardRepository {
  Future<Either<Failure, DashboardData>> getDashboard();
}
