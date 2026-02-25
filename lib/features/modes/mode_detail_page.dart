import 'package:flutter/material.dart';

import '../../models/mode.dart';
import '../session/session_page.dart';

class ModeDetailPage extends StatefulWidget {
  const ModeDetailPage({super.key, required this.mode});
  final ModeConfig mode;

  @override
  State<ModeDetailPage> createState() => _ModeDetailPageState();
}

class _ModeDetailPageState extends State<ModeDetailPage> {
  late int _bpm;
  late Duration _duration;
  bool _soundEnabled = true;
  bool _voiceEnabled = true;
  bool _hapticsEnabled = false;

  @override
  void initState() {
    super.initState();
    _bpm = widget.mode.defaultBpm;
    _duration = widget.mode.defaultDuration;
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    final bpmAdjustable = mode.kind == ModeKind.steady;
    final durationAdjustable = mode.kind == ModeKind.steady;

    return Scaffold(
      appBar: AppBar(title: Text(mode.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(mode.feel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _InfoCard(title: '适合人群', body: mode.suitableFor),
          const SizedBox(height: 10),
          _InfoCard(title: '语音提醒', body: mode.voiceRule),
          const SizedBox(height: 10),
          _InfoCard(title: '注意事项', body: mode.notes),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('参数', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _SliderRow(
                    label: '步频（BPM）',
                    valueText: '$_bpm',
                    enabled: bpmAdjustable,
                    child: Slider(
                      value: _bpm.toDouble(),
                      min: mode.minBpm.toDouble(),
                      max: mode.maxBpm.toDouble(),
                      divisions: (mode.maxBpm - mode.minBpm),
                      onChanged: bpmAdjustable
                          ? (v) {
                              setState(() => _bpm = v.round());
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _SliderRow(
                    label: '总时长（分钟）',
                    valueText: '${_duration.inMinutes}',
                    enabled: durationAdjustable,
                    child: Slider(
                      value: _duration.inMinutes.toDouble(),
                      min: (mode.defaultDuration.inMinutes - 10).clamp(5, 240).toDouble(),
                      max: (mode.defaultDuration.inMinutes + 10).clamp(5, 240).toDouble(),
                      divisions: 20,
                      onChanged: durationAdjustable
                          ? (v) {
                              setState(() => _duration = Duration(minutes: v.round()));
                            }
                          : null,
                    ),
                  ),
                  const Divider(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _soundEnabled,
                    title: const Text('提示音（节拍器）'),
                    onChanged: (v) => setState(() => _soundEnabled = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _voiceEnabled,
                    title: const Text('语音提醒'),
                    onChanged: (v) => setState(() => _voiceEnabled = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _hapticsEnabled,
                    title: const Text('振动提醒'),
                    onChanged: (v) => setState(() => _hapticsEnabled = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SessionPage(
                    mode: mode,
                    bpm: _bpm,
                    duration: _duration,
                    soundEnabled: _soundEnabled,
                    voiceEnabled: _voiceEnabled,
                    hapticsEnabled: _hapticsEnabled,
                  ),
                ),
              );
            },
            child: const Text('开始训练'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.valueText,
    required this.child,
    required this.enabled,
  });

  final String label;
  final String valueText;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(valueText, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
