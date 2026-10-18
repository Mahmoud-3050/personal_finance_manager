import 'package:equatable/equatable.dart';

import '../../../../shared/domain/entities/calendar_date.dart';
import 'capture_draft.dart';

final class ReceiptReading extends Equatable {
  const ReceiptReading({
    this.amountMinor,
    this.date,
    this.shopName,
    this.unsure = const <CaptureField>{},
  });

  final int? amountMinor;
  final CalendarDate? date;
  final String? shopName;
  final Set<CaptureField> unsure;

  @override
  List<Object?> get props => <Object?>[amountMinor, date, shopName, unsure];
}
