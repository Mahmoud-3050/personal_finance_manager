import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../domain/entities/account.dart';

class AccountMark extends StatelessWidget {
  const AccountMark({required this.type, super.key});

  final AccountType type;

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 44.r,
        child: Icon(_icon, color: colors.success, size: 20.r),
      ),
    );
  }

  IconData get _icon => switch (type) {
    AccountType.bank => Icons.account_balance_outlined,
    AccountType.eWallet => Icons.account_balance_wallet_outlined,
    AccountType.cash => Icons.payments_outlined,
    AccountType.other => Icons.savings_outlined,
  };
}
