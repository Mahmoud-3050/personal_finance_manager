import 'package:flutter/material.dart';

import '../../../../config/language/strings.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/entities/subcategory.dart';
import '../../../../shared/widgets/app_dropdown.dart';

class AccountFilter extends StatelessWidget {
  const AccountFilter({
    required this.accounts,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<Account> accounts;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppDropdown<String>(
      value: value,
      values: accounts.map((Account item) => item.id).toList(),
      names: accounts.map((Account item) => item.name).toList(),
      hintText: '',
      labelText: Strings.fenzoAccount,
      isOptional: true,
      onChanged: onChanged,
    );
  }
}

class TypeFilter extends StatelessWidget {
  const TypeFilter({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final MoneyTransactionType? value;
  final ValueChanged<MoneyTransactionType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppDropdown<MoneyTransactionType>(
      value: value,
      values: MoneyTransactionType.values,
      names: MoneyTransactionType.values.map(_label).toList(),
      hintText: '',
      labelText: Strings.fenzoTransfer,
      isOptional: true,
      onChanged: onChanged,
    );
  }

  String _label(MoneyTransactionType type) => switch (type) {
    MoneyTransactionType.income => Strings.fenzoIncome,
    MoneyTransactionType.expense => Strings.fenzoExpense,
    MoneyTransactionType.transfer => Strings.fenzoTransfer,
  };
}

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    required this.categories,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<Category> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppDropdown<String>(
      value: value,
      values: categories.map((Category item) => item.id).toList(),
      names: categories.map((Category item) => item.name).toList(),
      hintText: '',
      labelText: Strings.fenzoCategory,
      isOptional: true,
      onChanged: onChanged,
    );
  }
}

class SubcategoryFilter extends StatelessWidget {
  const SubcategoryFilter({
    required this.subcategories,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<Subcategory> subcategories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppDropdown<String>(
      value: value,
      values: subcategories.map((Subcategory item) => item.id).toList(),
      names: subcategories.map((Subcategory item) => item.name).toList(),
      hintText: '',
      labelText: Strings.fenzoSubcategory,
      isOptional: true,
      onChanged: onChanged,
    );
  }
}
