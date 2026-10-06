import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/finance_records.dart';
import '../repositories/categories_repository.dart';

class DeleteCategoryParams extends Params {
  const DeleteCategoryParams(this.id, {this.cancellation});
  final String id;
  @override
  final Object? cancellation;
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'id': id};
  @override
  List<Object?> get props => <Object?>[id];
}

class DeleteCategoryUseCase
    extends UseCase<FinanceRecords, DeleteCategoryParams> {
  DeleteCategoryUseCase(this._repository);
  final CategoriesRepository _repository;
  @override
  Future<Either<Failure, FinanceRecords>> call(DeleteCategoryParams params) {
    return _repository.deleteCategory(params.id);
  }
}
