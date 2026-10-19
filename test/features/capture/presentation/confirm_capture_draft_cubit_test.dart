import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/features/capture/data/datasources/capture_draft_data_source.dart';
import 'package:finzomanager/features/capture/data/repositories/capture_repository_impl.dart';
import 'package:finzomanager/features/capture/domain/entities/capture_draft.dart';
import 'package:finzomanager/features/capture/domain/usecases/confirm_capture_draft_use_case.dart';
import 'package:finzomanager/features/capture/presentation/controller/confirm_capture_draft/confirm_capture_draft_cubit.dart';
import 'package:finzomanager/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:finzomanager/features/transactions/domain/usecases/save_expense_use_case.dart';
import 'package:finzomanager/features/transactions/domain/usecases/save_income_use_case.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/services/percentage_commission.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const CaptureDraft draft = CaptureDraft(
    kind: CaptureKind.expense,
    date: CalendarDate(2026, 10, 17),
    amountMinor: 1000,
    accountId: 'cash',
    categoryId: 'food',
    uncertainFields: <CaptureField>{},
  );

  blocTest<ConfirmCaptureDraftCubit, ConfirmCaptureDraftState>(
    'confirm emits loading then success',
    build: () => ConfirmCaptureDraftCubit(_useCase()),
    act: (ConfirmCaptureDraftCubit cubit) => cubit.fConfirmCaptureDraft(draft),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallSuccess<FinanceRecords>>(),
    ],
  );

  blocTest<ConfirmCaptureDraftCubit, ConfirmCaptureDraftState>(
    'confirm emits loading then error',
    build: () => ConfirmCaptureDraftCubit(
      _useCase(error: const ValidationFailure(message: 'account_required')),
    ),
    act: (ConfirmCaptureDraftCubit cubit) => cubit.fConfirmCaptureDraft(draft),
    expect: () => <Object>[
      isA<ApiCallLoading<FinanceRecords>>(),
      isA<ApiCallError<FinanceRecords>>(),
    ],
  );
}

ConfirmCaptureDraftUseCase _useCase({Failure? error}) {
  return ConfirmCaptureDraftUseCase(
    repository: CaptureRepositoryImpl(source: MemoryCaptureDraftDataSource()),
    saveIncome: SaveIncomeUseCase(_Book(error: error)),
    saveExpense: SaveExpenseUseCase(_Book(error: error)),
  );
}

class _Book implements TransactionsRepository {
  _Book({this.error});

  final Failure? error;

  @override
  Future<Either<Failure, FinanceRecords>> load() async =>
      Right(FinanceRecords.empty());

  @override
  Future<Either<Failure, FinanceRecords>> deleteTransaction(String id) async =>
      Right(FinanceRecords.empty());

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
    CommissionBasis commissionBasis = CommissionBasis.fixed,
    int commissionRateMinor = 0,
  }) async {
    final Failure? failure = error;
    if (failure != null) {
      return Left(failure);
    }
    return Right(FinanceRecords.empty());
  }
}
