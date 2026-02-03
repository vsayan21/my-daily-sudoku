import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../daily_sudoku/shared/daily_key.dart';
import '../domain/entities/ranking_entry.dart';
import '../domain/ranking_repository.dart';

class CachedRanking {
  const CachedRanking({required this.entries, required this.fetchedAt});

  final List<RankingEntry> entries;
  final DateTime fetchedAt;
}

class RankingController extends ChangeNotifier with WidgetsBindingObserver {
  RankingController({
    required RankingRepository repository,
    required Future<String> Function() uidProvider,
  })  : _repository = repository,
        _uidProvider = uidProvider,
        _selectedDifficulty = SudokuDifficulty.easy,
        _selectedDateKey = buildDailyKey();

  final RankingRepository _repository;
  final Future<String> Function() _uidProvider;
  final Map<String, CachedRanking> _cache = {};

  SudokuDifficulty _selectedDifficulty;
  String _selectedDateKey;
  bool _isLoading = false;
  Object? _error;
  String? _currentUid;
  DateTime? _lastPausedAt;
  String _lastKnownTodayKey = buildDailyKey();

  SudokuDifficulty get selectedDifficulty => _selectedDifficulty;
  String get selectedDateKey => _selectedDateKey;
  bool get isLoading => _isLoading;
  Object? get error => _error;
  String? get currentUid => _currentUid;

  List<RankingEntry> get entries =>
      _cache[_cacheKey()]?.entries ?? const <RankingEntry>[];

  DateTime? get lastUpdated => _cache[_cacheKey()]?.fetchedAt;

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    _currentUid = await _uidProvider();
    await loadIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> loadIfNeeded({bool force = false}) async {
    final key = _cacheKey();
    if (!force && _cache.containsKey(key)) {
      return;
    }
    await _loadRanking();
  }

  Future<void> refresh() async {
    await _loadRanking();
  }

  void setDifficulty(SudokuDifficulty difficulty) {
    if (difficulty == _selectedDifficulty) {
      return;
    }
    _selectedDifficulty = difficulty;
    _error = null;
    notifyListeners();
    loadIfNeeded();
  }

  void setDateKey(String dateKey) {
    if (dateKey == _selectedDateKey) {
      return;
    }
    _selectedDateKey = dateKey;
    _error = null;
    notifyListeners();
    loadIfNeeded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _lastPausedAt = DateTime.now();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _handleResume();
    }
  }

  Future<void> _handleResume() async {
    final now = DateTime.now();
    final nowKey = buildDailyKey(now: now);
    final elapsed = _lastPausedAt == null
        ? null
        : now.difference(_lastPausedAt!);
    final shouldRefresh =
        (elapsed != null && elapsed > const Duration(seconds: 60)) ||
            nowKey != _lastKnownTodayKey;
    if (!shouldRefresh) {
      return;
    }
    _lastKnownTodayKey = nowKey;
    await refresh();
  }

  Future<void> _loadRanking() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final entries = await _repository.fetchRanking(
        dateKey: _selectedDateKey,
        difficulty: _selectedDifficulty,
      );
      _cache[_cacheKey()] = CachedRanking(
        entries: entries,
        fetchedAt: DateTime.now(),
      );
      _lastKnownTodayKey = buildDailyKey();
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _cacheKey() => '${_selectedDateKey}_${_selectedDifficulty.name}';
}
