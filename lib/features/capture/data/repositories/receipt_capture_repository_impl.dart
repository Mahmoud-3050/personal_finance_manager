import 'package:either/either.dart';

import '../../../../core/data/repository_guard.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/network/netwok_info.dart';
import '../../domain/entities/receipt_capture_failure.dart';
import '../../domain/entities/receipt_image_source.dart';
import '../../domain/entities/receipt_photo.dart';
import '../../domain/entities/receipt_read_gate.dart';
import '../../domain/entities/receipt_reading.dart';
import '../../domain/repositories/receipt_capture_repository.dart';
import '../../domain/repositories/receipt_reader.dart';
import '../datasources/receipt_image_data_source.dart';

class ReceiptCaptureRepositoryImpl
    with RepositoryGuard
    implements ReceiptCaptureRepository {
  ReceiptCaptureRepositoryImpl({
    required ReceiptImageDataSource images,
    required ReceiptReader reader,
    required NetworkInfo network,
  }) : _images = images,
       _reader = reader,
       _network = network;

  final ReceiptImageDataSource _images;
  final ReceiptReader _reader;
  final NetworkInfo _network;

  @override
  bool get sendsImageOffDevice => _reader.sendsImageOffDevice;

  @override
  Future<Either<Failure, ReceiptPhoto?>> pick(ReceiptImageSource source) {
    return guard(() => _images.pick(source), 'pickReceipt');
  }

  @override
  Future<Either<Failure, ReceiptReadGate>> prepare(ReceiptPhoto photo) {
    return guard(() async {
      if (!_reader.sendsImageOffDevice) {
        return ReceiptReadOnDevice(reading: _readOrFail(photo));
      }
      final bool online = await _network.isConnected;
      if (!online) {
        return const ReceiptReadOffline();
      }
      return const ReceiptReadNeedsConsent();
    }, 'prepareReceipt');
  }

  @override
  Future<Either<Failure, ReceiptReading>> read(ReceiptPhoto photo) {
    return guard(() async => _readOrFail(photo), 'readReceipt');
  }

  @override
  Future<Either<Failure, void>> delete(ReceiptPhoto photo) {
    return guard(() => _images.delete(photo), 'deleteReceipt');
  }

  ReceiptReading _readOrFail(ReceiptPhoto photo) {
    try {
      return _reader.read(photo);
    } on AppException {
      rethrow;
    } on Object {
      throw const CacheException(message: ReceiptCaptureFailure.readFailed);
    }
  }
}
