import 'package:flutter/material.dart';

import 'features/modes/mode_list_page.dart';

class PomoRunApp extends StatelessWidget {
  const PomoRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PomoRun',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6F5B)),
        useMaterial3: true,
      ),
      home: const ModeListPage(),
    );
  }
}
