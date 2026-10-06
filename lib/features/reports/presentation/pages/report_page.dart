import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../shared/domain/entities/account_period_figures.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/entities/category_share.dart';
import '../../../../shared/domain/entities/money.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/widgets/finance/balance_flow_stat.dart';
import '../../../../shared/widgets/finance/balance_hero_body.dart';
import '../../../../shared/widgets/finance/gradient_panel.dart';
import '../../../../shared/widgets/finance_ledger.dart';
import '../../../transactions/domain/usecases/search_transactions_use_case.dart';
import '../../../transactions/presentation/controller/delete_transaction/delete_transaction_cubit.dart';
import '../../../transactions/presentation/controller/save_expense/save_expense_cubit.dart';
import '../../../transactions/presentation/controller/save_income/save_income_cubit.dart';
import '../../../transactions/presentation/controller/save_transfer/save_transfer_cubit.dart';
import '../../../transactions/presentation/controller/update_transaction/update_transaction_cubit.dart';
import '../../domain/entities/report_data.dart';
import '../../domain/usecases/get_report_use_case.dart';
import '../controller/get_report/get_report_cubit.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateRange _range = CalendarDate.monthContaining(CalendarDate.today());
  String? _rangeError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<UpdateTransactionCubit, ApiCallState<FinanceRecords>>(
          listener: _reloadReport,
        ),
        BlocListener<DeleteTransactionCubit, ApiCallState<FinanceRecords>>(
          listener: _reloadReport,
        ),
        BlocListener<SaveIncomeCubit, ApiCallState<FinanceRecords>>(
          listener: _reloadReport,
        ),
        BlocListener<SaveExpenseCubit, ApiCallState<FinanceRecords>>(
          listener: _reloadReport,
        ),
        BlocListener<SaveTransferCubit, ApiCallState<FinanceRecords>>(
          listener: _reloadReport,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Strings.fenzoReports,
            style: TextStyles.of(size: 18, weight: FontWeight.w600),
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: <Widget>[
                  _preset(Strings.fenzoDay, _day, _isDay),
                  _preset(Strings.fenzoWeek, _week, _isWeek),
                  _preset(Strings.fenzoMonth, _month, _isMonth),
                  _preset(Strings.fenzoCustom, _custom, !_isDay && !_isWeek && !_isMonth),
                ],
              ),
            ),
            if (_rangeError != null)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(_rangeError!, style: TextStyles.of(size: 14)),
              ),
            Expanded(
              child: BlocBuilder<GetReportCubit, ApiCallState<ReportData>>(
                builder: (BuildContext context, ApiCallState<ReportData> state) {
                  if (state is! ApiCallSuccess<ReportData>) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final ReportData data = state.data;
                  return ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                        child: GradientPanel(
                          child: BalanceHeroBody(
                            label: Strings.fenzoNet,
                            amount: Money(data.figures.netMinor).format(),
                            amountColor: data.figures.netMinor < 0
                                ? context.colors.error
                                : context.colors.success,
                            footer: BalanceFlowStat(
                              incomeLabel: Strings.fenzoIncome,
                              incomeAmount: Money(
                                data.figures.incomeMinor,
                              ).format(),
                              expenseLabel: Strings.fenzoExpense,
                              expenseAmount: Money(
                                data.figures.expenseMinor,
                              ).format(),
                            ),
                          ),
                        ),
                      ),
                      FinanceLedgerRow(
                        title: Strings.fenzoTransactions,
                        onTap: () => context.push(
                          AppRoutes.transactions,
                          extra: SearchTransactionsParams(range: _range),
                        ),
                      ),
                      if (data.figures.expenseShares.isNotEmpty)
                        FinanceSectionTitle(Strings.fenzoExpense),
                      for (final CategoryShare share
                          in data.figures.expenseShares)
                        FinanceLedgerRow(
                          title: share.name,
                          subtitle: share.percentageLabel,
                          amount: Money(share.amountMinor).format(),
                          amountColor: context.colors.error,
                          onTap: () => context.push(
                            AppRoutes.transactions,
                            extra: SearchTransactionsParams(
                              range: _range,
                              type: MoneyTransactionType.expense,
                              categoryId: share.id,
                            ),
                          ),
                        ),
                      for (final CategoryShare child
                          in data.figures.expenseShares.expand(
                            (CategoryShare share) => share.children,
                          ))
                        FinanceLedgerRow(
                          indent: 16.w,
                          title: child.name,
                          subtitle: child.percentageLabel,
                          amount: Money(child.amountMinor).format(),
                          amountColor: context.colors.error,
                        ),
                      if (data.figures.incomeShares.isNotEmpty)
                        FinanceSectionTitle(Strings.fenzoIncome),
                      for (final CategoryShare share in data.figures.incomeShares)
                        FinanceLedgerRow(
                          title: share.name,
                          subtitle: share.percentageLabel,
                          amount: Money(share.amountMinor).format(),
                          amountColor: context.colors.success,
                          onTap: () => context.push(
                            AppRoutes.transactions,
                            extra: SearchTransactionsParams(
                              range: _range,
                              type: MoneyTransactionType.income,
                              categoryId: share.id,
                            ),
                          ),
                        ),
                      for (final AccountPeriodFigures account
                          in data.figures.accounts) ...<Widget>[
                        FinanceSectionTitle(account.name),
                        FinanceLedgerRow(
                          title: Strings.fenzoStarting,
                          amount: Money(account.startingMinor).format(),
                        ),
                        FinanceLedgerRow(
                          title: Strings.fenzoIncome,
                          amount: Money(account.incomeMinor).format(),
                          amountColor: context.colors.success,
                        ),
                        FinanceLedgerRow(
                          title: Strings.fenzoExpense,
                          amount: Money(account.expenseMinor).format(),
                          amountColor: context.colors.error,
                        ),
                        FinanceLedgerRow(
                          title: Strings.fenzoTransfersIn,
                          amount: Money(account.transfersInMinor).format(),
                        ),
                        FinanceLedgerRow(
                          title: Strings.fenzoTransfersOut,
                          amount: Money(account.transfersOutMinor).format(),
                        ),
                        FinanceLedgerRow(
                          title: Strings.fenzoEnding,
                          amount: Money(account.endingMinor).format(),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isDay =>
      _range == DateRange(CalendarDate.today(), CalendarDate.today());

  bool get _isWeek =>
      _range == CalendarDate.weekContaining(CalendarDate.today());

  bool get _isMonth =>
      _range == CalendarDate.monthContaining(CalendarDate.today());

  Widget _preset(String label, VoidCallback onPressed, bool selected) {
    final ThemeColors colors = context.colors;
    final Text labelText = Text(
      label,
      maxLines: 1,
      style: TextStyles.of(
        size: 14,
        weight: FontWeight.w500,
        color: selected ? colors.onPrimary : colors.textPrimary,
      ),
    );
    if (selected) {
      return FilledButton(onPressed: onPressed, child: labelText);
    }
    return OutlinedButton(onPressed: onPressed, child: labelText);
  }

  void _day() => _apply(DateRange(CalendarDate.today(), CalendarDate.today()));

  void _week() => _apply(CalendarDate.weekContaining(CalendarDate.today()));

  void _month() => _apply(CalendarDate.monthContaining(CalendarDate.today()));

  Future<void> _custom() async {
    final DateTime? start = await showDatePicker(
      context: context,
      initialDate: _range.start.toDateTime(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (start == null || !mounted) {
      return;
    }
    final DateTime? end = await showDatePicker(
      context: context,
      initialDate: _range.end.toDateTime(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (end == null || !mounted) {
      return;
    }
    final DateRange? range = DateRange.tryCreate(
      CalendarDate.fromDateTime(start),
      CalendarDate.fromDateTime(end),
    );
    if (range == null) {
      setState(() => _rangeError = Strings.fenzoInvalidRange);
      return;
    }
    _apply(range);
  }

  void _apply(DateRange range) {
    setState(() {
      _range = range;
      _rangeError = null;
    });
    _load();
  }

  void _reloadReport(BuildContext context, ApiCallState<FinanceRecords> state) {
    if (state is ApiCallSuccess<FinanceRecords>) {
      _load();
    }
  }

  void _load() {
    context.read<GetReportCubit>().fGetReport(GetReportParams(_range));
  }
}
