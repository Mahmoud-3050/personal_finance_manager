import '../../../../shared/data/models/period_figures_model.dart';
import '../../domain/entities/report_data.dart';

final class ReportDataModel extends ReportData {
  const ReportDataModel({
    required super.figures,
    required super.totalMoneyMinor,
  });

  factory ReportDataModel.fromJson(Map<String, dynamic> json) {
    return ReportDataModel(
      figures: PeriodFiguresModel.fromJson(
        json['figures']! as Map<String, dynamic>,
      ),
      totalMoneyMinor: json['total_money_minor'] as int,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'figures': PeriodFiguresModel.fromEntity(figures).toJson(),
    'total_money_minor': totalMoneyMinor,
  };
}
