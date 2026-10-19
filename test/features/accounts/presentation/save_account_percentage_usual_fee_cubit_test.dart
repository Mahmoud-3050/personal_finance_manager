import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:finzomanager/features/accounts/domain/usecases/save_account_use_case.dart';
import 'package:finzomanager/features/accounts/presentation/controller/save_account/save_account_cubit.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/shared/domain/services/percentage_commission.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements AccountsRepository {
  _Repo(this._accepts);

  final bool _accepts;

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
    int defaultCommissionMinor = 0,
    CommissionBasis defaultCommissionBasis = CommissionBasis.fixed,
    int defaultCommissionRateMinor = 0,
  }) async {
    if (!_accepts || defaultCommissionRateMinor < 0) {
      return const Left(ValidationFailure(message: 'commission_non_negative'));
    }
    return Right(FinanceRecords.empty());
  }

  @override
  Future<Either<Failure, FinanceRecords>> load() async {
    return Right(FinanceRecords.empty());
  }

  @override
  Future<Either<Failure, FinanceRecords>> deactivateAccount(String id) async {
    return Right(FinanceRecords.empty());
  }

  @override
  Future<Either<Failure, FinanceRecords>> reactivateAccount(String id) async {
    return Right(FinanceRecords.empty());
  }

  @override
  Future<Either<Failure, FinanceRecords>> deleteAccount(String id) async {
    return Right(FinanceRecords.empty());
  }
}

void main() {
  const SaveAccountParams params = SaveAccountParams(
    name: 'Vodafone',
    type: AccountType.eWallet,
    openingBalanceMinor: 0,
    openingDate: CalendarDate(2026, 10, 1),
    defaultCommissionBasis: CommissionBasis.percentage,
    defaultCommissionRateMinor: 100,
  );

  blocTest<SaveAccountCubit, ApiCallState<FinanceRecords>>(
    'percentage usual fee emits loading then success',
    build: () => SaveAccountCubit(SaveAccountUseCase(_Repo(true))),
    act: (SaveAccountCubit cubit) => cubit.fSaveAccount(params),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallSuccess<FinanceRecords>>(),
    ],
  );

  blocTest<SaveAccountCubit, ApiCallState<FinanceRecords>>(
    'percentage usual fee emits loading then the validation error',
    build: () => SaveAccountCubit(SaveAccountUseCase(_Repo(false))),
    act: (SaveAccountCubit cubit) => cubit.fSaveAccount(params),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallError<FinanceRecords>>().having(
        (ApiCallError<FinanceRecords> state) => state.message,
        'message',
        'commission_non_negative',
      ),
    ],
  );
}
