import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:finzomanager/features/transactions/domain/usecases/save_transfer_use_case.dart';
import 'package:finzomanager/features/transactions/presentation/controller/save_transfer/save_transfer_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements TransactionsRepository {
  _Repo(this._accepts);

  final bool _accepts;

  @override
  Future<Either<Failure, FinanceRecords>> saveMovement({
    required String? id,
    required MoneyTransactionType type,
    required int amountMinor,
    required CalendarDate date,
    String? accountId,
    String? categoryId,
    String? subcategoryId,
    String? fromAccountId,
    String? toAccountId,
    String? description,
    String? notes,
    int commissionMinor = 0,
  }) async {
    if (!_accepts) {
      return const Left(ValidationFailure(message: 'transfer_accounts'));
    }
    return Right(FinanceRecords.empty());
  }

  @override
  Future<Either<Failure, FinanceRecords>> load() async {
    return Right(FinanceRecords.empty());
  }

  @override
  Future<Either<Failure, FinanceRecords>> deleteTransaction(String id) async {
    return Right(FinanceRecords.empty());
  }
}

void main() {
  const SaveTransferParams params = SaveTransferParams(
    amountMinor: 100000,
    date: CalendarDate(2026, 10, 2),
    fromAccountId: 'bank',
    toAccountId: 'wallet',
    commissionMinor: 500,
  );

  blocTest<SaveTransferCubit, ApiCallState<FinanceRecords>>(
    'save transfer emits loading then success',
    build: () => SaveTransferCubit(SaveTransferUseCase(_Repo(true))),
    act: (SaveTransferCubit cubit) => cubit.fSaveTransfer(params),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallSuccess<FinanceRecords>>(),
    ],
  );

  blocTest<SaveTransferCubit, ApiCallState<FinanceRecords>>(
    'save transfer emits loading then the validation error',
    build: () => SaveTransferCubit(SaveTransferUseCase(_Repo(false))),
    act: (SaveTransferCubit cubit) => cubit.fSaveTransfer(params),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallError<FinanceRecords>>().having(
        (ApiCallError<FinanceRecords> state) => state.message,
        'message',
        'transfer_accounts',
      ),
    ],
  );
}
