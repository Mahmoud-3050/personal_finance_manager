import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:finzomanager/features/transactions/domain/usecases/save_expense_use_case.dart';
import 'package:finzomanager/features/transactions/presentation/controller/save_expense/save_expense_cubit.dart';
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
      return const Left(ValidationFailure(message: 'commission_not_allowed'));
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
  const SaveExpenseParams params = SaveExpenseParams(
    amountMinor: 20000,
    date: CalendarDate(2026, 10, 2),
    commissionMinor: 300,
  );

  blocTest<SaveExpenseCubit, ApiCallState<FinanceRecords>>(
    'save expense emits loading then success',
    build: () => SaveExpenseCubit(SaveExpenseUseCase(_Repo(true))),
    act: (SaveExpenseCubit cubit) => cubit.fSaveExpense(params),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallSuccess<FinanceRecords>>(),
    ],
  );

  blocTest<SaveExpenseCubit, ApiCallState<FinanceRecords>>(
    'save expense emits loading then the validation error',
    build: () => SaveExpenseCubit(SaveExpenseUseCase(_Repo(false))),
    act: (SaveExpenseCubit cubit) => cubit.fSaveExpense(params),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallError<FinanceRecords>>().having(
        (ApiCallError<FinanceRecords> state) => state.message,
        'message',
        'commission_not_allowed',
      ),
    ],
  );
}
