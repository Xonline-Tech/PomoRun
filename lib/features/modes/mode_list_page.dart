import 'package:flutter/material.dart';

import '../../data/preset_modes.dart';
import '../../models/mode.dart';
import 'mode_detail_page.dart';

class ModeListPage extends StatelessWidget {
  const ModeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final modes = PresetModes.all;
    return Scaffold(
      appBar: AppBar(title: const Text('选择运动模式')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: modes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final mode = modes[index];
          return _ModeCard(
            mode: mode,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ModeDetailPage(mode: mode),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.onTap});

  final ModeConfig mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mode.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text('${mode.defaultBpm} BPM'),
                ],
              ),
              const SizedBox(height: 8),
              Text(mode.feel, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _ChipText(text: '建议 ${mode.defaultDuration.inMinutes} 分钟'),
                  _ChipText(text: mode.kind == ModeKind.interval ? '间歇' : '稳态'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipText extends StatelessWidget {
  const _ChipText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
