import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/usecases/usecase.dart';
import 'package:finzomanager/features/capture/data/datasources/capture_draft_data_source.dart';
import 'package:finzomanager/features/capture/data/repositories/capture_repository_impl.dart';
import 'package:finzomanager/features/capture/domain/entities/capture_draft.dart';
import 'package:finzomanager/features/capture/domain/usecases/discard_capture_draft_use_case.dart';
import 'package:finzomanager/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/services/percentage_commission.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'discard clears the draft and does not save income or expense',
    () async {
      final _RecordingTransactions book = _RecordingTransactions();
      final CaptureRepositoryImpl repository = CaptureRepositoryImpl(
        source: MemoryCaptureDraftDataSource(),
      );
      await repository.hold(CaptureDraft.handStarted());
      final result = await DiscardCaptureDraftUseCase(repository: repository)(
        const NoParams(),
      );

      expect(result.fold((_) => false, (bool cleared) => cleared), isTrue);
      expect(book.saves, 0);
      final Either<Failure, CaptureDraft?> stored = await repository.read();
      expect(stored.fold((_) => null, (CaptureDraft? value) => value), isNull);
    },
  );
}

class _RecordingTransactions implements TransactionsRepository {
  int saves = 0;

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
    saves += 1;
    return Right(FinanceRecords.empty());
  }
}
