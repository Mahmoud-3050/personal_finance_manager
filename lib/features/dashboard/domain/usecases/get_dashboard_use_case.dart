import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardUseCase extends UseCase<DashboardData, NoParams> {
  GetDashboardUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, DashboardData>> call(NoParams params) {
    return _repository.getDashboard();
  }
}
