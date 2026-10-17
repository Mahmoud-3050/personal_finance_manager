import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../transactions/domain/usecases/save_expense_use_case.dart';
import '../../../transactions/domain/usecases/save_income_use_case.dart';
import '../entities/capture_draft.dart';
import '../repositories/capture_repository.dart';

class ConfirmCaptureDraftParams extends Params {
  const ConfirmCaptureDraftParams({required this.draft, this.cancellation});

  final CaptureDraft draft;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'kind': draft.kind.name};

  @override
  List<Object?> get props => <Object?>[draft, cancellation];
}

class ConfirmCaptureDraftUseCase
    extends UseCase<FinanceRecords, ConfirmCaptureDraftParams> {
  ConfirmCaptureDraftUseCase({
    required CaptureRepository repository,
    required SaveIncomeUseCase saveIncome,
    required SaveExpenseUseCase saveExpense,
  }) : _repository = repository,
       _saveIncome = saveIncome,
       _saveExpense = saveExpense;

  final CaptureRepository _repository;
  final SaveIncomeUseCase _saveIncome;
  final SaveExpenseUseCase _saveExpense;

  @override
  Future<Either<Failure, FinanceRecords>> call(
    ConfirmCaptureDraftParams params,
  ) async {
    final Failure? blocked = await _blocked();
    if (blocked != null) {
      return Left<Failure, FinanceRecords>(blocked);
    }
    final CaptureDraft draft = params.draft;
    final Either<Failure, CaptureDraft> held = await _repository.hold(draft);
    final Failure? holdFailure = held.fold(
      (Failure failure) => failure,
      (_) => null,
    );
    if (holdFailure != null) {
      return Left<Failure, FinanceRecords>(holdFailure);
    }
    final Either<Failure, FinanceRecords> saved = await _save(draft);
    final Failure? saveFailure = saved.fold(
      (Failure failure) => failure,
      (_) => null,
    );
    if (saveFailure != null) {
      return Left<Failure, FinanceRecords>(saveFailure);
    }
    final Either<Failure, void> finished = await _repository.markFinished();
    return finished.fold(Left<Failure, FinanceRecords>.new, (_) => saved);
  }

  Future<Failure?> _blocked() async {
    final Either<Failure, bool> finished = await _repository.isFinished();
    return finished.fold((Failure failure) => failure, (bool alreadyConfirmed) {
      if (!alreadyConfirmed) {
        return null;
      }
      return const ValidationFailure(message: 'draft_finished');
    });
  }

  Future<Either<Failure, FinanceRecords>> _save(CaptureDraft draft) {
    return switch (draft.kind) {
      CaptureKind.income => _saveIncome(
        SaveIncomeParams(
          amountMinor: draft.amountMinor ?? 0,
          date: draft.date,
          accountId: draft.accountId,
          categoryId: draft.categoryId,
          subcategoryId: draft.subcategoryId,
          notes: draft.notes,
        ),
      ),
      CaptureKind.expense => _saveExpense(
        SaveExpenseParams(
          amountMinor: draft.amountMinor ?? 0,
          date: draft.date,
          accountId: draft.accountId,
          categoryId: draft.categoryId,
          subcategoryId: draft.subcategoryId,
          notes: draft.notes,
          commissionMinor: draft.commissionToSave,
        ),
      ),
    };
  }
}
