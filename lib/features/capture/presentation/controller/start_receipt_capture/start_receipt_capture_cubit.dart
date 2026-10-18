import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../domain/entities/capture_draft.dart';
import '../../../domain/entities/receipt_capture_failure.dart';
import '../../../domain/entities/receipt_capture_outcome.dart';
import '../../../domain/entities/receipt_image_source.dart';
import '../../../domain/entities/receipt_photo.dart';
import '../../../domain/usecases/delete_receipt_photo_use_case.dart';
import '../../../domain/usecases/pick_receipt_image_use_case.dart';
import '../../../domain/usecases/read_receipt_use_case.dart';

part 'start_receipt_capture_states.dart';

class StartReceiptCaptureCubit extends Cubit<StartReceiptCaptureState> {
  StartReceiptCaptureCubit({
    required PickReceiptImageUseCase pickReceiptImage,
    required ReadReceiptUseCase readReceipt,
    required DeleteReceiptPhotoUseCase deleteReceiptPhoto,
  }) : _pickReceiptImage = pickReceiptImage,
       _readReceipt = readReceipt,
       _deleteReceiptPhoto = deleteReceiptPhoto,
       super(const ApiCallHolding<ReceiptCaptureOutcome>());

  final PickReceiptImageUseCase _pickReceiptImage;
  final ReadReceiptUseCase _readReceipt;
  final DeleteReceiptPhotoUseCase _deleteReceiptPhoto;
  ReceiptPhoto? _heldPhoto;

  Future<void> fStartReceiptCapture(ReceiptImageSource source) async {
    if (state.isLoading) {
      return;
    }
    _emit(const ApiCallLoading<ReceiptCaptureOutcome>());
    final result = await _pickReceiptImage(
      PickReceiptImageParams(source: source),
    );
    final Failure? failure = result.leftOrNull;
    if (failure != null) {
      _emit(
        ApiCallError<ReceiptCaptureOutcome>(message: failure.message ?? ''),
      );
      return;
    }
    final ReceiptPhoto? photo = result.rightOrNull;
    if (photo == null) {
      _heldPhoto = null;
      _emit(
        const ApiCallSuccess<ReceiptCaptureOutcome>(
          data: ReceiptCaptureCancelled(),
        ),
      );
      return;
    }
    _heldPhoto = photo;
    await _prepare(photo);
  }

  Future<void> fAcceptOffDeviceReading() async {
    final ReceiptPhoto? photo = _heldPhoto;
    if (photo == null) {
      _emit(
        const ApiCallError<ReceiptCaptureOutcome>(
          message: ReceiptCaptureFailure.readFailed,
        ),
      );
      return;
    }
    if (state.isLoading) {
      return;
    }
    _emit(const ApiCallLoading<ReceiptCaptureOutcome>());
    final result = await _readReceipt(
      ReadReceiptParams(photo: photo, step: ReceiptReadStep.accept),
    );
    final Failure? failure = result.leftOrNull;
    if (failure != null) {
      await _failReading(failure);
      return;
    }
    final ReceiptCaptureOutcome? outcome = result.rightOrNull;
    if (outcome == null) {
      return;
    }
    _heldPhoto = null;
    _emit(ApiCallSuccess<ReceiptCaptureOutcome>(data: outcome));
  }

  Future<void> fSkipToBlankDraft() async {
    if (state.isLoading) {
      return;
    }
    final ReceiptPhoto? photo = _heldPhoto;
    _heldPhoto = null;
    _emit(const ApiCallLoading<ReceiptCaptureOutcome>());
    if (photo != null) {
      final result = await _deleteReceiptPhoto(
        DeleteReceiptPhotoParams(photo: photo),
      );
      final Failure? failure = result.leftOrNull;
      if (failure != null) {
        _emit(
          ApiCallError<ReceiptCaptureOutcome>(message: failure.message ?? ''),
        );
        return;
      }
    }
    _emit(
      ApiCallSuccess<ReceiptCaptureOutcome>(
        data: ReceiptBlankReady(draft: CaptureDraft.handStarted()),
      ),
    );
  }

  @override
  Future<void> close() {
    final ReceiptPhoto? photo = _heldPhoto;
    _heldPhoto = null;
    if (photo != null) {
      unawaited(_deleteReceiptPhoto(DeleteReceiptPhotoParams(photo: photo)));
    }
    return super.close();
  }

  Future<void> _prepare(ReceiptPhoto photo) async {
    final result = await _readReceipt(
      ReadReceiptParams(photo: photo, step: ReceiptReadStep.prepare),
    );
    final Failure? failure = result.leftOrNull;
    if (failure != null) {
      await _failReading(failure);
      return;
    }
    final ReceiptCaptureOutcome? outcome = result.rightOrNull;
    if (outcome == null) {
      return;
    }
    if (outcome is! ReceiptConsentRequired) {
      _heldPhoto = null;
    }
    _emit(ApiCallSuccess<ReceiptCaptureOutcome>(data: outcome));
  }

  Future<void> _failReading(Failure failure) async {
    final ReceiptPhoto? photo = _heldPhoto;
    _heldPhoto = null;
    if (photo != null) {
      await _deleteReceiptPhoto(DeleteReceiptPhotoParams(photo: photo));
    }
    _emit(ApiCallError<ReceiptCaptureOutcome>(message: failure.message ?? ''));
  }

  void _emit(StartReceiptCaptureState next) {
    if (!isClosed) {
      emit(next);
    }
  }
}
