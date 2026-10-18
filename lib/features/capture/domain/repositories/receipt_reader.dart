import '../entities/receipt_photo.dart';
import '../entities/receipt_reading.dart';

abstract interface class ReceiptReader {
  bool get sendsImageOffDevice;

  ReceiptReading read(ReceiptPhoto photo);
}
