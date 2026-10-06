import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/entities/category_share.dart';
import '../../../../shared/domain/entities/money.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/entities/subcategory.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/widgets/finance/movement_mark.dart';
import '../../../../shared/widgets/finance/movement_style.dart';
import '../../../../shared/widgets/finance/summary_card.dart';
import '../../../../shared/widgets/finance_ledger.dart';
import '../../domain/entities/dashboard_data.dart';
import 'dashboard_navigation.dart';

class DashboardShares extends StatelessWidget {
  const DashboardShares({required this.data, super.key});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final List<CategoryShare> shares = data.expenseShares.toList()
      ..sort(
        (CategoryShare a, CategoryShare b) =>
            b.amountMinor.compareTo(a.amountMinor),
      );
    if (shares.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FinanceSectionTitle(Strings.fenzoExpense),
        for (final CategoryShare share in shares)
          SummaryCard(
            title: share.name,
            subtitle: share.percentageLabel,
            amount: Money(share.amountMinor).format(),
            amountColor: context.colors.error,
            leading: MovementMark(
              type: MoneyTransactionType.expense,
              categoryName: share.name,
            ),
            onTap: () => openMonth(
              context,
              type: MoneyTransactionType.expense,
              categoryId: share.id,
            ),
          ),
      ],
    );
  }
}

class DashboardRecent extends StatelessWidget {
  const DashboardRecent({required this.data, required this.book, super.key});

  final DashboardData data;
  final FinanceRecords? book;

  @override
  Widget build(BuildContext context) {
    if (data.recent.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FinanceSectionTitle(Strings.fenzoTransactions),
        for (final MoneyTransaction item in data.recent)
          _RecentCard(item: item, book: book),
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.item, required this.book});

  final MoneyTransaction item;
  final FinanceRecords? book;

  @override
  Widget build(BuildContext context) {
    final String? category = _categoryName(book, item);
    return SummaryCard(
      title: item.description ?? item.notes ?? _label(item.type),
      subtitle: _subtitle(item, book),
      amount: Money(item.amountMinor).format(),
      amountColor: movementTone(context.colors, item.type),
      leading: MovementMark(type: item.type, categoryName: category),
    );
  }
}

String _label(MoneyTransactionType type) => switch (type) {
  MoneyTransactionType.income => Strings.fenzoIncome,
  MoneyTransactionType.expense => Strings.fenzoExpense,
  MoneyTransactionType.transfer => Strings.fenzoTransfer,
};

String? _categoryName(FinanceRecords? book, MoneyTransaction item) {
  return book?.categories
      .where((Category category) => category.id == item.categoryId)
      .map((Category category) => category.name)
      .firstOrNull;
}

String _subtitle(MoneyTransaction item, FinanceRecords? book) {
  final String? category = _categoryName(book, item);
  final String? subcategory = book?.subcategories
      .where((Subcategory subcategory) => subcategory.id == item.subcategoryId)
      .map((Subcategory subcategory) => subcategory.name)
      .firstOrNull;
  final String names = <String?>[
    category,
    subcategory,
  ].whereType<String>().join(' / ');
  if (names.isEmpty) {
    return item.date.toIso();
  }
  return '${item.date.toIso()} · $names';
}
