import 'package:flutter/material.dart';

import '../models/mode.dart';
import 'app_theme.dart';

Color modeSeedColor(ModeConfig mode) {
  switch (mode.id) {
    case 'easy_jog':
      return const Color(0xFF2F9F84);
    case 'interval':
      return const Color(0xFFF08A24);
    case 'steady_long':
      return const Color(0xFF4A6CF7);
    case 'tempo':
      return const Color(0xFFE25555);
    case 'super_slow':
      return const Color(0xFF7CB342);
  }
  return const Color(0xFF0C7D6A);
}

ThemeData buildModeTheme(BuildContext context, ModeConfig mode) {
  final brightness = Theme.of(context).brightness;
  final colorScheme = ColorScheme.fromSeed(
      seedColor: modeSeedColor(mode), brightness: brightness);
  return buildAppTheme(colorScheme: colorScheme);
}
