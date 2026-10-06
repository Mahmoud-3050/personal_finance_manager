import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('week is Saturday through Friday and a reversed range is rejected', () {
    final DateRange week = CalendarDate.weekContaining(const CalendarDate(2026, 10, 6));
    expect(week.start, const CalendarDate(2026, 10, 3));
    expect(week.end, const CalendarDate(2026, 10, 9));
    final DateRange month = CalendarDate.monthContaining(const CalendarDate(2026, 10, 6));
    expect(month.start, const CalendarDate(2026, 10, 1));
    expect(month.end, const CalendarDate(2026, 10, 31));
    expect(
      DateRange.tryCreate(const CalendarDate(2026, 10, 9), const CalendarDate(2026, 10, 3)),
      isNull,
    );
  });
}
