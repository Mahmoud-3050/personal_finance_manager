import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/language/strings.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../accounts/domain/entities/account_list_data.dart';
import '../../../accounts/presentation/controller/get_accounts/get_accounts_cubit.dart';

class DashboardAction extends StatelessWidget {
  const DashboardAction({super.key});

  @override
  Widget build(BuildContext context) {
    final bool hasAccounts = _hasAccounts(context);
    return AppElevatedButton(
      width: double.infinity,
      text: hasAccounts ? Strings.fenzoAddTransaction : Strings.fenzoEmpty,
      onPressed: () => context.push(
        hasAccounts ? AppRoutes.transactionForm : AppRoutes.accountForm,
      ),
    );
  }

  bool _hasAccounts(BuildContext context) {
    final ApiCallState<AccountListData> accounts = context
        .watch<GetAccountsCubit>()
        .state;
    return accounts is ApiCallSuccess<AccountListData> &&
        accounts.data.records.accounts.isNotEmpty;
  }
}
