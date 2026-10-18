import 'dart:io';

import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/services/network/netwok_info.dart';
import 'package:finzomanager/features/capture/data/datasources/receipt_image_data_source.dart';
import 'package:finzomanager/features/capture/data/datasources/receipt_reader_data_source.dart';
import 'package:finzomanager/features/capture/data/repositories/receipt_capture_repository_impl.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_photo.dart';
import 'package:finzomanager/features/capture/domain/usecases/delete_receipt_photo_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'delete removes the temp file and a missing file still succeeds',
    () async {
      final Directory root = await Directory.systemTemp.createTemp(
        'receipt-use-case',
      );
      addTearDown(() => root.delete(recursive: true));
      final File file = File('${root.path}/shot.jpg');
      await file.writeAsString('bytes');
      final DeleteReceiptPhotoUseCase useCase = DeleteReceiptPhotoUseCase(
        repository: ReceiptCaptureRepositoryImpl(
          images: ReceiptImageDataSourceImpl(storageRoot: root),
          reader: const EmptyReceiptReader(),
          network: _Online(),
        ),
      );

      final Either<Failure, bool> first = await useCase(
        DeleteReceiptPhotoParams(photo: ReceiptPhoto(path: file.path)),
      );
      final Either<Failure, bool> second = await useCase(
        DeleteReceiptPhotoParams(photo: ReceiptPhoto(path: file.path)),
      );

      expect(first.rightOrNull, isTrue);
      expect(second.rightOrNull, isTrue);
      expect(file.existsSync(), isFalse);
    },
  );
}

class _Online implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}
