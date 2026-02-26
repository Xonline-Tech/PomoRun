import 'package:flutter/material.dart';

import '../../models/mode.dart';
import '../../models/workout_record.dart';
import '../../services/honor_progress_service.dart';
import '../../ui/app_background.dart';
import '../../ui/mode_theme.dart';
import '../../utils/duration_format.dart';
import 'session_controller.dart';
import 'session_state.dart';
import 'session_summary_page.dart';

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
  bool _navigated = false;

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
        final modeTheme = buildModeTheme(context, widget.mode);
        final lockBack = s.status == SessionStatus.running ||
            s.status == SessionStatus.paused;
        if (s.status == SessionStatus.finished && !_navigated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _goToSummary();
          });
        }
        return Theme(
          data: modeTheme,
          child: WillPopScope(
            onWillPop: () async => !lockBack,
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(widget.mode.name),
                automaticallyImplyLeading: !lockBack,
              ),
              body: AppBackground(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: _CenterStats(
                              state: s,
                              modeName: widget.mode.name,
                            ),
                          ),
                        ),
                        _Controls(
                          status: s.status,
                          soundEnabled: s.soundEnabled,
                          voiceEnabled: s.voiceEnabled,
                          hapticsEnabled: s.hapticsEnabled,
                          onToggleSound: () =>
                              _controller.toggleSound(!s.soundEnabled),
                          onToggleVoice: () =>
                              _controller.toggleVoice(!s.voiceEnabled),
                          onToggleHaptics: () =>
                              _controller.toggleHaptics(!s.hapticsEnabled),
                          onStart: _controller.start,
                          onPause: _controller.pause,
                          onFinish: () {
                            _controller.finish();
                            _goToSummary();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _goToSummary() async {
    if (_navigated) return;
    _navigated = true;
    final elapsed = _controller.state.totalElapsed;
    final startedAt = _controller.startedAt ??
        DateTime.now().subtract(elapsed.isNegative ? Duration.zero : elapsed);
    final record = WorkoutRecord(
      modeId: widget.mode.id,
      startedAt: startedAt,
      duration: elapsed,
      bpm: widget.bpm,
      isInterval: widget.mode.kind == ModeKind.interval,
    );
    final update = await HonorProgressService().recordWorkout(record);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SessionSummaryPage(
          mode: widget.mode,
          record: record,
          progress: update.progress.summary,
          newlyUnlocked: update.newlyUnlocked,
        ),
      ),
    );
  }
}

class _CenterStats extends StatelessWidget {
  const _CenterStats({required this.state, required this.modeName});

  final SessionState state;
  final String modeName;

  @override
  Widget build(BuildContext context) {
    final bpm = state.currentSegment.bpm;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          modeName,
          textAlign: TextAlign.center,
          style: textTheme.labelLarge?.copyWith(
            letterSpacing: 1.4,
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$bpm',
          textAlign: TextAlign.center,
          style: textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 84,
            height: 0.95,
          ),
        ),
        Text(
          'BPM',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '本段剩余 ${formatClock(state.segmentRemaining)}',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          '总用时 ${formatClock(state.totalElapsed)}',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '总剩余 ${formatClock(state.totalRemaining)}',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.status,
    required this.soundEnabled,
    required this.voiceEnabled,
    required this.hapticsEnabled,
    required this.onToggleSound,
    required this.onToggleVoice,
    required this.onToggleHaptics,
    required this.onStart,
    required this.onPause,
    required this.onFinish,
  });

  final SessionStatus status;
  final bool soundEnabled;
  final bool voiceEnabled;
  final bool hapticsEnabled;
  final VoidCallback onToggleSound;
  final VoidCallback onToggleVoice;
  final VoidCallback onToggleHaptics;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final isRunning = status == SessionStatus.running;
    final isPaused = status == SessionStatus.paused;
    final isIdle = status == SessionStatus.idle;
    final showEndControls = isRunning || isPaused;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Visibility(
          visible: showEndControls,
          maintainState: true,
          maintainAnimation: true,
          maintainSize: true,
          maintainSemantics: false,
          maintainInteractivity: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SizedBox(
              width: double.infinity,
              child: _SlideToEnd(
                onConfirmed: onFinish,
                active: showEndControls,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundActionButton(
              size: 72,
              label: voiceEnabled ? '语音' : '静音',
              icon:
                  voiceEnabled ? Icons.record_voice_over : Icons.voice_over_off,
              filled: false,
              onPressed: onToggleVoice,
            ),
            const SizedBox(width: 18),
            _RoundActionButton(
              size: 96,
              label: isRunning ? '暂停' : (isPaused ? '继续' : '开始'),
              icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              filled: true,
              onPressed: isRunning ? onPause : onStart,
            ),
            const SizedBox(width: 18),
            _RoundActionButton(
              size: 56,
              label: soundEnabled ? '声音' : '静音',
              icon: soundEnabled ? Icons.volume_up : Icons.volume_off,
              filled: false,
              onPressed: onToggleSound,
            ),
            const SizedBox(width: 14),
            _RoundActionButton(
              size: 56,
              label: hapticsEnabled ? '振动' : '无振',
              icon: hapticsEnabled ? Icons.vibration : Icons.smartphone,
              filled: false,
              onPressed: onToggleHaptics,
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.size,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.filled,
  });

  final double size;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final background = filled ? colorScheme.primary : colorScheme.surface;
    final foreground = filled ? colorScheme.onPrimary : colorScheme.primary;
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Material(
            color: background,
            shape: const CircleBorder(),
            elevation: filled ? 4 : 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Icon(icon, color: foreground, size: size * 0.45),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: size <= 56 ? 11 : 13,
          ),
        ),
      ],
    );
  }
}

class _SlideToEnd extends StatefulWidget {
  const _SlideToEnd({required this.onConfirmed, required this.active});

  final VoidCallback onConfirmed;
  final bool active;

  @override
  State<_SlideToEnd> createState() => _SlideToEndState();
}

class _SlideToEndState extends State<_SlideToEnd> {
  double _position = 0;
  bool _isDragging = false;
  bool _confirmed = false;

  void _handleDragUpdate(double delta, double maxPosition) {
    if (_confirmed || !widget.active) return;
    setState(() {
      _isDragging = true;
      _position = (_position + delta).clamp(0, maxPosition);
    });
  }

  void _handleDragEnd(double maxPosition) {
    if (_confirmed || !widget.active) return;
    final shouldConfirm = _position >= maxPosition * 0.7;
    setState(() {
      _isDragging = false;
      _position = shouldConfirm ? maxPosition : 0;
      _confirmed = shouldConfirm;
    });
    if (shouldConfirm) {
      widget.onConfirmed();
    }
  }

  @override
  void didUpdateWidget(covariant _SlideToEnd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active && oldWidget.active) {
      _confirmed = false;
      _position = 0;
      _isDragging = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = 64.0;
        final padding = 5.0;
        final thumbSize = height - padding * 2;
        final maxPosition = (constraints.maxWidth - thumbSize - padding * 2)
            .clamp(0.0, double.infinity);
        final progress =
            maxPosition == 0 ? 0.0 : (_position / maxPosition).clamp(0.0, 1.0);

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(999),
            border:
                Border.all(color: colorScheme.outlineVariant.withOpacity(0.6)),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                child: Center(
                  child: Text(
                    _confirmed ? '已结束' : '滑动结束',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant
                          .withOpacity(0.85 - progress * 0.5),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: _isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                left: padding + _position,
                top: padding,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _handleDragUpdate(details.delta.dx, maxPosition),
                  onHorizontalDragEnd: (_) => _handleDragEnd(maxPosition),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock_open_rounded,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
