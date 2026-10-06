import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/finance_records.dart';

abstract interface class CategoriesRepository {
  Future<Either<Failure, FinanceRecords>> load();

  Future<Either<Failure, FinanceRecords>> saveCategory({
    required String? id,
    required String? parentId,
    required String name,
    required CategoryKind kind,
  });

  Future<Either<Failure, FinanceRecords>> deactivateCategory(String id);

  Future<Either<Failure, FinanceRecords>> deleteCategory(String id);
}
