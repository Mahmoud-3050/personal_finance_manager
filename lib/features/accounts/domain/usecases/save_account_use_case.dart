import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/finance_records.dart';
import '../repositories/accounts_repository.dart';

class SaveAccountParams extends Params {
  const SaveAccountParams({
    required this.name,
    required this.type,
    required this.openingBalanceMinor,
    required this.openingDate,
    this.id,
    this.includeInTotal = true,
    this.bankName,
    this.accountNumber,
    this.phoneNumber,
    this.cancellation,
  });

  final String? id;
  final String name;
  final AccountType type;
  final int openingBalanceMinor;
  final CalendarDate openingDate;
  final bool includeInTotal;
  final String? bankName;
  final String? accountNumber;
  final String? phoneNumber;
  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'name': name};

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    type,
    openingBalanceMinor,
    openingDate,
    includeInTotal,
  ];
}

class SaveAccountUseCase extends UseCase<FinanceRecords, SaveAccountParams> {
  SaveAccountUseCase(this._repository);
  final AccountsRepository _repository;

  @override
  Future<Either<Failure, FinanceRecords>> call(SaveAccountParams params) {
    return _repository.saveAccount(
      id: params.id,
      name: params.name,
      type: params.type,
      openingBalanceMinor: params.openingBalanceMinor,
      openingDate: params.openingDate,
      includeInTotal: params.includeInTotal,
      bankName: params.bankName,
      accountNumber: params.accountNumber,
      phoneNumber: params.phoneNumber,
    );
  }
}
