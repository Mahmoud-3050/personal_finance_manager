import '../../../../core/error/exceptions.dart';
import '../../domain/entities/receipt_capture_failure.dart';
import '../../domain/entities/receipt_photo.dart';
import '../../domain/entities/receipt_reading.dart';
import '../../domain/repositories/receipt_reader.dart';

class EmptyReceiptReader implements ReceiptReader {
  const EmptyReceiptReader();

  @override
  bool get sendsImageOffDevice => false;

  @override
  ReceiptReading read(ReceiptPhoto photo) {
    try {
      return const ReceiptReading();
    } on AppException {
      rethrow;
    } on Object {
      throw const CacheException(message: ReceiptCaptureFailure.readFailed);
    }
  }
}
