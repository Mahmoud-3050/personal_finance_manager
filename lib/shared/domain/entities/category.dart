import 'package:equatable/equatable.dart';

enum CategoryKind { income, expense }

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.kind,
    required this.isActive,
  });

  final String id;
  final String name;
  final CategoryKind kind;
  final bool isActive;

  Category copyWith({String? name, bool? isActive}) {
    return Category(
      id: id,
      name: name ?? this.name,
      kind: kind,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, name, kind, isActive];
}
