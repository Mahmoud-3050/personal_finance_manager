import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../domain/entities/receipt_photo.dart';
import '../../../domain/usecases/delete_receipt_photo_use_case.dart';

part 'release_receipt_photo_states.dart';

class ReleaseReceiptPhotoCubit extends Cubit<ReleaseReceiptPhotoState> {
  ReleaseReceiptPhotoCubit(this._deleteReceiptPhoto)
    : super(const ApiCallHolding<bool>());

  final DeleteReceiptPhotoUseCase _deleteReceiptPhoto;

  Future<void> fReleaseReceiptPhoto(ReceiptPhoto photo) async {
    if (state.isLoading) {
      return;
    }
    emit(const ApiCallLoading<bool>());
    final result = await _deleteReceiptPhoto(
      DeleteReceiptPhotoParams(photo: photo),
    );
    if (isClosed) {
      return;
    }
    result.fold(
      (failure) => emit(ApiCallError<bool>(message: failure.message ?? '')),
      (_) => emit(const ApiCallSuccess<bool>(data: true)),
    );
  }
}
