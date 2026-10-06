import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/language/strings.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../domain/entities/dashboard_data.dart';
import '../controller/get_dashboard/get_dashboard_cubit.dart';
import '../widgets/dashboard_loaded.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.fenzoTitle),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: BlocBuilder<GetDashboardCubit, ApiCallState<DashboardData>>(
        builder: (BuildContext context, ApiCallState<DashboardData> state) {
          return switch (state) {
            ApiCallSuccess<DashboardData>(:final DashboardData data) =>
              DashboardLoaded(data: data),
            ApiCallError<DashboardData>(:final String message) => Center(
              child: Text(message, style: TextStyles.of(size: 16)),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
    );
  }
}
