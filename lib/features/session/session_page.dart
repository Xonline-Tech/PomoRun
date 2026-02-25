import 'package:flutter/material.dart';

import '../../models/mode.dart';
import '../../utils/duration_format.dart';
import 'session_controller.dart';
import 'session_state.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({
    super.key,
    required this.mode,
    required this.bpm,
    required this.duration,
    required this.soundEnabled,
    required this.voiceEnabled,
    required this.hapticsEnabled,
  });

  final ModeConfig mode;
  final int bpm;
  final Duration duration;
  final bool soundEnabled;
  final bool voiceEnabled;
  final bool hapticsEnabled;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  late final SessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SessionController(
      mode: widget.mode,
      bpm: widget.bpm,
      totalDuration: widget.duration,
      soundEnabled: widget.soundEnabled,
      voiceEnabled: widget.voiceEnabled,
      hapticsEnabled: widget.hapticsEnabled,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final s = _controller.state;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.mode.name),
            actions: [
              IconButton(
                tooltip: s.soundEnabled ? '声音：开' : '声音：关',
                onPressed: () => _controller.toggleSound(!s.soundEnabled),
                icon: Icon(s.soundEnabled ? Icons.volume_up : Icons.volume_off),
              ),
              IconButton(
                tooltip: s.voiceEnabled ? '语音：开' : '语音：关',
                onPressed: () => _controller.toggleVoice(!s.voiceEnabled),
                icon: Icon(s.voiceEnabled ? Icons.record_voice_over : Icons.voice_over_off),
              ),
              IconButton(
                tooltip: s.hapticsEnabled ? '振动：开' : '振动：关',
                onPressed: () => _controller.toggleHaptics(!s.hapticsEnabled),
                icon: Icon(s.hapticsEnabled ? Icons.vibration : Icons.smartphone),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeaderCard(state: s),
                const SizedBox(height: 12),
                _ProgressCard(state: s),
                const Spacer(),
                _Controls(
                  status: s.status,
                  onStart: _controller.start,
                  onPause: _controller.pause,
                  onFinish: () {
                    _controller.finish();
                    Navigator.of(context).maybePop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.state});
  final SessionState state;

  @override
  Widget build(BuildContext context) {
    final bpm = state.currentSegment.bpm;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.currentSegment.label}  ·  $bpm BPM',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '本段剩余 ${formatClock(state.segmentRemaining)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Text(
              bpm.toString(),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.state});
  final SessionState state;

  @override
  Widget build(BuildContext context) {
    final progress = state.totalDuration.inMilliseconds == 0
        ? 0.0
        : (state.totalElapsed.inMilliseconds / state.totalDuration.inMilliseconds).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('已用 ${formatClock(state.totalElapsed)}'),
                Text('剩余 ${formatClock(state.totalRemaining)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onFinish,
  });

  final SessionStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final isRunning = status == SessionStatus.running;
    final isPaused = status == SessionStatus.paused;
    final isIdle = status == SessionStatus.idle;

    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: isRunning ? onPause : onStart,
            child: Text(isRunning ? '暂停' : (isPaused ? '继续' : (isIdle ? '开始' : '开始'))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: onFinish,
            child: const Text('结束'),
          ),
        ),
      ],
    );
  }
}
