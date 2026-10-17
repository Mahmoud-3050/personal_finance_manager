import 'package:flutter/material.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../domain/entities/capture_draft.dart';

class CaptureUncertainMark extends StatelessWidget {
  const CaptureUncertainMark({required this.field, super.key});

  final CaptureField field;

  @override
  Widget build(BuildContext context) {
    return Text(
      Strings.fenzoCaptureUncertain,
      key: Key('uncertain-${field.name}'),
      style: TextStyles.of(size: 12, weight: FontWeight.w600),
    );
  }
}
