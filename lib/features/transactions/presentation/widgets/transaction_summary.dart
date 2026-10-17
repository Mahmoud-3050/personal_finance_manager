import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/entities/money.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/entities/subcategory.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/widgets/finance/movement_mark.dart';
import '../../../../shared/widgets/finance/movement_style.dart';
import '../../../../shared/widgets/finance/summary_card.dart';

class TransactionSummary extends StatelessWidget {
  const TransactionSummary({
    required this.item,
    required this.book,
    this.onTap,
    this.trailing,
    this.showFeeAsAmount = false,
    super.key,
  });

  final MoneyTransaction item;
  final FinanceRecords? book;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showFeeAsAmount;

  @override
  Widget build(BuildContext context) {
    final String? category = _name(book?.categories, item.categoryId);
    return SummaryCard(
      title: item.description ?? item.notes ?? _typeLabel(item.type),
      subtitle: _subtitle(
        item,
        book,
        category,
        hideFee: showFeeAsAmount,
      ),
      amount: Money(
        showFeeAsAmount ? item.commissionMinor : item.amountMinor,
      ).format(),
      amountColor: movementTone(context.colors, item.type),
      leading: MovementMark(type: item.type, categoryName: category),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

String _typeLabel(MoneyTransactionType type) => switch (type) {
  MoneyTransactionType.income => Strings.fenzoIncome,
  MoneyTransactionType.expense => Strings.fenzoExpense,
  MoneyTransactionType.transfer => Strings.fenzoTransfer,
};

String? _name(List<Category>? categories, String? id) {
  return categories
      ?.where((Category category) => category.id == id)
      .map((Category category) => category.name)
      .firstOrNull;
}

String _subtitle(
  MoneyTransaction item,
  FinanceRecords? book,
  String? category, {
  required bool hideFee,
}) {
  final String? subcategory = book?.subcategories
      .where((Subcategory value) => value.id == item.subcategoryId)
      .map((Subcategory value) => value.name)
      .firstOrNull;
  final String names = <String?>[
    category,
    subcategory,
  ].whereType<String>().join(' / ');
  final String fee = item.commissionMinor > 0 && !hideFee
      ? '${Strings.fenzoTransferCommission} ${Money(item.commissionMinor).format()}'
      : '';
  return <String>[
    item.date.toIso(),
    if (names.isNotEmpty) names,
    if (fee.isNotEmpty) fee,
  ].join(' · ');
}
