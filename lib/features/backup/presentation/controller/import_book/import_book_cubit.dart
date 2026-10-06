import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/language/strings.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/import_book_use_case.dart';

part 'import_book_states.dart';

class ImportBookCubit extends Cubit<ImportBookState> {
  ImportBookCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final ImportBookUseCase _useCase;

  Future<void> fImportBook({
    required bool confirmed,
    FinanceRecords? replacement,
  }) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(
      ImportBookParams(confirmed: confirmed, replacement: replacement),
    );
    result.fold(
      (failure) => emit(
        ApiCallError<FinanceRecords>(
          message: failure is ValidationFailure
              ? Strings.backupUnusable
              : failure.message ?? Strings.backupUnusable,
        ),
      ),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
