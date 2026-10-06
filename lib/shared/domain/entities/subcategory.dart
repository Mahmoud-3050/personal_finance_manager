import 'package:equatable/equatable.dart';

class Subcategory extends Equatable {
  const Subcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.isActive,
  });

  final String id;
  final String categoryId;
  final String name;
  final bool isActive;

  Subcategory copyWith({String? name, bool? isActive}) {
    return Subcategory(
      id: id,
      categoryId: categoryId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, categoryId, name, isActive];
}
