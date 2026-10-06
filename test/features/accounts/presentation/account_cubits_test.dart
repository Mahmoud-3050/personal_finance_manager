import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:finzomanager/features/accounts/domain/usecases/save_account_use_case.dart';
import 'package:finzomanager/features/accounts/presentation/controller/save_account/save_account_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements AccountsRepository {
  @override
  Future<Either<Failure, FinanceRecords>> saveAccount({
    required String? id,
    required String name,
    required AccountType type,
    required int openingBalanceMinor,
    required CalendarDate openingDate,
    required bool includeInTotal,
    String? bankName,
    String? accountNumber,
    String? phoneNumber,
  }) async {
    return Right(FinanceRecords.empty());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  blocTest<SaveAccountCubit, ApiCallState<FinanceRecords>>(
    'save account emits loading then success',
    build: () => SaveAccountCubit(SaveAccountUseCase(_Repo())),
    act: (SaveAccountCubit cubit) => cubit.fSaveAccount(
      const SaveAccountParams(
        name: 'Cash',
        type: AccountType.cash,
        openingBalanceMinor: 0,
        openingDate: CalendarDate(2026, 10, 1),
      ),
    ),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallSuccess<FinanceRecords>>(),
    ],
  );
}
