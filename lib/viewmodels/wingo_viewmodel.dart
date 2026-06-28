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
    // Generate initial draws
    final initialHistory = _generateInitialHistory();
    final periodId = _generateStartPeriodId(tab);
    final duration = _getDuration(tab);

    _state = WingoState(
      activeTab: tab,
      timeRemaining: duration,
      periodId: periodId,
      history: initialHistory,
      multiplier: 1,
      activeHistoryTab: WingoHistoryTab.gameHistory,
      myBets: const [],
    );
  }

  void selectTab(WingoTabType tab) {
    if (_state.activeTab == tab) return;
    _initializeGame(tab);
    notifyListeners();
  }

  void selectHistoryTab(WingoHistoryTab tab) {
    if (_state.activeHistoryTab == tab) return;
    _state = _state.copyWith(activeHistoryTab: tab);
    notifyListeners();
  }

  void selectMultiplier(int multiplier) {
    _state = _state.copyWith(multiplier: multiplier);
    notifyListeners();
  }

  void placeBet(String choice, int amount) {
    debugPrint('Placed bet: Choice: $choice, Amount: $amount, Multiplier: ${_state.multiplier}');
    
    final finalAmount = amount.toDouble();
    final newBet = WingoBet(
      periodId: _state.periodId,
      choice: choice,
      amount: finalAmount,
      timestamp: DateTime.now(),
    );

    final updatedBets = List<WingoBet>.from(_state.myBets);
    updatedBets.insert(0, newBet);

    _state = _state.copyWith(myBets: updatedBets);
    notifyListeners();
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
    return List.generate(10, (_) => _generateRandomDrawResult());
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

  bool _evaluateBetWin(String choice, int number) {
    if (choice == 'Big') return number >= 5;
    if (choice == 'Small') return number <= 4;
    if (choice == 'Green') return const [1, 3, 5, 7, 9].contains(number);
    if (choice == 'Red') return const [0, 2, 4, 6, 8].contains(number);
    if (choice == 'Violet') return const [0, 5].contains(number);
    
    // Exact number selection
    final parsedNumber = int.tryParse(choice);
    if (parsedNumber != null) {
      return parsedNumber == number;
    }
    return false;
  }

  double _calculatePayout(String choice, double amount, int number) {
    if (choice == 'Big' || choice == 'Small') return amount * 2.0;
    if (choice == 'Violet') return amount * 4.5;
    if (choice == 'Green' || choice == 'Red') {
      if (number == 0 || number == 5) {
        return amount * 1.5; // Split color win multiplier (violet + red/green)
      }
      return amount * 2.0;
    }
    // Exact number multiplier (9x)
    return amount * 9.0;
  }

  void _tick() {
    int nextTime = _state.timeRemaining - 1;
    if (nextTime <= 0) {
      final newDraw = _generateRandomDrawResult();
      final newHistory = List<DrawResult>.from(_state.history);
      newHistory.insert(0, newDraw);
      if (newHistory.length > 10) {
        newHistory.removeLast();
      }

      final currentPeriod = _state.periodId;
      final drawnNumber = newDraw.number;

      // Evaluate and resolve pending bets for the drawn period
      final updatedBets = _state.myBets.map((bet) {
        if (bet.periodId == currentPeriod && !bet.isResolved) {
          final won = _evaluateBetWin(bet.choice, drawnNumber);
          final payout = won ? _calculatePayout(bet.choice, bet.amount, drawnNumber) : 0.0;
          return bet.copyWith(
            isResolved: true,
            isWon: won,
            payout: payout,
          );
        }
        return bet;
      }).toList();

      final nextPeriod = _generateNextPeriodId(_state.periodId);
      final resetDuration = _getDuration(_state.activeTab);

      _state = _state.copyWith(
        timeRemaining: resetDuration,
        periodId: nextPeriod,
        history: newHistory,
        myBets: updatedBets,
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
