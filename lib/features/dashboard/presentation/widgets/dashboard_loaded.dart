import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../core/presentation/api_call_state.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../categories/presentation/controller/get_categories/get_categories_cubit.dart';
import '../../domain/entities/dashboard_data.dart';
import 'dashboard_accounts.dart';
import 'dashboard_activity.dart';
import 'dashboard_balance.dart';

class DashboardLoaded extends StatelessWidget {
  const DashboardLoaded({required this.data, super.key});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: <Widget>[
        DashboardBalance(data: data),
        const DashboardGap(),
        const DashboardAction(),
        const DashboardGap(),
        DashboardShares(data: data),
        DashboardRecent(data: data, book: _categories(context)),
      ],
    );
  }

  FinanceRecords? _categories(BuildContext context) {
    final ApiCallState<FinanceRecords> state = context
        .watch<GetCategoriesCubit>()
        .state;
    return state is ApiCallSuccess<FinanceRecords> ? state.data : null;
  }
}
