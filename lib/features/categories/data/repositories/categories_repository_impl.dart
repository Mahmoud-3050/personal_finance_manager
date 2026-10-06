import 'package:either/either.dart';

import '../../../../core/data/repository_guard.dart';
import '../../../../core/database/finance_command.dart';
import '../../../../core/database/finance_store.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../domain/repositories/categories_repository.dart';

class CategoriesRepositoryImpl
    with RepositoryGuard, FinanceCommand
    implements CategoriesRepository {
  CategoriesRepositoryImpl(this.financeStore);

  @override
  final FinanceStore financeStore;

  @override
  Future<Either<Failure, FinanceRecords>> load() =>
      readRecords('loadCategories');

  @override
  Future<Either<Failure, FinanceRecords>> saveCategory({
    required String? id,
    required String? parentId,
    required String name,
    required CategoryKind kind,
  }) {
    return changeRecords(
      'saveCategory',
      (FinanceRecords records) => records.saveCategory(
        id: id,
        parentId: parentId,
        name: name,
        kind: kind,
      ),
    );
  }

  @override
  Future<Either<Failure, FinanceRecords>> deactivateCategory(String id) {
    return changeRecords(
      'deactivateCategory',
      (FinanceRecords records) => records.deactivateCategory(id),
    );
  }

  @override
  Future<Either<Failure, FinanceRecords>> deleteCategory(String id) {
    return changeRecords(
      'deleteCategory',
      (FinanceRecords records) => records.deleteCategory(id),
    );
  }
}
