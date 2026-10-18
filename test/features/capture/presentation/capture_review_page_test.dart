import 'package:either/either.dart';
import 'package:finzomanager/config/language/strings.dart';
import 'package:finzomanager/config/themes/app_theme.dart';
import 'package:finzomanager/config/themes/colors_palettes.dart';
import 'package:finzomanager/core/error/failures.dart';
import 'package:finzomanager/core/presentation/api_call_state.dart';
import 'package:finzomanager/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:finzomanager/features/accounts/domain/usecases/get_accounts_use_case.dart';
import 'package:finzomanager/features/accounts/presentation/controller/get_accounts/get_accounts_cubit.dart';
import 'package:finzomanager/features/capture/data/datasources/capture_draft_data_source.dart';
import 'package:finzomanager/features/capture/data/repositories/capture_repository_impl.dart';
import 'package:finzomanager/features/capture/domain/entities/capture_draft.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_image_source.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_photo.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_read_gate.dart';
import 'package:finzomanager/features/capture/domain/entities/receipt_reading.dart';
import 'package:finzomanager/features/capture/domain/repositories/receipt_capture_repository.dart';
import 'package:finzomanager/features/capture/domain/usecases/confirm_capture_draft_use_case.dart';
import 'package:finzomanager/features/capture/domain/usecases/delete_receipt_photo_use_case.dart';
import 'package:finzomanager/features/capture/domain/usecases/discard_capture_draft_use_case.dart';
import 'package:finzomanager/features/capture/presentation/controller/confirm_capture_draft/confirm_capture_draft_cubit.dart';
import 'package:finzomanager/features/capture/presentation/controller/discard_capture_draft/discard_capture_draft_cubit.dart';
import 'package:finzomanager/features/capture/presentation/controller/release_receipt_photo/release_receipt_photo_cubit.dart';
import 'package:finzomanager/features/capture/presentation/pages/capture_review_page.dart';
import 'package:finzomanager/features/categories/domain/repositories/categories_repository.dart';
import 'package:finzomanager/features/categories/domain/usecases/get_categories_use_case.dart';
import 'package:finzomanager/features/categories/presentation/controller/get_categories/get_categories_cubit.dart';
import 'package:finzomanager/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:finzomanager/features/transactions/domain/usecases/save_expense_use_case.dart';
import 'package:finzomanager/features/transactions/domain/usecases/save_income_use_case.dart';
import 'package:finzomanager/features/transactions/presentation/controller/save_expense/save_expense_cubit.dart';
import 'package:finzomanager/features/transactions/presentation/controller/save_income/save_income_cubit.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/category.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/entities/subcategory.dart';
import 'package:finzomanager/shared/domain/finance_records.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language/language.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await Language.instance.init();
    await Themes.instance.init(config: ColorsPalettes.config);
  });

  tearDown(resetThemes);

  testWidgets(
    'a hand-started draft is an expense dated today with no uncertain mark',
    (WidgetTester tester) async {
      final _Harness harness = _Harness();
      addTearDown(harness.close);
      await tester.pumpWidget(harness.build());
      await tester.pumpAndSettle();

      expect(find.text(Strings.fenzoExpense), findsWidgets);
      expect(find.text(CalendarDate.today().toIso()), findsOneWidget);
      expect(find.byKey(const Key('uncertain-amount')), findsNothing);
      expect(find.byKey(const Key('mark-uncertain')), findsNothing);
      expect(find.byKey(const Key('receipt-photo')), findsNothing);
      expect(find.byKey(const Key('shop-name')), findsNothing);
      expect(harness.book.saves, 0);
      expect(harness.saveIncome.state, isA<ApiCallHolding<FinanceRecords>>());
      expect(harness.saveExpense.state, isA<ApiCallHolding<FinanceRecords>>());
    },
  );

  testWidgets('a supplied draft shows an uncertain amount and does not save', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness(
      supplied: const CaptureDraft(
        kind: CaptureKind.expense,
        date: CalendarDate(2026, 10, 17),
        amountMinor: 5000,
        uncertainFields: <CaptureField>{CaptureField.amount},
      ),
    );
    addTearDown(harness.close);
    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('uncertain-amount')), findsOneWidget);
    expect(find.byKey(const Key('mark-uncertain')), findsNothing);
    expect(find.byKey(const Key('receipt-photo')), findsNothing);
    expect(find.byKey(const Key('shop-name')), findsNothing);
    expect(harness.book.saves, 0);
    expect(harness.saveIncome.state, isA<ApiCallHolding<FinanceRecords>>());
    expect(harness.saveExpense.state, isA<ApiCallHolding<FinanceRecords>>());
  });

  testWidgets(
    'no active account tells the person to add one and hides confirm',
    (WidgetTester tester) async {
      final _Harness harness = _Harness(withAccount: false);
      addTearDown(harness.close);
      await tester.pumpWidget(harness.build());
      await tester.pumpAndSettle();

      expect(find.text(Strings.fenzoEmpty), findsOneWidget);
      expect(find.text(Strings.fenzoCaptureConfirm), findsNothing);
    },
  );

  test('a failed confirm names the rule in a translated string', () {
    expect(captureFailureCopy('subcategory_invalid'), Strings.fenzoSubcategory);
    expect(
      captureFailureCopy('date_before_opening'),
      Strings.fenzoDateBeforeOpening,
    );
    expect(captureFailureCopy('not_a_known_code'), isNot('not_a_known_code'));
  });

  testWidgets('a receipt proposal shows the photo and an uncertain shop name', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness(
      supplied: const CaptureDraft(
        kind: CaptureKind.expense,
        date: CalendarDate(2026, 10, 17),
        uncertainFields: <CaptureField>{CaptureField.shopName},
      ),
      photo: const ReceiptPhoto(path: '/missing/receipt.png'),
    );
    addTearDown(harness.close);
    await tester.pumpWidget(harness.build());
    await tester.pump();

    expect(find.byKey(const Key('receipt-photo')), findsOneWidget);
    expect(find.byKey(const Key('uncertain-shopName')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('shop-name')), 'Market');
    await tester.pump();
    expect(harness.book.saves, 0);
    expect(harness.saveIncome.state, isA<ApiCallHolding<FinanceRecords>>());
    expect(harness.saveExpense.state, isA<ApiCallHolding<FinanceRecords>>());
  });
}

class _Harness {
  _Harness({this.supplied, this.photo, this.withAccount = true})
    : book = _CountingBook() {
    saveIncome = SaveIncomeCubit(SaveIncomeUseCase(book));
    saveExpense = SaveExpenseCubit(SaveExpenseUseCase(book));
  }

  final CaptureDraft? supplied;
  final ReceiptPhoto? photo;
  final bool withAccount;
  final _CountingBook book;
  late final SaveIncomeCubit saveIncome;
  late final SaveExpenseCubit saveExpense;

  Widget build() {
    final SaveIncomeUseCase saveIncomeUseCase = SaveIncomeUseCase(book);
    final SaveExpenseUseCase saveExpenseUseCase = SaveExpenseUseCase(book);
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          theme: appTheme(ColorsPalettes.config.light, Brightness.light),
          home: MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<GetAccountsCubit>(
                create: (_) => GetAccountsCubit(
                  GetAccountsUseCase(_EmptyAccounts(withAccount: withAccount)),
                ),
              ),
              BlocProvider<GetCategoriesCubit>(
                create: (_) => GetCategoriesCubit(
                  GetCategoriesUseCase(_EmptyCategories()),
                ),
              ),
              BlocProvider<SaveIncomeCubit>.value(value: saveIncome),
              BlocProvider<SaveExpenseCubit>.value(value: saveExpense),
              BlocProvider<ConfirmCaptureDraftCubit>(
                create: (_) => ConfirmCaptureDraftCubit(
                  ConfirmCaptureDraftUseCase(
                    repository: CaptureRepositoryImpl(
                      source: MemoryCaptureDraftDataSource(),
                    ),
                    saveIncome: saveIncomeUseCase,
                    saveExpense: saveExpenseUseCase,
                  ),
                ),
              ),
              BlocProvider<DiscardCaptureDraftCubit>(
                create: (_) => DiscardCaptureDraftCubit(
                  DiscardCaptureDraftUseCase(
                    repository: CaptureRepositoryImpl(
                      source: MemoryCaptureDraftDataSource(),
                    ),
                  ),
                ),
              ),
              BlocProvider<ReleaseReceiptPhotoCubit>(
                create: (_) => ReleaseReceiptPhotoCubit(
                  DeleteReceiptPhotoUseCase(repository: _QuietReceipts()),
                ),
              ),
            ],
            child: CaptureReviewPage(supplied: supplied, photo: photo),
          ),
        );
      },
    );
  }

  Future<void> close() async {
    await saveIncome.close();
    await saveExpense.close();
  }
}

Account _cashAccount() {
  return Account(
    id: 'cash',
    name: 'Cash',
    type: AccountType.cash,
    openingBalanceMinor: 0,
    openingDate: const CalendarDate(2026, 1, 1),
    isActive: true,
    includeInTotal: true,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

class _EmptyAccounts implements AccountsRepository {
  _EmptyAccounts({required this.withAccount});

  final bool withAccount;

  @override
  Future<Either<Failure, FinanceRecords>> load() async {
    if (!withAccount) {
      return Right(FinanceRecords.empty());
    }
    return Right(
      FinanceRecords(
        accounts: <Account>[_cashAccount()],
        categories: const <Category>[],
        subcategories: const <Subcategory>[],
        transactions: const <MoneyTransaction>[],
      ),
    );
  }

  @override
  Future<Either<Failure, FinanceRecords>> deactivateAccount(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, FinanceRecords>> deleteAccount(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, FinanceRecords>> reactivateAccount(String id) =>
      throw UnimplementedError();

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
  }) => throw UnimplementedError();
}

class _EmptyCategories implements CategoriesRepository {
  @override
  Future<Either<Failure, FinanceRecords>> load() async =>
      Right(FinanceRecords.empty());

  @override
  Future<Either<Failure, FinanceRecords>> deactivateCategory(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, FinanceRecords>> deleteCategory(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, FinanceRecords>> saveCategory({
    required String? id,
    required String? parentId,
    required String name,
    required CategoryKind kind,
  }) => throw UnimplementedError();
}

class _QuietReceipts implements ReceiptCaptureRepository {
  @override
  bool get sendsImageOffDevice => false;

  @override
  Future<Either<Failure, ReceiptPhoto?>> pick(ReceiptImageSource source) async {
    return const Right<Failure, ReceiptPhoto?>(null);
  }

  @override
  Future<Either<Failure, ReceiptReadGate>> prepare(ReceiptPhoto photo) async {
    return const Right<Failure, ReceiptReadGate>(
      ReceiptReadOnDevice(reading: ReceiptReading()),
    );
  }

  @override
  Future<Either<Failure, ReceiptReading>> read(ReceiptPhoto photo) async {
    return const Right<Failure, ReceiptReading>(ReceiptReading());
  }

  @override
  Future<Either<Failure, void>> delete(ReceiptPhoto photo) async {
    return const Right<Failure, void>(null);
  }
}

class _CountingBook implements TransactionsRepository {
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
  }) async {
    saves += 1;
    return Right(FinanceRecords.empty());
  }
}
