import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../domain/entities/backup_settings.dart';
import '../../../domain/usecases/export_book_use_case.dart';

part 'export_book_states.dart';

class ExportBookCubit extends Cubit<ExportBookState> {
  ExportBookCubit(this._useCase)
    : super(const ApiCallHolding<BackupSettings>());

  final ExportBookUseCase _useCase;

  Future<void> fExportBook({DateTime? now}) async {
    emit(const ApiCallLoading<BackupSettings>());
    final result = await _useCase(ExportBookParams(now: now ?? DateTime.now()));
    result.fold(
      (failure) =>
          emit(ApiCallError<BackupSettings>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<BackupSettings>(data: data)),
    );
  }
}
