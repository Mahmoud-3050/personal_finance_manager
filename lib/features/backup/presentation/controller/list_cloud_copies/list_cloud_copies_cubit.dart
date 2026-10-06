import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/backup_copy.dart';
import '../../../domain/usecases/list_cloud_copies_use_case.dart';

part 'list_cloud_copies_states.dart';

class ListCloudCopiesCubit extends Cubit<ListCloudCopiesState> {
  ListCloudCopiesCubit(this._useCase)
    : super(const ApiCallHolding<List<BackupCopy>>());

  final ListCloudCopiesUseCase _useCase;

  Future<void> fListCloudCopies() async {
    emit(const ApiCallLoading<List<BackupCopy>>());
    final result = await _useCase(const NoParams());
    result.fold(
      (failure) =>
          emit(ApiCallError<List<BackupCopy>>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<List<BackupCopy>>(data: data)),
    );
  }
}
