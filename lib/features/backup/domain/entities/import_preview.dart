import 'package:equatable/equatable.dart';

import '../../../../shared/domain/finance_records.dart';

class ImportPreview extends Equatable {
  const ImportPreview({required this.createdAt, required this.records});

  final DateTime createdAt;
  final FinanceRecords records;

  @override
  List<Object?> get props => <Object?>[createdAt, records];
}
