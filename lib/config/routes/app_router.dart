import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/feature_scope.dart';
import '../../features/accounts/accounts_injection.dart';
import '../../features/categories/categories_injection.dart';
import '../../features/dashboard/dashboard_injection.dart';
import '../../features/reports/reports_injection.dart';
import '../../features/transactions/transactions_injection.dart';
import '../../shared/domain/entities/account.dart';
import '../../shared/domain/entities/calendar_date.dart';
import '../../shared/domain/entities/money_transaction.dart';
import '../../features/transactions/domain/usecases/search_transactions_use_case.dart';
import '../../features/accounts/presentation/controller/deactivate_account/deactivate_account_cubit.dart';
import '../../features/accounts/presentation/controller/delete_account/delete_account_cubit.dart';
import '../../features/accounts/presentation/controller/get_accounts/get_accounts_cubit.dart';
import '../../features/accounts/presentation/controller/reactivate_account/reactivate_account_cubit.dart';
import '../../features/categories/presentation/controller/deactivate_category/deactivate_category_cubit.dart';
import '../../features/categories/presentation/controller/delete_category/delete_category_cubit.dart';
import '../../features/categories/presentation/controller/get_categories/get_categories_cubit.dart';
import '../../features/categories/presentation/controller/save_category/save_category_cubit.dart';
import '../../features/dashboard/presentation/controller/get_dashboard/get_dashboard_cubit.dart';
import '../../features/reports/presentation/controller/get_report/get_report_cubit.dart';
import '../../features/accounts/presentation/controller/save_account/save_account_cubit.dart';
import '../../features/transactions/presentation/controller/delete_transaction/delete_transaction_cubit.dart';
import '../../features/transactions/presentation/controller/save_expense/save_expense_cubit.dart';
import '../../features/transactions/presentation/controller/save_income/save_income_cubit.dart';
import '../../features/transactions/presentation/controller/save_transfer/save_transfer_cubit.dart';
import '../../features/transactions/presentation/controller/search_transactions/search_transactions_cubit.dart';
import '../../features/transactions/presentation/controller/update_transaction/update_transaction_cubit.dart';
import '../../features/accounts/presentation/pages/account_form_page.dart';
import '../../features/accounts/presentation/pages/account_list_page.dart';
import '../../features/categories/presentation/pages/category_list_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/reports/presentation/pages/report_page.dart';
import '../../features/transactions/presentation/pages/transaction_form_page.dart';
import '../../features/transactions/presentation/pages/transaction_list_page.dart';
import '../../injection_container.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    redirect: (BuildContext context, GoRouterState state) {
      return null;
    },
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return FeatureScope(
            scopeName: 'finance',
            registrations: const <FeatureRegistration>[
              registerAccounts,
              registerCategories,
              registerTransactions,
              registerDashboard,
              registerReports,
            ],
            child: MultiBlocProvider(
              providers: <BlocProvider<dynamic>>[
                BlocProvider<GetDashboardCubit>(
                  create: (_) =>
                      ServiceLocator.instance<GetDashboardCubit>()
                        ..fGetDashboard(),
                ),
                BlocProvider<GetAccountsCubit>(
                  create: (_) =>
                      ServiceLocator.instance<GetAccountsCubit>()
                        ..fGetAccounts(),
                ),
                BlocProvider<GetCategoriesCubit>(
                  create: (_) =>
                      ServiceLocator.instance<GetCategoriesCubit>()
                        ..fGetCategories(),
                ),
                BlocProvider<GetReportCubit>(
                  create: (_) => ServiceLocator.instance<GetReportCubit>(),
                ),
                BlocProvider<SaveAccountCubit>(
                  create: (_) => ServiceLocator.instance<SaveAccountCubit>(),
                ),
                BlocProvider<DeactivateAccountCubit>(
                  create: (_) =>
                      ServiceLocator.instance<DeactivateAccountCubit>(),
                ),
                BlocProvider<ReactivateAccountCubit>(
                  create: (_) =>
                      ServiceLocator.instance<ReactivateAccountCubit>(),
                ),
                BlocProvider<DeleteAccountCubit>(
                  create: (_) => ServiceLocator.instance<DeleteAccountCubit>(),
                ),
                BlocProvider<SaveCategoryCubit>(
                  create: (_) => ServiceLocator.instance<SaveCategoryCubit>(),
                ),
                BlocProvider<DeactivateCategoryCubit>(
                  create: (_) =>
                      ServiceLocator.instance<DeactivateCategoryCubit>(),
                ),
                BlocProvider<DeleteCategoryCubit>(
                  create: (_) => ServiceLocator.instance<DeleteCategoryCubit>(),
                ),
                BlocProvider<SaveIncomeCubit>(
                  create: (_) => ServiceLocator.instance<SaveIncomeCubit>(),
                ),
                BlocProvider<SaveExpenseCubit>(
                  create: (_) => ServiceLocator.instance<SaveExpenseCubit>(),
                ),
                BlocProvider<SaveTransferCubit>(
                  create: (_) => ServiceLocator.instance<SaveTransferCubit>(),
                ),
                BlocProvider<UpdateTransactionCubit>(
                  create: (_) =>
                      ServiceLocator.instance<UpdateTransactionCubit>(),
                ),
                BlocProvider<DeleteTransactionCubit>(
                  create: (_) =>
                      ServiceLocator.instance<DeleteTransactionCubit>(),
                ),
                BlocProvider<SearchTransactionsCubit>(
                  create: (_) =>
                      ServiceLocator.instance<SearchTransactionsCubit>(),
                ),
              ],
              child: child,
            ),
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (BuildContext context, GoRouterState state) =>
                const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.accounts,
            builder: (BuildContext context, GoRouterState state) =>
                const AccountListPage(),
          ),
          GoRoute(
            path: AppRoutes.accountForm,
            builder: (BuildContext context, GoRouterState state) {
              final Object? extra = state.extra;
              return AccountFormPage(existing: extra is Account ? extra : null);
            },
          ),
          GoRoute(
            path: AppRoutes.transactionForm,
            builder: (BuildContext context, GoRouterState state) {
              final Object? extra = state.extra;
              return TransactionFormPage(
                existing: extra is MoneyTransaction ? extra : null,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.transactions,
            builder: (BuildContext context, GoRouterState state) {
              final Object? extra = state.extra;
              return TransactionListPage(
                initialQuery: switch (extra) {
                  SearchTransactionsParams params => params,
                  DateRange range => SearchTransactionsParams(range: range),
                  _ => null,
                },
              );
            },
          ),
          GoRoute(
            path: AppRoutes.categories,
            builder: (BuildContext context, GoRouterState state) =>
                const CategoryListPage(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (BuildContext context, GoRouterState state) =>
                const ReportPage(),
          ),
        ],
      ),
    ],
  );
}
