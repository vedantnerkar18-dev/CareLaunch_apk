import 'package:flutter/material.dart';

/// A bubble that grows while the child breathes in (4 s) and shrinks while
/// they breathe out (6 s). One controller drives everything.
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  static const _inSeconds = 4;
  static const _outSeconds = 6;

  late final AnimationController _controller;
  late final Animation<double> _scale;
  int _breaths = 0;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _inSeconds + _outSeconds),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: _inSeconds.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.4)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: _outSeconds.toDouble(),
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _running) {
        setState(() => _breaths++);
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _controller.forward();
    } else {
      _controller.stop();
    }
  }

  void _reset() {
    _controller.stop();
    _controller.value = 0;
    setState(() {
      _running = false;
      _breaths = 0;
    });
  }

  String get _instruction {
    if (!_running && _controller.value == 0) return 'Press start when you are ready';
    if (!_running) return 'Paused';
    final inPhase = _controller.value < _inSeconds / (_inSeconds + _outSeconds);
    return inPhase ? 'Breathe in...' : 'Breathe out...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Breathing bubble')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _instruction,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 260,
                      child: Center(
                        child: Semantics(
                          label: 'Breathing bubble. Grows as you breathe in, '
                              'shrinks as you breathe out.',
                          child: Container(
                            width: 260 * _scale.value,
                            height: 260 * _scale.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.25),
                              border: Border.all(
                                color: theme.colorScheme.primary,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Breaths completed: $_breaths',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _toggle,
                      icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                      label: Text(_running ? 'Pause' : 'Start'),
                    ),
                    TextButton(onPressed: _reset, child: const Text('Reset')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}