import 'package:either/either.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/features/capture/data/datasources/capture_draft_data_source.dart';
import 'package:finzomanager/features/capture/data/repositories/capture_repository_impl.dart';
import 'package:finzomanager/features/capture/domain/entities/capture_draft.dart';
import 'package:finzomanager/features/capture/domain/repositories/capture_repository.dart';
import 'package:finzomanager/features/capture/domain/usecases/confirm_capture_draft_use_case.dart';
import 'package:finzomanager/features/transactions/domain/usecases/save_expense_use_case.dart';
import 'package:finzomanager/features/transactions/domain/usecases/save_income_use_case.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:finzomanager/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _RecordingTransactions book;
  late CaptureRepository repository;
  late ConfirmCaptureDraftUseCase useCase;

  setUp(() {
    book = _RecordingTransactions();
    repository = CaptureRepositoryImpl(source: MemoryCaptureDraftDataSource());
    useCase = ConfirmCaptureDraftUseCase(
      repository: repository,
      saveIncome: SaveIncomeUseCase(book),
      saveExpense: SaveExpenseUseCase(book),
    );
  });

  test('a valid expense is saved once and the draft is cleared', () async {
    final result = await useCase(
      ConfirmCaptureDraftParams(draft: _draft(CaptureKind.expense)),
    );
    expect(
      result.fold((_) => null, (FinanceRecords value) => value),
      isNotNull,
    );
    expect(book.expenseCalls, 1);
    expect(book.incomeCalls, 0);
    final Either<Failure, CaptureDraft?> stored = await repository.read();
    expect(stored.fold((_) => null, (CaptureDraft? value) => value), isNull);
  });

  test('a valid income calls save income once and not expense', () async {
    await useCase(
      ConfirmCaptureDraftParams(
        draft: _draft(CaptureKind.income, accountType: AccountType.bank),
      ),
    );
    expect(book.incomeCalls, 1);
    expect(book.expenseCalls, 0);
    expect(book.lastCommission, 0);
  });

  test('a bank or e-wallet expense passes its commission', () async {
    await useCase(
      ConfirmCaptureDraftParams(
        draft: _draft(
          CaptureKind.expense,
          accountType: AccountType.bank,
          commissionMinor: 300,
        ),
      ),
    );
    expect(book.lastCommission, 300);

    final _RecordingTransactions walletBook = _RecordingTransactions();
    final ConfirmCaptureDraftUseCase walletUseCase = ConfirmCaptureDraftUseCase(
      repository: CaptureRepositoryImpl(source: MemoryCaptureDraftDataSource()),
      saveIncome: SaveIncomeUseCase(walletBook),
      saveExpense: SaveExpenseUseCase(walletBook),
    );
    await walletUseCase(
      ConfirmCaptureDraftParams(
        draft: _draft(
          CaptureKind.expense,
          accountType: AccountType.eWallet,
          commissionMinor: 150,
        ),
      ),
    );
    expect(walletBook.lastCommission, 150);
  });

  test('cash, other, and income pass a zero commission', () async {
    for (final AccountType type in <AccountType>[
      AccountType.cash,
      AccountType.other,
    ]) {
      final _RecordingTransactions recorder = _RecordingTransactions();
      await _freshUseCase(recorder)(
        ConfirmCaptureDraftParams(
          draft: _draft(
            CaptureKind.expense,
            accountType: type,
            commissionMinor: 400,
          ),
        ),
      );
      expect(recorder.lastCommission, 0);
    }
    final _RecordingTransactions incomeBook = _RecordingTransactions();
    await _freshUseCase(incomeBook)(
      ConfirmCaptureDraftParams(
        draft: _draft(
          CaptureKind.income,
          accountType: AccountType.bank,
          commissionMinor: 400,
        ),
      ),
    );
    expect(incomeBook.lastCommission, 0);
    expect(incomeBook.expenseCalls, 0);
  });

  test('a save failure leaves the draft held', () async {
    book.error = const ValidationFailure(message: 'account_required');
    final CaptureDraft draft = _draft(CaptureKind.expense);
    final result = await useCase(ConfirmCaptureDraftParams(draft: draft));
    expect(
      result.fold((Failure failure) => failure.message, (_) => null),
      'account_required',
    );
    final Either<Failure, CaptureDraft?> stored = await repository.read();
    expect(stored.fold((_) => null, (CaptureDraft? value) => value), draft);
  });

  test('a second confirm after success does not save again', () async {
    final ConfirmCaptureDraftParams params = ConfirmCaptureDraftParams(
      draft: _draft(CaptureKind.expense),
    );
    await useCase(params);
    await useCase(params);
    expect(book.expenseCalls, 1);
  });

  test('a shop name is not saved as the notes', () async {
    final _RecordingTransactions recorder = _RecordingTransactions();
    await _freshUseCase(recorder)(
      ConfirmCaptureDraftParams(
        draft: _draft(
          CaptureKind.expense,
        ).copyWith(notes: 'typed note', shopName: 'Market'),
      ),
    );
    expect(recorder.lastNotes, 'typed note');
    expect(recorder.expenseCalls, 1);
  });
}

ConfirmCaptureDraftUseCase _freshUseCase(_RecordingTransactions recorder) {
  return ConfirmCaptureDraftUseCase(
    repository: CaptureRepositoryImpl(source: MemoryCaptureDraftDataSource()),
    saveIncome: SaveIncomeUseCase(recorder),
    saveExpense: SaveExpenseUseCase(recorder),
  );
}

CaptureDraft _draft(
  CaptureKind kind, {
  AccountType accountType = AccountType.cash,
  int? commissionMinor,
}) {
  return CaptureDraft(
    kind: kind,
    date: const CalendarDate(2026, 10, 17),
    amountMinor: 20000,
    accountId: 'account',
    accountType: accountType,
    categoryId: 'food',
    commissionMinor: commissionMinor,
    uncertainFields: const <CaptureField>{},
  );
}

class _RecordingTransactions implements TransactionsRepository {
  int expenseCalls = 0;
  int incomeCalls = 0;
  int? lastCommission;
  String? lastNotes;
  Failure? error;

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
  }) async {
    if (type == MoneyTransactionType.expense) {
      expenseCalls += 1;
    }
    if (type == MoneyTransactionType.income) {
      incomeCalls += 1;
    }
    lastCommission = commissionMinor;
    lastNotes = notes;
    final Failure? failure = error;
    if (failure != null) {
      return Left(failure);
    }
    return Right(FinanceRecords.empty());
  }
}
