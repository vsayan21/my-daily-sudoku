import 'dart:async';

import 'package:flutter/foundation.dart';

/// Timer service backed by a [Stopwatch].
class GameTimer extends ChangeNotifier {
  static const Duration _tickInterval = Duration(seconds: 1);

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int _stopwatchSeconds = 0;
  int _baseSeconds = 0;

  /// Elapsed time in seconds.
  int get elapsedSeconds => _stopwatchSeconds;

  /// Starts the timer from zero.
  void start() {
    startFrom(0);
  }

  /// Starts the timer from a given elapsed seconds value.
  void startFrom(int elapsedSeconds) {
    _baseSeconds = elapsedSeconds;
    _stopwatchSeconds = elapsedSeconds;
    _stopwatch
      ..reset()
      ..start();
    _startTicker();
    notifyListeners();
  }

  /// Pauses the timer.
  void pause() {
    if (!_stopwatch.isRunning) {
      return;
    }
    _baseSeconds = _baseSeconds + _stopwatch.elapsed.inSeconds;
    _stopwatch
      ..reset()
      ..stop();
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
    _stopwatchSeconds = 0;
    _baseSeconds = 0;
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
    final nextValue = _baseSeconds + _stopwatch.elapsed.inSeconds;
    if (nextValue == _stopwatchSeconds) {
      return;
    }
    _stopwatchSeconds = nextValue;
    notifyListeners();
  }
}
