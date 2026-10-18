import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

import '../../config/language/strings.dart';
import '../domain/entities/calendar_date.dart';
import 'platform/platform_target.dart';

const CalendarDate _earliestSelectableDate = CalendarDate(2000, 1, 1);
const CalendarDate _latestSelectableDate = CalendarDate(2100, 1, 1);
const double _iosDatePickerHeight = 216;

/// Shows the platform date picker and returns the chosen day.
///
/// iOS uses the Cupertino wheel. Android uses the Material date dialog.
Future<CalendarDate?> showPlatformDatePicker({
  required BuildContext context,
  required CalendarDate initialDate,
  CalendarDate firstDate = _earliestSelectableDate,
  CalendarDate lastDate = _latestSelectableDate,
}) async {
  final DateTime earliest = firstDate.toDateTime();
  final DateTime latest = lastDate.toDateTime();
  final DateTime initial = _clampDate(
    initialDate.toDateTime(),
    earliest,
    latest,
  );
  final DateTime? picked = usesIosComponents(context)
      ? await _showIosDatePicker(
          context: context,
          initialDate: initial,
          firstDate: earliest,
          lastDate: latest,
        )
      : await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: earliest,
          lastDate: latest,
        );
  if (picked == null) {
    return null;
  }
  return CalendarDate.fromDateTime(picked);
}

DateTime _clampDate(DateTime value, DateTime earliest, DateTime latest) {
  if (value.isBefore(earliest)) {
    return earliest;
  }
  if (value.isAfter(latest)) {
    return latest;
  }
  return value;
}

Future<DateTime?> _showIosDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return PlatformDatePicker(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    },
  );
}

class PlatformDatePicker extends StatefulWidget {
  const PlatformDatePicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    super.key,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<PlatformDatePicker> createState() => _PlatformDatePickerState();
}

class _PlatformDatePickerState extends State<PlatformDatePicker> {
  late DateTime _selectedDate = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _DatePickerToolbar(
              onCancel: () => Navigator.of(context).pop(),
              onDone: () => Navigator.of(context).pop(_selectedDate),
            ),
            SizedBox(
              height: _iosDatePickerHeight,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: widget.initialDate,
                minimumDate: widget.firstDate,
                maximumDate: widget.lastDate,
                onDateTimeChanged: (DateTime value) => _selectedDate = value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerToolbar extends StatelessWidget {
  const _DatePickerToolbar({required this.onCancel, required this.onDone});

  final VoidCallback onCancel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CupertinoButton(onPressed: onCancel, child: Text(Strings.cancel)),
        const Spacer(),
        CupertinoButton(onPressed: onDone, child: Text(Strings.done)),
      ],
    );
  }
}
