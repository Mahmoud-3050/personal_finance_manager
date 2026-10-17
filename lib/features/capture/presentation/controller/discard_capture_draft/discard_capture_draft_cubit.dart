import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/discard_capture_draft_use_case.dart';

part 'discard_capture_draft_states.dart';

class DiscardCaptureDraftCubit extends Cubit<DiscardCaptureDraftState> {
  DiscardCaptureDraftCubit(this._useCase) : super(const ApiCallHolding<bool>());

  final DiscardCaptureDraftUseCase _useCase;

  Future<void> fDiscardCaptureDraft() async {
    if (state.isLoading) {
      return;
    }
    emit(const ApiCallLoading<bool>());
    final result = await _useCase(const NoParams());
    result.fold(
      (failure) => emit(ApiCallError<bool>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<bool>(data: data)),
    );
  }
}
