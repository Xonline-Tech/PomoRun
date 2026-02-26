import 'package:flutter/material.dart';

import '../../models/mode.dart';
import '../../ui/app_background.dart';
import '../../ui/mode_theme.dart';
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

    final modeTheme = buildModeTheme(context, mode);
    return Theme(
      data: modeTheme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(title: Text(mode.name)),
        body: AppBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _HeroCard(mode: mode, bpm: _bpm, duration: _duration),
                const SizedBox(height: 16),
                _InfoGroupCard(
                  suitableFor: mode.suitableFor,
                  voiceRule: mode.voiceRule,
                  notes: mode.notes,
                ),
                const SizedBox(height: 16),
                _ParamCard(
                  bpm: _bpm,
                  duration: _duration,
                  mode: mode,
                  bpmAdjustable: bpmAdjustable,
                  durationAdjustable: durationAdjustable,
                  soundEnabled: _soundEnabled,
                  voiceEnabled: _voiceEnabled,
                  hapticsEnabled: _hapticsEnabled,
                  onBpmChanged: (value) => setState(() => _bpm = value),
                  onDurationChanged: (value) =>
                      setState(() => _duration = value),
                  onSoundChanged: (value) =>
                      setState(() => _soundEnabled = value),
                  onVoiceChanged: (value) =>
                      setState(() => _voiceEnabled = value),
                  onHapticsChanged: (value) =>
                      setState(() => _hapticsEnabled = value),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
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
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('开始训练'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard(
      {required this.mode, required this.bpm, required this.duration});

  final ModeConfig mode;
  final int bpm;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final kindLabel = mode.kind == ModeKind.interval ? '间歇节奏' : '稳态节奏';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.65),
            colorScheme.surface.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kindLabel,
            style: textTheme.labelLarge?.copyWith(
              letterSpacing: 1.8,
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mode.name,
            style:
                textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            mode.feel,
            style: textTheme.bodyLarge
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _StatPill(label: '默认 BPM', value: bpm.toString()),
              _StatPill(label: '建议时长', value: '${duration.inMinutes} 分钟'),
              _StatPill(
                  label: '节奏类型',
                  value: mode.kind == ModeKind.interval ? '间歇' : '稳态'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoGroupCard extends StatelessWidget {
  const _InfoGroupCard({
    required this.suitableFor,
    required this.voiceRule,
    required this.notes,
  });

  final String suitableFor;
  final String voiceRule;
  final String notes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSection(title: '适合人群', body: suitableFor),
          const SizedBox(height: 12),
          _InfoSection(title: '语音提醒', body: voiceRule),
          const SizedBox(height: 12),
          _InfoSection(title: '注意事项', body: notes),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _ParamCard extends StatelessWidget {
  const _ParamCard({
    required this.bpm,
    required this.duration,
    required this.mode,
    required this.bpmAdjustable,
    required this.durationAdjustable,
    required this.soundEnabled,
    required this.voiceEnabled,
    required this.hapticsEnabled,
    required this.onBpmChanged,
    required this.onDurationChanged,
    required this.onSoundChanged,
    required this.onVoiceChanged,
    required this.onHapticsChanged,
  });

  final int bpm;
  final Duration duration;
  final ModeConfig mode;
  final bool bpmAdjustable;
  final bool durationAdjustable;
  final bool soundEnabled;
  final bool voiceEnabled;
  final bool hapticsEnabled;
  final ValueChanged<int> onBpmChanged;
  final ValueChanged<Duration> onDurationChanged;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onVoiceChanged;
  final ValueChanged<bool> onHapticsChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('参数设置',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _SliderRow(
            label: '步频（BPM）',
            valueText: '$bpm',
            enabled: bpmAdjustable,
            child: Slider(
              value: bpm.toDouble(),
              min: mode.minBpm.toDouble(),
              max: mode.maxBpm.toDouble(),
              divisions: (mode.maxBpm - mode.minBpm),
              onChanged: bpmAdjustable ? (v) => onBpmChanged(v.round()) : null,
            ),
          ),
          const SizedBox(height: 6),
          _SliderRow(
            label: '总时长（分钟）',
            valueText: '${duration.inMinutes}',
            enabled: durationAdjustable,
            child: Slider(
              value: duration.inMinutes.toDouble(),
              min: (mode.defaultDuration.inMinutes - 10)
                  .clamp(5, 240)
                  .toDouble(),
              max: (mode.defaultDuration.inMinutes + 10)
                  .clamp(5, 240)
                  .toDouble(),
              divisions: 20,
              onChanged: durationAdjustable
                  ? (v) => onDurationChanged(Duration(minutes: v.round()))
                  : null,
            ),
          ),
          const Divider(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: soundEnabled,
            title: const Text('提示音（节拍器）'),
            onChanged: onSoundChanged,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: voiceEnabled,
            title: const Text('语音提醒'),
            onChanged: onVoiceChanged,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: hapticsEnabled,
            title: const Text('振动提醒'),
            onChanged: onHapticsChanged,
          ),
        ],
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
