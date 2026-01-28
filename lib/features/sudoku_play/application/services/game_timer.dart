import 'dart:async';

import 'package:flutter/foundation.dart';

/// Timer service backed by a [Stopwatch].
class GameTimer extends ChangeNotifier {
  static const Duration _tickInterval = Duration(seconds: 1);

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int _elapsedSeconds = 0;

  /// Elapsed time in seconds.
  int get elapsedSeconds => _elapsedSeconds;

  /// Starts the timer from zero.
  void start() {
    reset();
    _stopwatch.start();
    _startTicker();
  }

  /// Pauses the timer.
  void pause() {
    if (!_stopwatch.isRunning) {
      return;
    }
    _stopwatch.stop();
    _stopTicker();
    _refreshElapsedSeconds();
  }

  /// Resumes the timer.
  void resume() {
    if (_stopwatch.isRunning) {
      return;
    }
    _stopwatch.start();
    _startTicker();
    _refreshElapsedSeconds();
  }

  /// Resets the timer to zero.
  void reset() {
    _stopwatch
      ..reset()
      ..stop();
    _elapsedSeconds = 0;
    _stopTicker();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }

  void _startTicker() {
    _timer ??= Timer.periodic(_tickInterval, (_) => _refreshElapsedSeconds());
  }

  void _stopTicker() {
    _timer?.cancel();
    _timer = null;
  }

  void _refreshElapsedSeconds() {
    final nextValue = _stopwatch.elapsed.inSeconds;
    if (nextValue == _elapsedSeconds) {
      return;
    }
    _elapsedSeconds = nextValue;
    notifyListeners();
  }
}
