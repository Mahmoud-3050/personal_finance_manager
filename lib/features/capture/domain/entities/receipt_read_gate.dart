import 'package:equatable/equatable.dart';

import 'receipt_reading.dart';

sealed class ReceiptReadGate extends Equatable {
  const ReceiptReadGate();
}

final class ReceiptReadOnDevice extends ReceiptReadGate {
  const ReceiptReadOnDevice({required this.reading});

  final ReceiptReading reading;

  @override
  List<Object?> get props => <Object?>[reading];
}

final class ReceiptReadNeedsConsent extends ReceiptReadGate {
  const ReceiptReadNeedsConsent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ReceiptReadOffline extends ReceiptReadGate {
  const ReceiptReadOffline();

  @override
  List<Object?> get props => const <Object?>[];
}
