import 'package:flutter/material.dart';

/// True when the surrounding theme is targeting iOS.
bool usesIosComponents(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS;
}
