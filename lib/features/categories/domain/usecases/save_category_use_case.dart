import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/finance_records.dart';
import '../repositories/categories_repository.dart';

class SaveCategoryParams extends Params {
  const SaveCategoryParams({
    required this.name,
    required this.kind,
    this.id,
    this.parentId,
    this.cancellation,
  });
  final String? id;
  final String? parentId;
  final String name;
  final CategoryKind kind;
  @override
  final Object? cancellation;
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'name': name};
  @override
  List<Object?> get props => <Object?>[id, parentId, name, kind];
}

class SaveCategoryUseCase extends UseCase<FinanceRecords, SaveCategoryParams> {
  SaveCategoryUseCase(this._repository);
  final CategoriesRepository _repository;
  @override
  Future<Either<Failure, FinanceRecords>> call(SaveCategoryParams params) {
    return _repository.saveCategory(
      id: params.id,
      parentId: params.parentId,
      name: params.name,
      kind: params.kind,
    );
  }
}
