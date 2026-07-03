import 'package:flutter/material.dart';

enum TrxWingoTabType {
  seconds30,
  minute1,
  minute3,
  minute5,
}

enum TrxWingoHistoryTab {
  gameHistory,
  chart,
  myHistory,
}

class TrxDrawResult {
  final String periodId;
  final int blockHeight;
  final String blockTime;
  final String hashValue;
  final int resultNumber;
  final List<Color> colors;
  final String bigSmall;
  final List<String> last5HashChars;

  const TrxDrawResult({
    required this.periodId,
    required this.blockHeight,
    required this.blockTime,
    required this.hashValue,
    required this.resultNumber,
    required this.colors,
    required this.bigSmall,
    required this.last5HashChars,
  });
}

class TrxWingoBet {
  final String periodId;
  final TrxWingoTabType tabType;
  final String choice;
  final double amount;
  final DateTime timestamp;
  final bool isResolved;
  final bool isWon;
  final double payout;

  const TrxWingoBet({
    required this.periodId,
    required this.tabType,
    required this.choice,
    required this.amount,
    required this.timestamp,
    this.isResolved = false,
    this.isWon = false,
    this.payout = 0.0,
  });

  TrxWingoBet copyWith({
    bool? isResolved,
    bool? isWon,
    double? payout,
  }) {
    return TrxWingoBet(
      periodId: periodId,
      tabType: tabType,
      choice: choice,
      amount: amount,
      timestamp: timestamp,
      isResolved: isResolved ?? this.isResolved,
      isWon: isWon ?? this.isWon,
      payout: payout ?? this.payout,
    );
  }
}

class TrxWingoResolutionResult {
  final String periodId;
  final bool isWon;
  final double totalPayout;
  final double totalBetAmount;

  const TrxWingoResolutionResult({
    required this.periodId,
    required this.isWon,
    required this.totalPayout,
    required this.totalBetAmount,
  });
}

class TrxWingoState {
  final TrxWingoTabType activeTab;
  final int timeRemaining;
  final String periodId;
  final List<TrxDrawResult> history;
  final int multiplier;
  final TrxWingoHistoryTab activeHistoryTab;
  final List<TrxWingoBet> myBets;
  final int chartPage;
  final int gameHistoryPage;
  final double balance;
  final Map<TrxWingoTabType, List<TrxDrawResult>> allHistories;
  final Map<TrxWingoTabType, String> allPeriodIds;
  final Map<TrxWingoTabType, int> allTimeRemaining;
  final TrxWingoResolutionResult? lastResolution;

  const TrxWingoState({
    required this.activeTab,
    required this.timeRemaining,
    required this.periodId,
    required this.history,
    required this.multiplier,
    required this.activeHistoryTab,
    required this.myBets,
    required this.chartPage,
    required this.gameHistoryPage,
    required this.balance,
    required this.allHistories,
    required this.allPeriodIds,
    required this.allTimeRemaining,
    this.lastResolution,
  });

  TrxWingoState copyWith({
    TrxWingoTabType? activeTab,
    int? timeRemaining,
    String? periodId,
    List<TrxDrawResult>? history,
    int? multiplier,
    TrxWingoHistoryTab? activeHistoryTab,
    List<TrxWingoBet>? myBets,
    int? chartPage,
    int? gameHistoryPage,
    double? balance,
    Map<TrxWingoTabType, List<TrxDrawResult>>? allHistories,
    Map<TrxWingoTabType, String>? allPeriodIds,
    Map<TrxWingoTabType, int>? allTimeRemaining,
    TrxWingoResolutionResult? lastResolution,
    bool clearLastResolution = false,
  }) {
    return TrxWingoState(
      activeTab: activeTab ?? this.activeTab,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      periodId: periodId ?? this.periodId,
      history: history ?? this.history,
      multiplier: multiplier ?? this.multiplier,
      activeHistoryTab: activeHistoryTab ?? this.activeHistoryTab,
      myBets: myBets ?? this.myBets,
      chartPage: chartPage ?? this.chartPage,
      gameHistoryPage: gameHistoryPage ?? this.gameHistoryPage,
      balance: balance ?? this.balance,
      allHistories: allHistories ?? this.allHistories,
      allPeriodIds: allPeriodIds ?? this.allPeriodIds,
      allTimeRemaining: allTimeRemaining ?? this.allTimeRemaining,
      lastResolution: clearLastResolution ? null : (lastResolution ?? this.lastResolution),
    );
  }
}
