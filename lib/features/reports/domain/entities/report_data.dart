import 'package:equatable/equatable.dart';

import '../../../../shared/domain/entities/period_figures.dart';

class ReportData extends Equatable {
  const ReportData({required this.figures, required this.totalMoneyMinor});

  final PeriodFigures figures;
  final int totalMoneyMinor;

  @override
  List<Object?> get props => <Object?>[figures, totalMoneyMinor];
}
