import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';

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
                children: <Widget>[
                  _preset(Strings.fenzoDay, _day),
                  _preset(Strings.fenzoWeek, _week),
                  _preset(Strings.fenzoMonth, _month),
                  _preset(Strings.fenzoCustom, _custom),
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
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    children: <Widget>[
                      _moneyTile(Strings.fenzoIncome, data.figures.incomeMinor),
                      _moneyTile(
                        Strings.fenzoExpense,
                        data.figures.expenseMinor,
                      ),
                      _moneyTile(Strings.fenzoNet, data.figures.netMinor),
                      ListTile(
                        title: Text(
                          Strings.fenzoTransactions,
                          style: TextStyles.of(
                            size: 16,
                            weight: FontWeight.w500,
                          ),
                        ),
                        onTap: () => context.push(
                          AppRoutes.transactions,
                          extra: SearchTransactionsParams(range: _range),
                        ),
                      ),
                      for (final CategoryShare share
                          in data.figures.expenseShares)
                        ListTile(
                          title: Text(
                            share.name,
                            style: TextStyles.of(size: 16),
                          ),
                          subtitle: Text(
                            share.percentageLabel,
                            style: TextStyles.of(size: 13),
                          ),
                          trailing: Text(
                            Money(share.amountMinor).format(),
                            style: TextStyles.of(size: 14),
                          ),
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
                        ListTile(
                          contentPadding: EdgeInsetsDirectional.only(
                            start: 32.w,
                            end: 16.w,
                          ),
                          title: Text(
                            child.name,
                            style: TextStyles.of(size: 15),
                          ),
                          subtitle: Text(
                            child.percentageLabel,
                            style: TextStyles.of(size: 13),
                          ),
                          trailing: Text(
                            Money(child.amountMinor).format(),
                            style: TextStyles.of(size: 14),
                          ),
                        ),
                      for (final CategoryShare share
                          in data.figures.incomeShares)
                        ListTile(
                          title: Text(
                            share.name,
                            style: TextStyles.of(size: 16),
                          ),
                          subtitle: Text(
                            share.percentageLabel,
                            style: TextStyles.of(size: 13),
                          ),
                          trailing: Text(
                            Money(share.amountMinor).format(),
                            style: TextStyles.of(size: 14),
                          ),
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
                          in data.figures.accounts)
                        ListTile(
                          title: Text(
                            account.name,
                            style: TextStyles.of(
                              size: 16,
                              weight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '${Strings.fenzoStarting} ${Money(account.startingMinor).format()}\n'
                            '${Strings.fenzoIncome} ${Money(account.incomeMinor).format()}\n'
                            '${Strings.fenzoExpense} ${Money(account.expenseMinor).format()}\n'
                            '${Strings.fenzoTransfersIn} ${Money(account.transfersInMinor).format()}\n'
                            '${Strings.fenzoTransfersOut} ${Money(account.transfersOutMinor).format()}\n'
                            '${Strings.fenzoEnding} ${Money(account.endingMinor).format()}',
                            style: TextStyles.of(size: 13),
                          ),
                        ),
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

  Widget _preset(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label, style: TextStyles.of(size: 14)),
    );
  }

  Widget _moneyTile(String title, int amountMinor) {
    return ListTile(
      title: Text(
        title,
        style: TextStyles.of(size: 16, weight: FontWeight.w500),
      ),
      trailing: Text(
        Money(amountMinor).format(),
        style: TextStyles.of(size: 14),
      ),
    );
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
