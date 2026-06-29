import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/k3_model.dart';

class K3ViewModel extends ChangeNotifier {
  static final K3ViewModel _instance = K3ViewModel._internal();
  factory K3ViewModel() => _instance;

  late K3State _state;
  Timer? _timer;
  final Random _random = Random();

  K3ViewModel._internal() {
    _initializeGame(K3TabType.minute1);

    // Start running the countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  K3State get state => _state;

  void _initializeGame(K3TabType activeTab) {
    final now = DateTime.now();

    final Map<K3TabType, List<K3DrawResult>> allHistories = {};
    final Map<K3TabType, String> allPeriodIds = {};
    final Map<K3TabType, int> allTimeRemaining = {};

    for (final tab in K3TabType.values) {
      allHistories[tab] = _generateInitialHistory();
      allPeriodIds[tab] = _calculatePeriodId(tab, now);
      allTimeRemaining[tab] = _calculateRemainingTime(tab, now);
    }

    _state = K3State(
      activeTab: activeTab,
      timeRemaining: allTimeRemaining[activeTab]!,
      periodId: allPeriodIds[activeTab]!,
      history: allHistories[activeTab]!,
      multiplier: 1,
      activeHistoryTab: K3HistoryTab.gameHistory,
      activeBetTab: K3BetTab.total,
      myBets: const [],
      chartPage: 1,
      gameHistoryPage: 1,
      allHistories: allHistories,
      allPeriodIds: allPeriodIds,
      allTimeRemaining: allTimeRemaining,
      lastResolution: null,
    );
  }

  void selectTab(K3TabType tab) {
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

  void selectHistoryTab(K3HistoryTab tab) {
    if (_state.activeHistoryTab == tab) return;
    _state = _state.copyWith(activeHistoryTab: tab);
    notifyListeners();
  }

  void selectBetTab(K3BetTab tab) {
    if (_state.activeBetTab == tab) return;
    _state = _state.copyWith(activeBetTab: tab);
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

  void placeBet(String choice, int amount) {
    debugPrint('K3 Placed bet: Choice: $choice, Amount: $amount, Multiplier: ${_state.multiplier}');
    
    final finalAmount = amount.toDouble();
    final newBet = K3Bet(
      periodId: _state.periodId,
      tabType: _state.activeTab,
      choice: choice,
      amount: finalAmount,
      timestamp: DateTime.now(),
    );

    final updatedBets = List<K3Bet>.from(_state.myBets);
    updatedBets.insert(0, newBet);

    _state = _state.copyWith(myBets: updatedBets);
    notifyListeners();
  }

  String _getTabTypeCode(K3TabType tab) {
    switch (tab) {
      case K3TabType.minute1:
        return '01';
      case K3TabType.minute3:
        return '03';
      case K3TabType.minute5:
        return '05';
      case K3TabType.minute10:
        return '10';
    }
  }

  List<K3DrawResult> _generateInitialHistory() {
    return List.generate(500, (_) => _generateRandomDrawResult());
  }

  K3DrawResult _generateRandomDrawResult() {
    return K3DrawResult(
      dice: [
        1 + _random.nextInt(6),
        1 + _random.nextInt(6),
        1 + _random.nextInt(6),
      ],
    );
  }

  bool _evaluateBetWin(String choice, K3DrawResult result) {
    final sum = result.sum;
    if (choice == 'Big') return sum >= 11;
    if (choice == 'Small') return sum <= 10;
    if (choice == 'Even') return sum % 2 == 0;
    if (choice == 'Odd') return sum % 2 != 0;
    
    if (choice.startsWith('sum_')) {
      final target = int.tryParse(choice.substring(4));
      return target == sum;
    }
    
    if (choice.startsWith('two_matching_')) {
      final valStr = choice.substring(13); // "11", "22", etc.
      final singleDigit = int.tryParse(valStr[0]);
      if (singleDigit != null) {
        return result.dice.where((d) => d == singleDigit).length >= 2;
      }
    }

    if (choice.startsWith('pair_unique_')) {
      final parts = choice.substring(12).split('_'); // ["22", "3"]
      final doubleDigit = int.tryParse(parts[0][0]);
      final singleDigit = int.tryParse(parts[1]);
      if (doubleDigit != null && singleDigit != null) {
        final countDouble = result.dice.where((d) => d == doubleDigit).length;
        final countSingle = result.dice.where((d) => d == singleDigit).length;
        if (doubleDigit == singleDigit) {
          return result.dice.where((d) => d == doubleDigit).length == 3;
        }
        return countDouble >= 2 && countSingle >= 1;
      }
    }

    if (choice.startsWith('three_matching_')) {
      final valStr = choice.substring(15); // "111", "222", etc.
      final singleDigit = int.tryParse(valStr[0]);
      if (singleDigit != null) {
        return result.dice.where((d) => d == singleDigit).length == 3;
      }
    }

    if (choice == 'any_three_same') {
      return result.dice[0] == result.dice[1] && result.dice[1] == result.dice[2];
    }

    if (choice == 'three_continuous') {
      final sorted = List<int>.from(result.dice)..sort();
      return (sorted[1] == sorted[0] + 1) && (sorted[2] == sorted[1] + 1);
    }

    if (choice.startsWith('diff_3_')) {
      final parts = choice.substring(7).split('_').map(int.parse).toList();
      return result.dice.contains(parts[0]) &&
             result.dice.contains(parts[1]) &&
             result.dice.contains(parts[2]);
    }

    if (choice.startsWith('diff_2_')) {
      final parts = choice.substring(7).split('_').map(int.parse).toList();
      return result.dice.contains(parts[0]) &&
             result.dice.contains(parts[1]);
    }
    
    return false;
  }

  double _calculatePayout(String choice, double amount, K3DrawResult result) {
    if (choice == 'Big' || choice == 'Small' || choice == 'Even' || choice == 'Odd') {
      return amount * 2.0;
    }
    if (choice.startsWith('sum_')) {
      return _calculateSumPayout(result.sum, amount);
    }
    if (choice.startsWith('two_matching_')) {
      return amount * 13.83;
    }
    if (choice.startsWith('pair_unique_')) {
      return amount * 69.12;
    }
    if (choice.startsWith('three_matching_')) {
      return amount * 207.36;
    }
    if (choice == 'any_three_same') {
      return amount * 34.56;
    }
    if (choice == 'three_continuous') {
      return amount * 8.64;
    }
    if (choice.startsWith('diff_3_')) {
      return amount * 34.56;
    }
    if (choice.startsWith('diff_2_')) {
      return amount * 6.91;
    }
    return 0.0;
  }

  double _calculateSumPayout(int sum, double amount) {
    final Map<int, double> multipliers = {
      3: 207.36, 4: 69.12, 5: 34.56, 6: 20.74, 7: 13.83, 8: 9.88,
      9: 8.3, 10: 7.68, 11: 7.68, 12: 8.3, 13: 9.88, 14: 13.83,
      15: 20.74, 16: 34.56, 17: 69.12, 18: 207.36
    };
    return amount * (multipliers[sum] ?? 2.0);
  }

  // --- Clock calculations based on System Clock (DateTime.now()) ---

  int _calculateRemainingTime(K3TabType tab, DateTime now) {
    switch (tab) {
      case K3TabType.minute1:
        return 60 - now.second;
      case K3TabType.minute3:
        final elapsed = (now.minute % 3) * 60 + now.second;
        return 180 - elapsed;
      case K3TabType.minute5:
        final elapsed = (now.minute % 5) * 60 + now.second;
        return 300 - elapsed;
      case K3TabType.minute10:
        final elapsed = (now.minute % 10) * 60 + now.second;
        return 600 - elapsed;
    }
  }

  String _calculatePeriodId(K3TabType tab, DateTime now) {
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final typeCode = _getTabTypeCode(tab);
    
    int intervalLengthSeconds;
    switch (tab) {
      case K3TabType.minute1:
        intervalLengthSeconds = 60;
        break;
      case K3TabType.minute3:
        intervalLengthSeconds = 180;
        break;
      case K3TabType.minute5:
        intervalLengthSeconds = 300;
        break;
      case K3TabType.minute10:
        intervalLengthSeconds = 600;
        break;
    }
    
    final totalSecondsInDay = now.hour * 3600 + now.minute * 60 + now.second;
    final periodIndex = totalSecondsInDay ~/ intervalLengthSeconds;
    final periodIndexStr = periodIndex.toString().padLeft(4, '0');
    return '$dateStr$typeCode$periodIndexStr';
  }

  // --- Statistics Calculations (last 100 Periods) ---

  List<int> getMissingStatistics() {
    final result = List<int>.filled(16, 0); // 3 to 18 (indices 0 to 15 mapped to 3-18)
    for (int idx = 0; idx < 16; idx++) {
      int sumVal = idx + 3;
      int index = _state.history.indexWhere((element) => element.sum == sumVal);
      result[idx] = index == -1 ? _state.history.length : index;
    }
    return result;
  }

  List<int> getFrequencyStatistics() {
    final result = List<int>.filled(16, 0);
    for (final draw in _state.history) {
      int sumVal = draw.sum;
      if (sumVal >= 3 && sumVal <= 18) {
        result[sumVal - 3]++;
      }
    }
    return result;
  }

  void _tick() {
    final now = DateTime.now();

    final allHistories = Map<K3TabType, List<K3DrawResult>>.from(_state.allHistories);
    final allPeriodIds = Map<K3TabType, String>.from(_state.allPeriodIds);
    final allTimeRemaining = Map<K3TabType, int>.from(_state.allTimeRemaining);
    final updatedBets = List<K3Bet>.from(_state.myBets);
    K3ResolutionResult? activeTabResolution;

    final activeTab = _state.activeTab;

    for (final tab in K3TabType.values) {
      final newPeriodId = _calculatePeriodId(tab, now);
      final newRemaining = _calculateRemainingTime(tab, now);
      final oldPeriodId = allPeriodIds[tab];

      if (newPeriodId != oldPeriodId) {
        final newDraw = _generateRandomDrawResult();
        final tabHistory = List<K3DrawResult>.from(allHistories[tab] ?? []);
        tabHistory.insert(0, newDraw);
        if (tabHistory.length > 500) {
          tabHistory.removeLast();
        }
        allHistories[tab] = tabHistory;

        double tabTotalBet = 0.0;
        double tabTotalPayout = 0.0;
        bool hasBets = false;

        for (int i = 0; i < updatedBets.length; i++) {
          final bet = updatedBets[i];
          if (bet.tabType == tab && bet.periodId == oldPeriodId && !bet.isResolved) {
            hasBets = true;
            final won = _evaluateBetWin(bet.choice, newDraw);
            final payout = won ? _calculatePayout(bet.choice, bet.amount, newDraw) : 0.0;
            
            tabTotalBet += bet.amount;
            tabTotalPayout += payout;

            updatedBets[i] = bet.copyWith(
              isResolved: true,
              isWon: won,
              payout: payout,
            );
          }
        }

        if (hasBets && tab == activeTab) {
          activeTabResolution = K3ResolutionResult(
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
