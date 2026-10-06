import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../domain/entities/money_transaction.dart';
import 'movement_style.dart';

class MovementMark extends StatelessWidget {
  const MovementMark({required this.type, this.categoryName, super.key});

  final MoneyTransactionType type;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final Color tone = movementTone(context.colors, type);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 44.r,
        child: Icon(
          movementIcon(type, categoryName),
          color: tone,
          size: 20.r,
        ),
      ),
    );
  }
}
