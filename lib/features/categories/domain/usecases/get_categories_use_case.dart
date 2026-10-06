import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/finance_records.dart';
import '../repositories/categories_repository.dart';

class GetCategoriesUseCase extends UseCase<FinanceRecords, NoParams> {
  GetCategoriesUseCase(this._repository);
  final CategoriesRepository _repository;
  @override
  Future<Either<Failure, FinanceRecords>> call(NoParams params) =>
      _repository.load();
}
