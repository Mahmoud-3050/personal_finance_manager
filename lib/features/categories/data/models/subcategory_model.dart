import '../../../../core/database/finance_database.dart';
import '../../../../shared/domain/entities/subcategory.dart';

final class SubcategoryModel extends Subcategory {
  const SubcategoryModel({
    required super.id,
    required super.categoryId,
    required super.name,
    required super.isActive,
  });

  factory SubcategoryModel.fromEntity(Subcategory subcategory) {
    return SubcategoryModel(
      id: subcategory.id,
      categoryId: subcategory.categoryId,
      name: subcategory.name,
      isActive: subcategory.isActive,
    );
  }

  factory SubcategoryModel.fromRow(SubcategoryRow row) {
    return SubcategoryModel(
      id: row.id,
      categoryId: row.categoryId,
      name: row.name,
      isActive: row.isActive,
    );
  }

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'category_id': categoryId,
    'name': name,
    'is_active': isActive,
  };

  SubcategoryRowsCompanion toCompanion() {
    return SubcategoryRowsCompanion.insert(
      id: id,
      categoryId: categoryId,
      name: name,
      isActive: isActive,
    );
  }
}
