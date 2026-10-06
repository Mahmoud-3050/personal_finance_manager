import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/entities/subcategory.dart';
import 'transaction_filter_fields.dart';

class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({
    required this.accounts,
    required this.categories,
    required this.subcategories,
    required this.accountId,
    required this.type,
    required this.categoryId,
    required this.subcategoryId,
    required this.onChanged,
    super.key,
  });

  final List<Account> accounts;
  final List<Category> categories;
  final List<Subcategory> subcategories;
  final String? accountId;
  final MoneyTransactionType? type;
  final String? categoryId;
  final String? subcategoryId;
  final void Function(TransactionFilterValue value) onChanged;

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class TransactionFilterValue {
  const TransactionFilterValue({
    required this.accountId,
    required this.type,
    required this.categoryId,
    required this.subcategoryId,
  });

  final String? accountId;
  final MoneyTransactionType? type;
  final String? categoryId;
  final String? subcategoryId;
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late String? _accountId = widget.accountId;
  late MoneyTransactionType? _type = widget.type;
  late String? _categoryId = widget.categoryId;
  late String? _subcategoryId = widget.subcategoryId;

  @override
  Widget build(BuildContext context) {
    final List<Subcategory> visible = widget.subcategories
        .where(
          (Subcategory item) =>
              _categoryId == null || item.categoryId == _categoryId,
        )
        .toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AccountFilter(
            accounts: widget.accounts,
            value: _accountId,
            onChanged: (String? value) {
              setState(() => _accountId = value);
              _emit();
            },
          ),
          SizedBox(height: 12.h),
          TypeFilter(
            value: _type,
            onChanged: (MoneyTransactionType? value) {
              setState(() => _type = value);
              _emit();
            },
          ),
          SizedBox(height: 12.h),
          CategoryFilter(
            categories: widget.categories,
            value: _categoryId,
            onChanged: (String? value) {
              setState(() {
                _categoryId = value;
                _subcategoryId = null;
              });
              _emit();
            },
          ),
          SizedBox(height: 12.h),
          SubcategoryFilter(
            subcategories: visible,
            value: _subcategoryId,
            onChanged: (String? value) {
              setState(() => _subcategoryId = value);
              _emit();
            },
          ),
        ],
      ),
    );
  }

  void _emit() {
    widget.onChanged(
      TransactionFilterValue(
        accountId: _accountId,
        type: _type,
        categoryId: _categoryId,
        subcategoryId: _subcategoryId,
      ),
    );
  }
}
