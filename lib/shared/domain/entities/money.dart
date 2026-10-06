import 'package:either/either.dart';

import '../../../../core/error/failures.dart';

/// Egyptian pounds stored as piastres. 100 piastres = 1 EGP.
final class Money {
  const Money(this.minor);

  static const int scale = 100;

  final int minor;

  bool get isNegative => minor < 0;

  static Either<Failure, Money> parse(
    String raw, {
    required bool allowNegative,
    required bool allowZero,
  }) {
    final String trimmed = raw.trim().replaceAll(',', '.');
    if (trimmed.isEmpty) {
      return const Left(ValidationFailure(message: 'amount_required'));
    }
    final RegExp pattern = RegExp(r'^-?\d+(\.\d+)?$');
    if (!pattern.hasMatch(trimmed)) {
      return const Left(ValidationFailure(message: 'amount_invalid'));
    }
    final List<String> parts = trimmed.split('.');
    if (parts.length == 2 && parts[1].length > 2) {
      return const Left(ValidationFailure(message: 'amount_scale'));
    }
    final bool negative = trimmed.startsWith('-');
    final String digits = negative ? trimmed.substring(1) : trimmed;
    final List<String> unsigned = digits.split('.');
    final int whole = int.parse(unsigned[0]);
    final String fraction = unsigned.length == 2
        ? unsigned[1].padRight(2, '0')
        : '00';
    int minor = whole * scale + int.parse(fraction);
    if (negative) {
      minor = -minor;
    }
    if (!allowNegative && minor < 0) {
      return const Left(ValidationFailure(message: 'amount_positive'));
    }
    if (!allowZero && minor == 0) {
      return const Left(ValidationFailure(message: 'amount_positive'));
    }
    return Right(Money(minor));
  }

  String format() {
    final bool negative = minor < 0;
    final int absolute = minor.abs();
    final String whole = (absolute ~/ scale).toString();
    final String fraction = (absolute % scale).toString().padLeft(2, '0');
    return '${negative ? '-' : ''}$whole.$fraction';
  }
}
