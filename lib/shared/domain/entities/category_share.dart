import 'package:equatable/equatable.dart';

class CategoryShare extends Equatable {
  const CategoryShare({
    required this.id,
    required this.name,
    required this.amountMinor,
    required this.percentageLabel,
    this.children = const <CategoryShare>[],
  });

  final String id;
  final String name;
  final int amountMinor;
  final String percentageLabel;
  final List<CategoryShare> children;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    amountMinor,
    percentageLabel,
    children,
  ];
}
