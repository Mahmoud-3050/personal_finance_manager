import 'package:equatable/equatable.dart';

class AccountPeriodFigures extends Equatable {
  const AccountPeriodFigures({
    required this.accountId,
    required this.name,
    required this.startingMinor,
    required this.incomeMinor,
    required this.expenseMinor,
    required this.transfersInMinor,
    required this.transfersOutMinor,
    required this.endingMinor,
  });

  final String accountId;
  final String name;
  final int startingMinor;
  final int incomeMinor;
  final int expenseMinor;
  final int transfersInMinor;
  final int transfersOutMinor;
  final int endingMinor;

  @override
  List<Object?> get props => <Object?>[
    accountId,
    name,
    startingMinor,
    incomeMinor,
    expenseMinor,
    transfersInMinor,
    transfersOutMinor,
    endingMinor,
  ];
}
