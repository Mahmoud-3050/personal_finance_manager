import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/language/strings.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/import_preview.dart';
import '../../../domain/usecases/preview_import_use_case.dart';

part 'preview_import_states.dart';

class PreviewImportCubit extends Cubit<PreviewImportState> {
  PreviewImportCubit(this._useCase)
    : super(const ApiCallHolding<ImportPreview>());

  final PreviewImportUseCase _useCase;

  Future<void> fPreviewImport() async {
    emit(const ApiCallLoading<ImportPreview>());
    final result = await _useCase(const NoParams());
    result.fold(
      (failure) => emit(
        ApiCallError<ImportPreview>(
          message: failure is ValidationFailure
              ? Strings.backupUnusable
              : failure.message ?? Strings.backupUnusable,
        ),
      ),
      (data) => emit(ApiCallSuccess<ImportPreview>(data: data)),
    );
  }
}
