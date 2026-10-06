import 'package:equatable/equatable.dart';

final class CalendarDate extends Equatable implements Comparable<CalendarDate> {
  const CalendarDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  factory CalendarDate.today() => CalendarDate.fromDateTime(DateTime.now());

  factory CalendarDate.fromDateTime(DateTime value) {
    return CalendarDate(value.year, value.month, value.day);
  }

  factory CalendarDate.parse(String value) {
    final List<String> parts = value.split('-');
    return CalendarDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  DateTime toDateTime() => DateTime(year, month, day);

  String toIso() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  CalendarDate addDays(int days) {
    return CalendarDate.fromDateTime(toDateTime().add(Duration(days: days)));
  }

  static DateRange weekContaining(CalendarDate date) {
    final int weekday = date.toDateTime().weekday;
    final int daysSinceSaturday = (weekday + 1) % 7;
    final CalendarDate start = date.addDays(-daysSinceSaturday);
    return DateRange(start, start.addDays(6));
  }

  static DateRange monthContaining(CalendarDate date) {
    final CalendarDate start = CalendarDate(date.year, date.month, 1);
    final CalendarDate end = CalendarDate.fromDateTime(
      DateTime(date.year, date.month + 1, 0),
    );
    return DateRange(start, end);
  }

  bool isBefore(CalendarDate other) => compareTo(other) < 0;

  bool isAfter(CalendarDate other) => compareTo(other) > 0;

  @override
  int compareTo(CalendarDate other) => toIso().compareTo(other.toIso());

  @override
  List<Object?> get props => <Object?>[year, month, day];
}

final class DateRange extends Equatable {
  const DateRange(this.start, this.end);

  final CalendarDate start;
  final CalendarDate end;

  static DateRange? tryCreate(CalendarDate start, CalendarDate end) {
    if (end.isBefore(start)) {
      return null;
    }
    return DateRange(start, end);
  }

  bool contains(CalendarDate date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  @override
  List<Object?> get props => <Object?>[start, end];
}
