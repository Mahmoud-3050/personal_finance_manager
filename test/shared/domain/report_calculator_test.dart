import 'package:finzomanager/shared/domain/services/report_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a zero total is 0 percent and one third rounds to one decimal', () {
    expect(percentageLabel(0, 0), '0%');
    expect(percentageLabel(1, 3), '33.3%');
  });
}
