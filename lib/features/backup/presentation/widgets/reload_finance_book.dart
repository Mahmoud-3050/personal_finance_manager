import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../accounts/presentation/controller/get_accounts/get_accounts_cubit.dart';
import '../../../categories/presentation/controller/get_categories/get_categories_cubit.dart';
import '../../../dashboard/presentation/controller/get_dashboard/get_dashboard_cubit.dart';
import '../../../reports/domain/usecases/get_report_use_case.dart';
import '../../../reports/presentation/controller/get_report/get_report_cubit.dart';

void reloadFinanceBook(BuildContext context) {
  context.read<GetAccountsCubit>().fGetAccounts();
  context.read<GetCategoriesCubit>().fGetCategories();
  context.read<GetDashboardCubit>().fGetDashboard();
  context.read<GetReportCubit>().fGetReport(
    GetReportParams(CalendarDate.monthContaining(CalendarDate.today())),
  );
}
