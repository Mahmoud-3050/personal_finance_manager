import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../transactions/domain/usecases/search_transactions_use_case.dart';

DateRange currentMonth() => CalendarDate.monthContaining(CalendarDate.today());

void openSearch(BuildContext context, SearchTransactionsParams query) {
  context.push(AppRoutes.transactions, extra: query);
}

void openMonth(
  BuildContext context, {
  MoneyTransactionType? type,
  String? accountId,
  String? categoryId,
  bool excludeTransfers = false,
}) {
  openSearch(
    context,
    SearchTransactionsParams(
      range: currentMonth(),
      type: type,
      accountId: accountId,
      categoryId: categoryId,
      excludeTransfers: excludeTransfers,
    ),
  );
}
