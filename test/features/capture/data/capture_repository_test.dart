import 'package:either/either.dart';
import 'package:finzomanager/core/error/exceptions.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/features/capture/data/datasources/capture_draft_data_source.dart';
import 'package:finzomanager/features/capture/data/repositories/capture_repository_impl.dart';
import 'package:finzomanager/features/capture/domain/entities/capture_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'hold then read returns the same draft, and clear makes read empty',
    () async {
      final CaptureRepositoryImpl repository = CaptureRepositoryImpl(
        source: MemoryCaptureDraftDataSource(),
      );
      final CaptureDraft draft = CaptureDraft.handStarted();

      final Either<Failure, CaptureDraft> held = await repository.hold(draft);
      final Either<Failure, CaptureDraft?> read = await repository.read();
      expect(held.fold((_) => null, (CaptureDraft value) => value), draft);
      expect(read.fold((_) => null, (CaptureDraft? value) => value), draft);

      await repository.clear();
      final Either<Failure, CaptureDraft?> empty = await repository.read();
      expect(empty.fold((_) => null, (CaptureDraft? value) => value), isNull);
    },
  );

  test('AppException from the data source becomes Left', () async {
    final CaptureRepositoryImpl repository = CaptureRepositoryImpl(
      source: _ThrowingDraftSource(),
    );
    final Either<Failure, CaptureDraft?> read = await repository.read();
    expect(
      read.fold((Failure failure) => failure, (_) => null),
      isA<CacheFailure>(),
    );
  });
}

class _ThrowingDraftSource implements CaptureDraftDataSource {
  @override
  CaptureDraft? read() => throw const CacheException(message: 'missing');

  @override
  void hold(CaptureDraft draft) =>
      throw const CacheException(message: 'missing');

  @override
  void clear() => throw const CacheException(message: 'missing');

  @override
  bool get isFinished => throw const CacheException(message: 'missing');

  @override
  void markFinished() => throw const CacheException(message: 'missing');
}
