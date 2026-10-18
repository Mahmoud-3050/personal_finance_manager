import 'dart:io';

import 'package:either/either.dart';
import 'package:finzomanager/core/error/exceptions.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/services/network/netwok_info.dart';
import 'package:finzomanager/features/capture/data/datasources/receipt_image_data_source.dart';
import 'package:finzomanager/features/capture/data/datasources/receipt_reader_data_source.dart';
import 'package:finzomanager/features/capture/data/repositories/receipt_capture_repository_impl.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_capture_failure.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_image_source.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_photo.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_read_gate.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_reading.dart';
import 'package:finzomanager/features/capture/domain/repositories/receipt_reader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  test('AppException from the image source becomes Left', () async {
    final ReceiptCaptureRepositoryImpl repository = _repository(
      images: _ThrowingImages(),
    );
    final Either<Failure, ReceiptPhoto?> picked = await repository.pick(
      ReceiptImageSource.camera,
    );
    expect(picked.leftOrNull, isA<CacheFailure>());
    expect(picked.leftOrNull?.message, ReceiptCaptureFailure.accessDenied);
  });

  test(
    'a reader AppException becomes Left with the read-failed message',
    () async {
      final ReceiptCaptureRepositoryImpl repository = _repository(
        reader: _ThrowingReader(),
      );
      final Either<Failure, ReceiptReading> read = await repository.read(
        const ReceiptPhoto(path: 'missing.jpg'),
      );
      expect(read.leftOrNull?.message, ReceiptCaptureFailure.readFailed);
    },
  );

  test('delete removes the file and a second delete still succeeds', () async {
    final Directory root = await Directory.systemTemp.createTemp(
      'receipt-delete',
    );
    addTearDown(() => root.delete(recursive: true));
    final File file = File('${root.path}/note.jpg');
    await file.writeAsString('receipt');
    final ReceiptCaptureRepositoryImpl repository = _repository(
      images: ReceiptImageDataSourceImpl(storageRoot: root),
    );

    final Either<Failure, void> first = await repository.delete(
      ReceiptPhoto(path: file.path),
    );
    final Either<Failure, void> second = await repository.delete(
      ReceiptPhoto(path: file.path),
    );

    expect(first.isRight, isTrue);
    expect(second.isRight, isTrue);
    expect(file.existsSync(), isFalse);
  });

  test('closing the picker is not a failure', () async {
    final ReceiptCaptureRepositoryImpl repository = _repository(
      images: ReceiptImageDataSourceImpl(
        pickImage: (ImageSource source) async => null,
      ),
    );
    final Either<Failure, ReceiptPhoto?> picked = await repository.pick(
      ReceiptImageSource.gallery,
    );
    expect(picked.rightOrNull, isNull);
    expect(picked.isRight, isTrue);
  });

  test(
    'a refused camera becomes Left with the access-denied message',
    () async {
      final ReceiptCaptureRepositoryImpl repository = _repository(
        images: ReceiptImageDataSourceImpl(
          pickImage: (ImageSource source) async {
            throw PlatformException(code: 'camera_access_denied');
          },
        ),
      );
      final Either<Failure, ReceiptPhoto?> picked = await repository.pick(
        ReceiptImageSource.camera,
      );
      expect(picked.leftOrNull?.message, ReceiptCaptureFailure.accessDenied);
    },
  );

  test(
    'an on-device prepare reads and an off-device prepare does not',
    () async {
      final _CountingReader onDevice = _CountingReader(sendsOffDevice: false);
      final ReceiptCaptureRepositoryImpl local = _repository(reader: onDevice);
      final Either<Failure, ReceiptReadGate> prepared = await local.prepare(
        const ReceiptPhoto(path: 'local.jpg'),
      );
      expect(prepared.rightOrNull, isA<ReceiptReadOnDevice>());
      expect(onDevice.reads, 1);

      final _CountingReader remote = _CountingReader(sendsOffDevice: true);
      final ReceiptCaptureRepositoryImpl online = _repository(
        reader: remote,
        online: true,
      );
      final Either<Failure, ReceiptReadGate> consent = await online.prepare(
        const ReceiptPhoto(path: 'remote.jpg'),
      );
      expect(consent.rightOrNull, isA<ReceiptReadNeedsConsent>());
      expect(remote.reads, 0);

      final ReceiptCaptureRepositoryImpl offline = _repository(
        reader: _CountingReader(sendsOffDevice: true),
        online: false,
      );
      final Either<Failure, ReceiptReadGate> skipped = await offline.prepare(
        const ReceiptPhoto(path: 'remote.jpg'),
      );
      expect(skipped.rightOrNull, isA<ReceiptReadOffline>());
    },
  );
}

ReceiptCaptureRepositoryImpl _repository({
  ReceiptImageDataSource? images,
  ReceiptReader? reader,
  bool online = true,
}) {
  return ReceiptCaptureRepositoryImpl(
    images: images ?? ReceiptImageDataSourceImpl(),
    reader: reader ?? const EmptyReceiptReader(),
    network: _FixedNetwork(online),
  );
}

class _FixedNetwork implements NetworkInfo {
  _FixedNetwork(this.online);

  final bool online;

  @override
  Future<bool> get isConnected async => online;
}

class _ThrowingImages implements ReceiptImageDataSource {
  @override
  Future<ReceiptPhoto?> pick(ReceiptImageSource source) {
    throw const CacheException(message: ReceiptCaptureFailure.accessDenied);
  }

  @override
  Future<void> delete(ReceiptPhoto photo) async {}
}

class _ThrowingReader implements ReceiptReader {
  @override
  bool get sendsImageOffDevice => false;

  @override
  ReceiptReading read(ReceiptPhoto photo) {
    throw const CacheException(message: ReceiptCaptureFailure.readFailed);
  }
}

class _CountingReader implements ReceiptReader {
  _CountingReader({required this.sendsOffDevice});

  final bool sendsOffDevice;
  int reads = 0;

  @override
  bool get sendsImageOffDevice => sendsOffDevice;

  @override
  ReceiptReading read(ReceiptPhoto photo) {
    reads += 1;
    return const ReceiptReading();
  }
}
