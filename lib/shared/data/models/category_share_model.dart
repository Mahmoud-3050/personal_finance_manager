import '../../domain/entities/category_share.dart';

final class CategoryShareModel extends CategoryShare {
  const CategoryShareModel({
    required super.id,
    required super.name,
    required super.amountMinor,
    required super.percentageLabel,
    super.children,
  });

  factory CategoryShareModel.fromEntity(CategoryShare share) {
    return CategoryShareModel(
      id: share.id,
      name: share.name,
      amountMinor: share.amountMinor,
      percentageLabel: share.percentageLabel,
      children: share.children.map(CategoryShareModel.fromEntity).toList(),
    );
  }

  factory CategoryShareModel.fromJson(Map<String, dynamic> json) {
    final List<Object?> rawChildren =
        json['children'] as List<Object?>? ?? const <Object?>[];
    return CategoryShareModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amountMinor: json['amount_minor'] as int,
      percentageLabel: json['percentage_label'] as String,
      children: rawChildren
          .map(
            (Object? child) =>
                CategoryShareModel.fromJson(child! as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'amount_minor': amountMinor,
    'percentage_label': percentageLabel,
    'children': children
        .map(
          (CategoryShare child) =>
              CategoryShareModel.fromEntity(child).toJson(),
        )
        .toList(),
  };
}
