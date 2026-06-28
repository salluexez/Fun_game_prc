import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/wingo_model.dart';

class WingoViewModel extends ChangeNotifier {
  late WingoState _state;
  Timer? _timer;
  final Random _random = Random();

  WingoViewModel() {
    _initializeGame(WingoTabType.seconds30);

    // Start running the countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  WingoState get state => _state;

  void _initializeGame(WingoTabType tab) {
    // Generate initial draws matching the screenshot
    final initialHistory = _generateInitialHistory();
    final periodId = _generateStartPeriodId(tab);
    final duration = _getDuration(tab);

    _state = WingoState(
      activeTab: tab,
      timeRemaining: duration,
      periodId: periodId,
      history: initialHistory,
      multiplier: 1,
    );
  }

  void selectTab(WingoTabType tab) {
    if (_state.activeTab == tab) return;
    _initializeGame(tab);
    notifyListeners();
  }

  void selectMultiplier(int multiplier) {
    _state = _state.copyWith(multiplier: multiplier);
    notifyListeners();
  }

  void placeBet(String choice, int amount) {
    debugPrint('Placed bet: Choice: $choice, Amount: $amount, Multiplier: ${_state.multiplier}');
  }

  int _getDuration(WingoTabType tab) {
    switch (tab) {
      case WingoTabType.seconds30:
        return 30;
      case WingoTabType.minute1:
        return 60;
      case WingoTabType.minute3:
        return 180;
      case WingoTabType.minute5:
        return 300;
    }
  }

  String _generateStartPeriodId(WingoTabType tab) {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final typeCode = _getTabTypeCode(tab);
    // E.g. 20260628 10005 2198
    final randVal = 100000 + _random.nextInt(900000);
    return '$dateStr$typeCode$randVal';
  }

  String _getTabTypeCode(WingoTabType tab) {
    switch (tab) {
      case WingoTabType.seconds30:
        return '30';
      case WingoTabType.minute1:
        return '01';
      case WingoTabType.minute3:
        return '03';
      case WingoTabType.minute5:
        return '05';
    }
  }

  String _generateNextPeriodId(String current) {
    try {
      final base = current.substring(0, current.length - 4);
      final count = int.parse(current.substring(current.length - 4));
      final nextCountStr = (count + 1).toString().padLeft(4, '0');
      return '$base$nextCountStr';
    } catch (_) {
      return current;
    }
  }

  List<DrawResult> _generateInitialHistory() {
    return List.generate(5, (_) => _generateRandomDrawResult());
  }

  DrawResult _generateRandomDrawResult() {
    final number = _random.nextInt(10);
    return DrawResult(
      number: number,
      colors: getColorsForNumber(number),
    );
  }

  List<Color> getColorsForNumber(int number) {
    if (number == 0) {
      return const [Color(0xFFF34C43), Color(0xFF9E5CFF)]; // Red & Violet split
    }
    if (number == 5) {
      return const [Color(0xFF2CA87E), Color(0xFF9E5CFF)]; // Green & Violet split
    }
    if (number % 2 == 0) {
      return const [Color(0xFFF34C43)]; // Red
    }
    return const [Color(0xFF2CA87E)]; // Green
  }

  void _tick() {
    int nextTime = _state.timeRemaining - 1;
    if (nextTime <= 0) {
      // Draw time! Generate new winner
      final newDraw = _generateRandomDrawResult();
      final newHistory = List<DrawResult>.from(_state.history);
      newHistory.insert(0, newDraw);
      if (newHistory.length > 5) {
        newHistory.removeLast();
      }

      final nextPeriod = _generateNextPeriodId(_state.periodId);
      final resetDuration = _getDuration(_state.activeTab);

      _state = _state.copyWith(
        timeRemaining: resetDuration,
        periodId: nextPeriod,
        history: newHistory,
      );
    } else {
      _state = _state.copyWith(timeRemaining: nextTime);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
