import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/wingo_model.dart';

class WingoViewModel extends ChangeNotifier {
  static final WingoViewModel _instance = WingoViewModel._internal();
  factory WingoViewModel() => _instance;

  late WingoState _state;
  Timer? _timer;
  final Random _random = Random();

  WingoViewModel._internal() {
    _initializeGame(WingoTabType.seconds30);

    // Start running the countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  WingoState get state => _state;

  void _initializeGame(WingoTabType activeTab) {
    final now = DateTime.now();

    final Map<WingoTabType, List<DrawResult>> allHistories = {};
    final Map<WingoTabType, String> allPeriodIds = {};
    final Map<WingoTabType, int> allTimeRemaining = {};

    for (final tab in WingoTabType.values) {
      allHistories[tab] = _generateInitialHistory();
      allPeriodIds[tab] = _calculatePeriodId(tab, now);
      allTimeRemaining[tab] = _calculateRemainingTime(tab, now);
    }

    _state = WingoState(
      activeTab: activeTab,
      timeRemaining: allTimeRemaining[activeTab]!,
      periodId: allPeriodIds[activeTab]!,
      history: allHistories[activeTab]!,
      multiplier: 1,
      activeHistoryTab: WingoHistoryTab.gameHistory,
      myBets: const [],
      chartPage: 1,
      gameHistoryPage: 1,
      balance: 2.03, // Match Daman screenshot exactly
      allHistories: allHistories,
      allPeriodIds: allPeriodIds,
      allTimeRemaining: allTimeRemaining,
      lastResolution: null,
    );
  }

  void selectTab(WingoTabType tab) {
    if (_state.activeTab == tab) return;
    _state = _state.copyWith(
      activeTab: tab,
      timeRemaining: _state.allTimeRemaining[tab]!,
      periodId: _state.allPeriodIds[tab]!,
      history: _state.allHistories[tab]!,
      chartPage: 1,
      gameHistoryPage: 1,
    );
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

  void setChartPage(int page) {
    if (page < 1 || page > 50) return;
    _state = _state.copyWith(chartPage: page);
    notifyListeners();
  }

  void nextPage() {
    if (_state.chartPage < 50) {
      setChartPage(_state.chartPage + 1);
    }
  }

  void prevPage() {
    if (_state.chartPage > 1) {
      setChartPage(_state.chartPage - 1);
    }
  }

  void setGameHistoryPage(int page) {
    if (page < 1 || page > 50) return;
    _state = _state.copyWith(gameHistoryPage: page);
    notifyListeners();
  }

  void nextGameHistoryPage() {
    if (_state.gameHistoryPage < 50) {
      setGameHistoryPage(_state.gameHistoryPage + 1);
    }
  }

  void prevGameHistoryPage() {
    if (_state.gameHistoryPage > 1) {
      setGameHistoryPage(_state.gameHistoryPage - 1);
    }
  }

  void clearResolution() {
    _state = _state.copyWith(clearLastResolution: true);
    notifyListeners();
  }

  void deposit(double amount) {
    _state = _state.copyWith(balance: _state.balance + amount);
    notifyListeners();
  }

  bool withdraw(double amount) {
    if (_state.balance < amount) return false;
    _state = _state.copyWith(balance: _state.balance - amount);
    notifyListeners();
    return true;
  }

  void placeBet(String choice, int amount) {
    debugPrint('Placed bet: Choice: $choice, Amount: $amount, Multiplier: ${_state.multiplier}');
    
    final finalAmount = amount.toDouble();
    final newBet = WingoBet(
      periodId: _state.periodId,
      tabType: _state.activeTab,
      choice: choice,
      amount: finalAmount,
      timestamp: DateTime.now(),
    );

    final updatedBets = List<WingoBet>.from(_state.myBets);
    updatedBets.insert(0, newBet);

    // Deduct bet amount from dummy wallet balance
    final newBalance = _state.balance - finalAmount;

    _state = _state.copyWith(
      myBets: updatedBets,
      balance: newBalance,
    );
    notifyListeners();
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

  List<DrawResult> _generateInitialHistory() {
    return List.generate(500, (_) => _generateRandomDrawResult());
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
        return amount * 1.5;
      }
      return amount * 2.0;
    }
    return amount * 9.0;
  }

  // --- Clock calculations based on System Clock (DateTime.now()) ---

  int _calculateRemainingTime(WingoTabType tab, DateTime now) {
    switch (tab) {
      case WingoTabType.seconds30:
        return 30 - (now.second % 30);
      case WingoTabType.minute1:
        return 60 - now.second;
      case WingoTabType.minute3:
        final elapsed = (now.minute % 3) * 60 + now.second;
        return 180 - elapsed;
      case WingoTabType.minute5:
        final elapsed = (now.minute % 5) * 60 + now.second;
        return 300 - elapsed;
    }
  }

  String _calculatePeriodId(WingoTabType tab, DateTime now) {
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final typeCode = _getTabTypeCode(tab);
    
    int intervalLengthSeconds;
    switch (tab) {
      case WingoTabType.seconds30:
        intervalLengthSeconds = 30;
        break;
      case WingoTabType.minute1:
        intervalLengthSeconds = 60;
        break;
      case WingoTabType.minute3:
        intervalLengthSeconds = 180;
        break;
      case WingoTabType.minute5:
        intervalLengthSeconds = 300;
        break;
    }
    
    final totalSecondsInDay = now.hour * 3600 + now.minute * 60 + now.second;
    final periodIndex = totalSecondsInDay ~/ intervalLengthSeconds;
    final periodIndexStr = periodIndex.toString().padLeft(5, '0');
    return '$dateStr$typeCode$periodIndexStr';
  }

  // --- Statistics Calculations (last 100 Periods) ---

  List<int> getMissingStatistics() {
    final result = List<int>.filled(10, 0);
    for (int num = 0; num <= 9; num++) {
      int index = _state.history.indexWhere((element) => element.number == num);
      result[num] = index == -1 ? _state.history.length : index;
    }
    return result;
  }

  List<int> getAvgMissingStatistics() {
    final result = List<int>.filled(10, 0);
    for (int num = 0; num <= 9; num++) {
      final indices = <int>[];
      for (int i = 0; i < _state.history.length; i++) {
        if (_state.history[i].number == num) {
          indices.add(i);
        }
      }
      if (indices.isEmpty) {
        result[num] = _state.history.length;
        continue;
      }
      int totalGaps = 0;
      int prevIndex = -1;
      for (final idx in indices) {
        totalGaps += (idx - prevIndex - 1);
        prevIndex = idx;
      }
      totalGaps += (_state.history.length - prevIndex - 1);
      result[num] = (totalGaps / (indices.length + 1)).round();
    }
    return result;
  }

  List<int> getFrequencyStatistics() {
    final result = List<int>.filled(10, 0);
    for (final draw in _state.history) {
      if (draw.number >= 0 && draw.number <= 9) {
        result[draw.number]++;
      }
    }
    return result;
  }

  List<int> getMaxConsecutiveStatistics() {
    final result = List<int>.filled(10, 0);
    for (int num = 0; num <= 9; num++) {
      int maxRun = 0;
      int currentRun = 0;
      for (final draw in _state.history) {
        if (draw.number == num) {
          currentRun++;
          if (currentRun > maxRun) {
            maxRun = currentRun;
          }
        } else {
          currentRun = 0;
        }
      }
      result[num] = maxRun;
    }
    return result;
  }

  void _tick() {
    final now = DateTime.now();

    final allHistories = Map<WingoTabType, List<DrawResult>>.from(_state.allHistories);
    final allPeriodIds = Map<WingoTabType, String>.from(_state.allPeriodIds);
    final allTimeRemaining = Map<WingoTabType, int>.from(_state.allTimeRemaining);
    final updatedBets = List<WingoBet>.from(_state.myBets);
    WingoResolutionResult? activeTabResolution;
    double totalPayoutToAdd = 0.0;

    final activeTab = _state.activeTab;

    for (final tab in WingoTabType.values) {
      final newPeriodId = _calculatePeriodId(tab, now);
      final newRemaining = _calculateRemainingTime(tab, now);
      final oldPeriodId = allPeriodIds[tab];

      if (newPeriodId != oldPeriodId) {
        final newDraw = _generateRandomDrawResult();
        final tabHistory = List<DrawResult>.from(allHistories[tab] ?? []);
        tabHistory.insert(0, newDraw);
        if (tabHistory.length > 500) {
          tabHistory.removeLast();
        }
        allHistories[tab] = tabHistory;

        final drawnNumber = newDraw.number;
        double tabTotalBet = 0.0;
        double tabTotalPayout = 0.0;
        bool hasBets = false;

        for (int i = 0; i < updatedBets.length; i++) {
          final bet = updatedBets[i];
          if (bet.tabType == tab && bet.periodId == oldPeriodId && !bet.isResolved) {
            hasBets = true;
            final won = _evaluateBetWin(bet.choice, drawnNumber);
            final payout = won ? _calculatePayout(bet.choice, bet.amount, drawnNumber) : 0.0;
            
            tabTotalBet += bet.amount;
            tabTotalPayout += payout;
            totalPayoutToAdd += payout;

            updatedBets[i] = bet.copyWith(
              isResolved: true,
              isWon: won,
              payout: payout,
            );
          }
        }

        if (hasBets && tab == activeTab) {
          activeTabResolution = WingoResolutionResult(
            periodId: oldPeriodId ?? '',
            isWon: tabTotalPayout > 0,
            totalPayout: tabTotalPayout,
            totalBetAmount: tabTotalBet,
          );
        }

        allPeriodIds[tab] = newPeriodId;
      }

      allTimeRemaining[tab] = newRemaining;
    }

    _state = _state.copyWith(
      timeRemaining: allTimeRemaining[activeTab],
      periodId: allPeriodIds[activeTab],
      history: allHistories[activeTab],
      allHistories: allHistories,
      allPeriodIds: allPeriodIds,
      allTimeRemaining: allTimeRemaining,
      myBets: updatedBets,
      balance: _state.balance + totalPayoutToAdd,
      lastResolution: activeTabResolution,
    );
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    // Singleton remains active; ignore framework dispose.
  }
}
