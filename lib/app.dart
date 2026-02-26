import 'package:flutter/material.dart';
import 'features/modes/mode_list_page.dart';
import 'ui/app_theme.dart';

class PomoRunApp extends StatelessWidget {
  const PomoRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0C7D6A),
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'PomoRun',
      theme: buildAppTheme(colorScheme: colorScheme),
      home: const ModeListPage(),
    );
  }
}
