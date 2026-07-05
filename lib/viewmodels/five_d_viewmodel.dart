import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/five_d_model.dart';
import '../services/wallet_service.dart';
import '../services/api_service.dart';

class FiveDViewModel extends ChangeNotifier {
  static final FiveDViewModel _instance = FiveDViewModel._internal();
  factory FiveDViewModel() => _instance;

  late FiveDState _state;
  Timer? _timer;
  final Random _random = Random();

  FiveDViewModel._internal() {
    _initializeGame(FiveDTabType.minute1);

    // Listen to shared wallet balance updates
    WalletService().addListener(() {
      _state = _state.copyWith(balance: WalletService().balance);
      notifyListeners();
    });

    // Start running the countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  FiveDState get state => _state;

  void _initializeGame(FiveDTabType activeTab) {
    final now = DateTime.now();

    final Map<FiveDTabType, List<FiveDDrawResult>> allHistories = {};
    final Map<FiveDTabType, String> allPeriodIds = {};
    final Map<FiveDTabType, int> allTimeRemaining = {};

    for (final tab in FiveDTabType.values) {
      allHistories[tab] = _generateInitialHistory();
      allPeriodIds[tab] = _calculatePeriodId(tab, now);
      allTimeRemaining[tab] = _calculateRemainingTime(tab, now);
    }

    // Pre-populate mock bets matching initial drawing history
    final List<FiveDBet> mockBets = [];
    final basePeriodId = allPeriodIds[activeTab]!;
    try {
      final base = basePeriodId.substring(0, basePeriodId.length - 4);
      final count = int.parse(basePeriodId.substring(basePeriodId.length - 4));
      final tabHistory = allHistories[activeTab]!;
      
      final p1Str = '$base${(count - 1).toString().padLeft(4, '0')}';
      final draw1 = tabHistory[0];
      final won1 = draw1.digits[0] == 6; // Position A matches 6
      mockBets.add(FiveDBet(
        periodId: p1Str,
        tabType: activeTab,
        positionTab: FiveDBetTab.A,
        choice: '6',
        amount: 10.0,
        timestamp: now.subtract(const Duration(minutes: 1)),
        isResolved: true,
        isWon: won1,
        payout: won1 ? 10.0 * 9.0 : 0.0,
      ));

      final p2Str = '$base${(count - 2).toString().padLeft(4, '0')}';
      final draw2 = tabHistory[1];
      final won2 = draw2.sumBigSmall == 'Big'; // SUM matches Big
      mockBets.add(FiveDBet(
        periodId: p2Str,
        tabType: activeTab,
        positionTab: FiveDBetTab.SUM,
        choice: 'Big',
        amount: 50.0,
        timestamp: now.subtract(const Duration(minutes: 2)),
        isResolved: true,
        isWon: won2,
        payout: won2 ? 50.0 * 2.0 : 0.0,
      ));
    } catch (_) {}

    _state = FiveDState(
      activeTab: activeTab,
      timeRemaining: allTimeRemaining[activeTab]!,
      periodId: allPeriodIds[activeTab]!,
      history: allHistories[activeTab]!,
      multiplier: 1,
      activeHistoryTab: FiveDHistoryTab.gameHistory,
      activeBetTab: FiveDBetTab.A,
      myBets: mockBets,
      chartPage: 1,
      gameHistoryPage: 1,
      balance: WalletService().balance,
      allHistories: allHistories,
      allPeriodIds: allPeriodIds,
      allTimeRemaining: allTimeRemaining,
      lastResolution: null,
    );
  }

  void selectTab(FiveDTabType tab) {
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

  void selectHistoryTab(FiveDHistoryTab tab) {
    if (_state.activeHistoryTab == tab) return;
    _state = _state.copyWith(activeHistoryTab: tab);
    notifyListeners();
  }

  void selectBetTab(FiveDBetTab tab) {
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

  void deposit(double amount) {
    WalletService().deposit(amount);
  }

  bool withdraw(double amount) {
    return WalletService().withdraw(amount);
  }

  void placeBet(FiveDBetTab positionTab, String choice, int amount) {
    debugPrint('5D Placed bet: Choice: $choice, Amount: $amount, Multiplier: ${_state.multiplier}');
    
    final finalAmount = amount.toDouble();
    
    // Deduct bet amount from shared wallet balance
    final success = WalletService().deduct(finalAmount);
    if (!success) return;

    if (ApiService().isLoggedIn) {
      final posCode = positionTab.toString().split('.').last.toUpperCase();
      final dbChoice = "${posCode}_$choice";
      ApiService().getActivePeriod('5d').then((activePeriod) {
        if (activePeriod != null) {
          final dbPeriodId = activePeriod['id'];
          ApiService().placeBet(ApiService().currentUserId!, dbPeriodId, dbChoice, finalAmount).then((_) {
            WalletService().syncBalance();
          });
        }
      });
    }

    final newBet = FiveDBet(
      periodId: _state.periodId,
      tabType: _state.activeTab,
      positionTab: positionTab,
      choice: choice,
      amount: finalAmount,
      timestamp: DateTime.now(),
    );

    final updatedBets = List<FiveDBet>.from(_state.myBets);
    updatedBets.insert(0, newBet);

    _state = _state.copyWith(
      myBets: updatedBets,
      balance: WalletService().balance,
    );
    notifyListeners();
  }

  String _getTabTypeCode(FiveDTabType tab) {
    switch (tab) {
      case FiveDTabType.minute1:
        return '01';
      case FiveDTabType.minute3:
        return '03';
      case FiveDTabType.minute5:
        return '05';
      case FiveDTabType.minute10:
        return '10';
    }
  }

  List<FiveDDrawResult> _generateInitialHistory() {
    return List.generate(500, (_) => _generateRandomDrawResult());
  }

  FiveDDrawResult _generateRandomDrawResult() {
    return FiveDDrawResult(
      digits: List.generate(5, (_) => _random.nextInt(10)),
    );
  }

  bool _evaluateBetWin(FiveDBet bet, FiveDDrawResult draw) {
    if (bet.positionTab == FiveDBetTab.SUM) {
      final choice = bet.choice;
      if (choice == 'Big') return draw.sumBigSmall == 'Big';
      if (choice == 'Small') return draw.sumBigSmall == 'Small';
      if (choice == 'Odd') return draw.sumOddEven == 'Odd';
      if (choice == 'Even') return draw.sumOddEven == 'Even';
      return false;
    } else {
      // Index of digit corresponds to enum value index
      final index = bet.positionTab.index; 
      final digit = draw.digits[index];
      final choice = bet.choice;

      if (choice == 'Big') return draw.getBigSmall(index) == 'Big';
      if (choice == 'Small') return draw.getBigSmall(index) == 'Small';
      if (choice == 'Odd') return draw.getOddEven(index) == 'Odd';
      if (choice == 'Even') return draw.getOddEven(index) == 'Even';
      
      // Also handles "Big2", "Small2", "Odd2", "Even2" labels
      if (choice == 'Big2') return draw.getBigSmall(index) == 'Big';
      if (choice == 'Small2') return draw.getBigSmall(index) == 'Small';
      if (choice == 'Odd2') return draw.getOddEven(index) == 'Odd';
      if (choice == 'Even2') return draw.getOddEven(index) == 'Even';

      final parsed = int.tryParse(choice);
      if (parsed != null) {
        return parsed == digit;
      }
      return false;
    }
  }

  double _calculatePayout(FiveDBet bet, FiveDDrawResult draw) {
    final choice = bet.choice;
    final parsed = int.tryParse(choice);
    
    // Number bet pays 9x
    if (parsed != null) {
      return bet.amount * 9.0;
    }
    
    // Category (Big/Small/Odd/Even) pays 2x
    return bet.amount * 2.0;
  }

  int _calculateRemainingTime(FiveDTabType tab, DateTime now) {
    switch (tab) {
      case FiveDTabType.minute1:
        return 60 - now.second;
      case FiveDTabType.minute3:
        final elapsed = (now.minute % 3) * 60 + now.second;
        return 180 - elapsed;
      case FiveDTabType.minute5:
        final elapsed = (now.minute % 5) * 60 + now.second;
        return 300 - elapsed;
      case FiveDTabType.minute10:
        final elapsed = (now.minute % 10) * 60 + now.second;
        return 600 - elapsed;
    }
  }

  String _calculatePeriodId(FiveDTabType tab, DateTime now) {
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final typeCode = _getTabTypeCode(tab);
    
    int intervalLengthSeconds;
    switch (tab) {
      case FiveDTabType.minute1:
        intervalLengthSeconds = 60;
        break;
      case FiveDTabType.minute3:
        intervalLengthSeconds = 180;
        break;
      case FiveDTabType.minute5:
        intervalLengthSeconds = 300;
        break;
      case FiveDTabType.minute10:
        intervalLengthSeconds = 600;
        break;
    }
    
    final totalSecondsInDay = now.hour * 3600 + now.minute * 60 + now.second;
    final periodIndex = totalSecondsInDay ~/ intervalLengthSeconds;
    final periodIndexStr = periodIndex.toString().padLeft(4, '0');
    return '$dateStr$typeCode$periodIndexStr';
  }

  void _tick() {
    final now = DateTime.now();

    final allHistories = Map<FiveDTabType, List<FiveDDrawResult>>.from(_state.allHistories);
    final allPeriodIds = Map<FiveDTabType, String>.from(_state.allPeriodIds);
    final allTimeRemaining = Map<FiveDTabType, int>.from(_state.allTimeRemaining);
    final updatedBets = List<FiveDBet>.from(_state.myBets);
    FiveDResolutionResult? activeTabResolution;
    double totalPayoutToAdd = 0.0;

    final activeTab = _state.activeTab;

    for (final tab in FiveDTabType.values) {
      final newPeriodId = _calculatePeriodId(tab, now);
      final newRemaining = _calculateRemainingTime(tab, now);
      final oldPeriodId = allPeriodIds[tab];

      if (newPeriodId != oldPeriodId) {
        final newDraw = _generateRandomDrawResult();
        final tabHistory = List<FiveDDrawResult>.from(allHistories[tab] ?? []);
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
            final won = _evaluateBetWin(bet, newDraw);
            final payout = won ? _calculatePayout(bet, newDraw) : 0.0;
            
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
          activeTabResolution = FiveDResolutionResult(
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
      balance: WalletService().balance,
      lastResolution: activeTabResolution,
    );
    if (totalPayoutToAdd > 0) {
      WalletService().addPayout(totalPayoutToAdd);
    } else {
      notifyListeners();
    }
  }

  // Generate statistics calculations (missing, avg missing, frequency, max consecutive)
  List<int> calculateMissing(int positionIndex) {
    final result = List<int>.filled(10, 0);
    final historyList = _state.history;
    for (int num = 0; num < 10; num++) {
      int missingCount = 0;
      for (final draw in historyList) {
        if (draw.digits[positionIndex] == num) {
          break;
        }
        missingCount++;
      }
      result[num] = missingCount;
    }
    return result;
  }

  List<int> calculateAvgMissing(int positionIndex) {
    final result = List<int>.filled(10, 0);
    final historyList = _state.history;
    for (int num = 0; num < 10; num++) {
      int appearances = 0;
      int missingSum = 0;
      int currentMissing = 0;
      for (final draw in historyList) {
        if (draw.digits[positionIndex] == num) {
          appearances++;
          missingSum += currentMissing;
          currentMissing = 0;
        } else {
          currentMissing++;
        }
      }
      result[num] = appearances == 0 ? historyList.length : (missingSum ~/ appearances);
    }
    return result;
  }

  List<int> calculateFrequency(int positionIndex) {
    final result = List<int>.filled(10, 0);
    for (final draw in _state.history) {
      final val = draw.digits[positionIndex];
      if (val >= 0 && val <= 9) {
        result[val]++;
      }
    }
    return result;
  }

  List<int> calculateMaxConsecutive(int positionIndex) {
    final result = List<int>.filled(10, 0);
    for (int num = 0; num < 10; num++) {
      int maxRun = 0;
      int currentRun = 0;
      for (final draw in _state.history) {
        if (draw.digits[positionIndex] == num) {
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

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    // Singleton remains active.
  }
}
