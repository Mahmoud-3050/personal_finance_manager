import '../../../../core/database/finance_database.dart';
import '../../../../shared/domain/entities/category.dart';

final class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.kind,
    required super.isActive,
  });

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      kind: category.kind,
      isActive: category.isActive,
    );
  }

  factory CategoryModel.fromRow(CategoryRow row) {
    return CategoryModel(
      id: row.id,
      name: row.name,
      kind: CategoryKind.values.byName(row.kind),
      isActive: row.isActive,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: CategoryKind.values.byName(json['kind'] as String),
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'kind': kind.name,
    'is_active': isActive,
  };

  CategoryRowsCompanion toCompanion() {
    return CategoryRowsCompanion.insert(
      id: id,
      name: name,
      kind: kind.name,
      isActive: isActive,
    );
  }
}
