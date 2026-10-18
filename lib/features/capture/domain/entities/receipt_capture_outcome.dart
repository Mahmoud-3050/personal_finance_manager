import 'package:equatable/equatable.dart';

import 'capture_draft.dart';
import 'receipt_photo.dart';

sealed class ReceiptCaptureOutcome extends Equatable {
  const ReceiptCaptureOutcome();
}

final class ReceiptProposalReady extends ReceiptCaptureOutcome {
  const ReceiptProposalReady({required this.draft, required this.photo});

  final CaptureDraft draft;
  final ReceiptPhoto photo;

  @override
  List<Object?> get props => <Object?>[draft, photo];
}

final class ReceiptConsentRequired extends ReceiptCaptureOutcome {
  const ReceiptConsentRequired({required this.photo});

  final ReceiptPhoto photo;

  @override
  List<Object?> get props => <Object?>[photo];
}

final class ReceiptBlankReady extends ReceiptCaptureOutcome {
  const ReceiptBlankReady({required this.draft});

  final CaptureDraft draft;

  @override
  List<Object?> get props => <Object?>[draft];
}

final class ReceiptCaptureCancelled extends ReceiptCaptureOutcome {
  const ReceiptCaptureCancelled();

  @override
  List<Object?> get props => const <Object?>[];
}
