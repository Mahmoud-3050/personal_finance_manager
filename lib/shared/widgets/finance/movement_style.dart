import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

import '../../domain/entities/money_transaction.dart';

Color movementTone(ThemeColors colors, MoneyTransactionType type) {
  return switch (type) {
    MoneyTransactionType.income => colors.success,
    MoneyTransactionType.expense => colors.error,
    MoneyTransactionType.transfer => colors.textSecondary,
  };
}

IconData movementIcon(MoneyTransactionType type, String? categoryName) {
  final String name = (categoryName ?? '').toLowerCase();
  for (final (IconData icon, List<String> words) in _categoryIcons) {
    if (words.any(name.contains)) {
      return icon;
    }
  }
  return switch (type) {
    MoneyTransactionType.income => Icons.south_west_rounded,
    MoneyTransactionType.expense => Icons.north_east_rounded,
    MoneyTransactionType.transfer => Icons.swap_horiz_rounded,
  };
}

const List<(IconData, List<String>)> _categoryIcons =
    <(IconData, List<String>)>[
      (Icons.shopping_bag_outlined, <String>['shop', 'grocery', 'market', 'تسوق', 'بقال']),
      (Icons.receipt_long_outlined, <String>['bill', 'util', 'فاتور']),
      (Icons.restaurant_outlined, <String>['din', 'food', 'cafe', 'restaurant', 'مطعم', 'طعام']),
      (Icons.directions_car_outlined, <String>['transport', 'fuel', 'uber', 'مواصل', 'بنزين']),
      (Icons.favorite_outline, <String>['health', 'medic', 'صحة', 'دواء']),
      (Icons.payments_outlined, <String>['salary', 'payroll', 'راتب']),
      (Icons.home_outlined, <String>['rent', 'home', 'إيجار', 'منزل']),
    ];
