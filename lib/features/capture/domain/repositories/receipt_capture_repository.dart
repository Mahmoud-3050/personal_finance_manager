import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../entities/receipt_image_source.dart';
import '../entities/receipt_photo.dart';
import '../entities/receipt_read_gate.dart';
import '../entities/receipt_reading.dart';

abstract interface class ReceiptCaptureRepository {
  bool get sendsImageOffDevice;

  Future<Either<Failure, ReceiptPhoto?>> pick(ReceiptImageSource source);

  Future<Either<Failure, ReceiptReadGate>> prepare(ReceiptPhoto photo);

  Future<Either<Failure, ReceiptReading>> read(ReceiptPhoto photo);

  Future<Either<Failure, void>> delete(ReceiptPhoto photo);
}
