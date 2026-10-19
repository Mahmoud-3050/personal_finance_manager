/// How a transfer commission is entered.
enum CommissionBasis { fixed, percentage }

/// Converts a percent rate into piastres.
///
/// [rateMinor] uses the same two-decimal scale as money, but as a percent:
/// `100` means 1.00%. Result is integer half-up of
/// `amountMinor * rateMinor / 10000`.
int percentageCommissionMinor({
  required int amountMinor,
  required int rateMinor,
}) {
  if (amountMinor < 0 || rateMinor < 0) {
    throw ArgumentError('amount and rate must be non-negative');
  }
  final int product = amountMinor * rateMinor;
  final int quotient = product ~/ 10000;
  final int remainder = product % 10000;
  if (remainder >= 5000) {
    return quotient + 1;
  }
  return quotient;
}
