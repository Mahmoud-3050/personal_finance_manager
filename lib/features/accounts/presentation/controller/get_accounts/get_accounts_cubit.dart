import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/account_list_data.dart';
import '../../../domain/usecases/get_accounts_use_case.dart';

part 'get_accounts_states.dart';

class GetAccountsCubit extends Cubit<GetAccountsState> {
  GetAccountsCubit(this._useCase)
    : super(const ApiCallHolding<AccountListData>());

  final GetAccountsUseCase _useCase;

  Future<void> fGetAccounts() async {
    emit(const ApiCallLoading<AccountListData>());
    final result = await _useCase(const NoParams());
    result.fold(
      (failure) =>
          emit(ApiCallError<AccountListData>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<AccountListData>(data: data)),
    );
  }
}
