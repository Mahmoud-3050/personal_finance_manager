import 'package:equatable/equatable.dart';

import 'capture_draft.dart';
import 'receipt_photo.dart';

final class CaptureReviewRequest extends Equatable {
  const CaptureReviewRequest({required this.draft, this.photo});

  final CaptureDraft draft;
  final ReceiptPhoto? photo;

  @override
  List<Object?> get props => <Object?>[draft, photo];
}
