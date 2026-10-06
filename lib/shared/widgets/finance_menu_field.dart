import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../core/utils/values/text_styles.dart';

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
