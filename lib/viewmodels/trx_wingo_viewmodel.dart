import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/trx_wingo_model.dart';
import '../services/wallet_service.dart';

class TrxWingoViewModel extends ChangeNotifier {
  static final TrxWingoViewModel _instance = TrxWingoViewModel._internal();
  factory TrxWingoViewModel() => _instance;

  late TrxWingoState _state;
  Timer? _timer;
  final Random _random = Random();
  int _currentSimulatedBlock = 84143700;

  TrxWingoViewModel._internal() {
    _initializeGame(TrxWingoTabType.minute1);

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

  TrxWingoState get state => _state;

  void _initializeGame(TrxWingoTabType activeTab) {
    final now = DateTime.now();

    final Map<TrxWingoTabType, List<TrxDrawResult>> allHistories = {};
    final Map<TrxWingoTabType, String> allPeriodIds = {};
    final Map<TrxWingoTabType, int> allTimeRemaining = {};

    for (final tab in TrxWingoTabType.values) {
      allHistories[tab] = _generateInitialHistory(tab, now);
      allPeriodIds[tab] = _calculatePeriodId(tab, now);
      allTimeRemaining[tab] = _calculateRemainingTime(tab, now);
    }

    _state = TrxWingoState(
      activeTab: activeTab,
      timeRemaining: allTimeRemaining[activeTab]!,
      periodId: allPeriodIds[activeTab]!,
      history: allHistories[activeTab]!,
      multiplier: 1,
      activeHistoryTab: TrxWingoHistoryTab.gameHistory,
      myBets: const [],
      chartPage: 1,
      gameHistoryPage: 1,
      balance: WalletService().balance,
      allHistories: allHistories,
      allPeriodIds: allPeriodIds,
      allTimeRemaining: allTimeRemaining,
      lastResolution: null,
    );
  }

  void selectTab(TrxWingoTabType tab) {
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

  void selectHistoryTab(TrxWingoHistoryTab tab) {
    if (_state.activeHistoryTab == tab) return;
    _state = _state.copyWith(activeHistoryTab: tab);
    notifyListeners();
  }

  void setMultiplier(int val) {
    _state = _state.copyWith(multiplier: val);
    notifyListeners();
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

  void placeBet(String choice, int amount) {
    debugPrint('TRX Placed bet: Choice: $choice, Amount: $amount, Multiplier: ${_state.multiplier}');
    
    final finalAmount = amount.toDouble();
    
    // Deduct bet amount from shared wallet balance
    final success = WalletService().deduct(finalAmount);
    if (!success) return;

    final newBet = TrxWingoBet(
      periodId: _state.periodId,
      tabType: _state.activeTab,
      choice: choice,
      amount: finalAmount,
      timestamp: DateTime.now(),
    );

    final updatedBets = List<TrxWingoBet>.from(_state.myBets);
    updatedBets.insert(0, newBet);

    _state = _state.copyWith(
      myBets: updatedBets,
      balance: WalletService().balance,
    );
    notifyListeners();
  }

  String _getTabTypeCode(TrxWingoTabType tab) {
    switch (tab) {
      case TrxWingoTabType.seconds30:
        return '30';
      case TrxWingoTabType.minute1:
        return '01';
      case TrxWingoTabType.minute3:
        return '03';
      case TrxWingoTabType.minute5:
        return '05';
    }
  }

  String _calculatePeriodId(TrxWingoTabType tab, DateTime dt) {
    final yyyyMMdd = "${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}";
    final totalSeconds = dt.hour * 3600 + dt.minute * 60 + dt.second;

    int periodIndex = 1;
    switch (tab) {
      case TrxWingoTabType.seconds30:
        periodIndex = (totalSeconds ~/ 30) + 1;
      case TrxWingoTabType.minute1:
        periodIndex = totalSeconds ~/ 60 + 1;
      case TrxWingoTabType.minute3:
        periodIndex = totalSeconds ~/ 180 + 1;
      case TrxWingoTabType.minute5:
        periodIndex = totalSeconds ~/ 300 + 1;
    }
    return "$yyyyMMdd${_getTabTypeCode(tab)}${periodIndex.toString().padLeft(4, '0')}";
  }

  int _calculateRemainingTime(TrxWingoTabType tab, DateTime dt) {
    final totalSeconds = dt.hour * 3600 + dt.minute * 60 + dt.second;
    switch (tab) {
      case TrxWingoTabType.seconds30:
        return 30 - (totalSeconds % 30);
      case TrxWingoTabType.minute1:
        return 60 - (totalSeconds % 60);
      case TrxWingoTabType.minute3:
        return 180 - (totalSeconds % 180);
      case TrxWingoTabType.minute5:
        return 300 - (totalSeconds % 300);
    }
  }

  List<TrxDrawResult> _generateInitialHistory(TrxWingoTabType tab, DateTime now) {
    final List<TrxDrawResult> list = [];
    int blockHeight = _currentSimulatedBlock - 50;

    for (int i = 0; i < 50; i++) {
      final rollTime = now.subtract(Duration(
        seconds: i * (tab == TrxWingoTabType.seconds30
            ? 30
            : tab == TrxWingoTabType.minute1
                ? 60
                : tab == TrxWingoTabType.minute3
                    ? 180
                    : 300),
      ));
      final hhmmss = "${rollTime.hour.toString().padLeft(2, '0')}:${rollTime.minute.toString().padLeft(2, '0')}:${rollTime.second.toString().padLeft(2, '0')}";
      
      // Generate a simulated TRON block hash
      final hash = _generateSimulatedHash();
      final digit = _parseLastNumericDigit(hash);
      final last5 = hash.substring(hash.length - 5).split('');

      list.add(TrxDrawResult(
        periodId: _calculatePeriodId(tab, rollTime),
        blockHeight: blockHeight + i,
        blockTime: hhmmss,
        hashValue: "**${hash.substring(hash.length - 4)}",
        resultNumber: digit,
        colors: _getColorsForNumber(digit),
        bigSmall: digit >= 5 ? 'B' : 'S',
        last5HashChars: last5,
      ));
    }
    return list.reversed.toList();
  }

  String _generateSimulatedHash() {
    const chars = '0123456789abcdef';
    final buffer = StringBuffer();
    // TRON hash is 64 characters (hexadecimal representation of SHA-256)
    for (int i = 0; i < 64; i++) {
      buffer.write(chars[_random.nextInt(16)]);
    }
    return buffer.toString();
  }

  int _parseLastNumericDigit(String hash) {
    // Traverse right-to-left to find first numeric character
    for (int i = hash.length - 1; i >= 0; i--) {
      final codeUnit = hash.codeUnitAt(i);
      if (codeUnit >= 48 && codeUnit <= 57) { // ASCII codes for '0' to '9'
        return codeUnit - 48;
      }
    }
    return 0; // Fallback
  }

  List<Color> _getColorsForNumber(int num) {
    if (num == 0) return [const Color(0xFFF15147), const Color(0xFF9E5CFF)]; // Red + Violet
    if (num == 5) return [const Color(0xFF2CA87E), const Color(0xFF9E5CFF)]; // Green + Violet
    if (num % 2 == 0) return [const Color(0xFFF15147)]; // Red
    return [const Color(0xFF2CA87E)]; // Green
  }

  void _tick() {
    final now = DateTime.now();
    final Map<TrxWingoTabType, int> allTimeRemaining = Map.from(_state.allTimeRemaining);
    final Map<TrxWingoTabType, String> allPeriodIds = Map.from(_state.allPeriodIds);
    final Map<TrxWingoTabType, List<TrxDrawResult>> allHistories = Map.from(_state.allHistories);

    final activeTab = _state.activeTab;
    TrxWingoResolutionResult? activeTabResolution;
    double totalPayoutToAdd = 0.0;
    final updatedBets = List<TrxWingoBet>.from(_state.myBets);

    for (final tab in TrxWingoTabType.values) {
      final oldPeriodId = allPeriodIds[tab];
      final newRemaining = _calculateRemainingTime(tab, now);
      final newPeriodId = _calculatePeriodId(tab, now);

      if (newPeriodId != oldPeriodId) {
        // Roll draw!
        _currentSimulatedBlock++;
        final hhmmss = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
        final hash = _generateSimulatedHash();
        final digit = _parseLastNumericDigit(hash);
        final last5 = hash.substring(hash.length - 5).split('');

        final newDraw = TrxDrawResult(
          periodId: oldPeriodId ?? '',
          blockHeight: _currentSimulatedBlock,
          blockTime: hhmmss,
          hashValue: "**${hash.substring(hash.length - 4)}",
          resultNumber: digit,
          colors: _getColorsForNumber(digit),
          bigSmall: digit >= 5 ? 'B' : 'S',
          last5HashChars: last5,
        );

        final tabHistory = List<TrxDrawResult>.from(allHistories[tab] ?? []);
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
            final won = _evaluateBetWin(bet.choice, digit);
            final payout = won ? _calculatePayout(bet.choice, bet.amount, digit) : 0.0;

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
          activeTabResolution = TrxWingoResolutionResult(
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

  bool _evaluateBetWin(String choice, int num) {
    if (choice == 'Green' && (num == 1 || num == 3 || num == 5 || num == 7 || num == 9)) return true;
    if (choice == 'Red' && (num == 0 || num == 2 || num == 4 || num == 6 || num == 8)) return true;
    if (choice == 'Violet' && (num == 0 || num == 5)) return true;
    if (choice == 'Big' && num >= 5) return true;
    if (choice == 'Small' && num < 5) return true;
    return choice == num.toString();
  }

  double _calculatePayout(String choice, double betAmt, int num) {
    final contractAmt = betAmt * 0.98; // 2% service fee deducted
    if (choice == 'Green') {
      return num == 5 ? contractAmt * 1.5 : contractAmt * 2.0;
    }
    if (choice == 'Red') {
      return num == 0 ? contractAmt * 1.5 : contractAmt * 2.0;
    }
    if (choice == 'Violet') {
      return contractAmt * 4.5;
    }
    if (choice == 'Big' || choice == 'Small') {
      return contractAmt * 2.0;
    }
    // Number bet matches exactly
    return contractAmt * 9.0;
  }

  // Statistics calculators (Missing, Avg missing, Frequency, Max Consecutive)
  List<int> calculateMissing() {
    final result = List<int>.filled(10, 0);
    final historyList = _state.history;
    for (int num = 0; num < 10; num++) {
      int missingCount = 0;
      for (final draw in historyList) {
        if (draw.resultNumber == num) {
          break;
        }
        missingCount++;
      }
      result[num] = missingCount;
    }
    return result;
  }

  List<int> calculateAvgMissing() {
    final result = List<int>.filled(10, 0);
    final historyList = _state.history;
    for (int num = 0; num < 10; num++) {
      int occurrences = 0;
      int currentSum = 0;
      int missingCount = 0;
      for (final draw in historyList) {
        if (draw.resultNumber == num) {
          occurrences++;
          currentSum += missingCount;
          missingCount = 0;
        } else {
          missingCount++;
        }
      }
      currentSum += missingCount; // trailing missing sequence
      result[num] = occurrences == 0 ? historyList.length : currentSum ~/ (occurrences + 1);
    }
    return result;
  }

  List<int> calculateFrequency() {
    final result = List<int>.filled(10, 0);
    for (final draw in _state.history) {
      if (draw.resultNumber >= 0 && draw.resultNumber <= 9) {
        result[draw.resultNumber]++;
      }
    }
    return result;
  }

  List<int> calculateMaxConsecutive() {
    final result = List<int>.filled(10, 0);
    final historyList = _state.history;
    for (int num = 0; num < 10; num++) {
      int maxConsecutive = 0;
      int currentConsecutive = 0;
      for (final draw in historyList) {
        if (draw.resultNumber == num) {
          currentConsecutive++;
          if (currentConsecutive > maxConsecutive) {
            maxConsecutive = currentConsecutive;
          }
        } else {
          currentConsecutive = 0;
        }
      }
      result[num] = maxConsecutive;
    }
    return result;
  }

  // Pagination support
  void setChartPage(int page) {
    if (page < 1 || page > 50) return;
    _state = _state.copyWith(chartPage: page);
    notifyListeners();
  }

  void setGameHistoryPage(int page) {
    if (page < 1 || page > 50) return;
    _state = _state.copyWith(gameHistoryPage: page);
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
