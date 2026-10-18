import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../config/language/strings.dart';
import '../../core/utils/values/text_styles.dart';
import 'platform/platform_target.dart';

class FinanceMenuField<T> extends StatelessWidget {
  const FinanceMenuField({
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    super.key,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (usesIosComponents(context)) {
      return _IosMenuField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        label: label,
      );
    }
    final ThemeColors colors = context.colors;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: colors.border),
    );
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colors.foreground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          style: TextStyles.of(size: 16),
        ),
      ),
    );
  }
}

class _IosMenuField<T> extends StatelessWidget {
  const _IosMenuField({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    final String selected = _labelFor(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null) ...<Widget>[
          Text(
            label!,
            style: TextStyles.of(size: 13, color: colors.textSecondary),
          ),
          SizedBox(height: 6.h),
        ],
        CupertinoButton(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          color: colors.foreground,
          borderRadius: BorderRadius.circular(8.r),
          onPressed: onChanged == null ? null : () => _openSheet(context),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  selected,
                  maxLines: 1,
                  style: TextStyles.of(size: 16),
                ),
              ),
              Icon(CupertinoIcons.chevron_down, color: colors.hint, size: 16.r),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openSheet(BuildContext context) {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: label == null ? null : Text(label!),
          actions: <Widget>[
            for (final DropdownMenuItem<T> item in items)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  onChanged?.call(item.value);
                },
                child: Text(_labelFor(item.value)),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(Strings.cancel),
          ),
        );
      },
    );
  }

  String _labelFor(T? candidate) {
    for (final DropdownMenuItem<T> item in items) {
      final Widget child = item.child;
      if (item.value == candidate && child is Text) {
        return child.data ?? '';
      }
    }
    return '';
  }
}
