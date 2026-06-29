import 'package:flutter/material.dart';

enum K3TabType {
  minute1,
  minute3,
  minute5,
  minute10,
}

enum K3HistoryTab {
  gameHistory,
  chart,
  myHistory,
}

enum K3BetTab {
  total,
  twoSame,
  threeSame,
  different,
}

class K3DrawResult {
  final List<int> dice;

  const K3DrawResult({
    required this.dice,
  });

  int get sum => dice.reduce((a, b) => a + b);

  String get bigSmall => sum >= 11 ? 'Big' : 'Small';

  String get oddEven => sum % 2 != 0 ? 'Odd' : 'Even';
}

class K3Bet {
  final String periodId;
  final K3TabType tabType;
  final String choice; // e.g. "sum_10", "Small", "3_same_111", etc.
  final double amount;
  final DateTime timestamp;
  final bool isResolved;
  final bool isWon;
  final double payout;

  const K3Bet({
    required this.periodId,
    required this.tabType,
    required this.choice,
    required this.amount,
    required this.timestamp,
    this.isResolved = false,
    this.isWon = false,
    this.payout = 0.0,
  });

  K3Bet copyWith({
    String? periodId,
    K3TabType? tabType,
    String? choice,
    double? amount,
    DateTime? timestamp,
    bool? isResolved,
    bool? isWon,
    double? payout,
  }) {
    return K3Bet(
      periodId: periodId ?? this.periodId,
      tabType: tabType ?? this.tabType,
      choice: choice ?? this.choice,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      isResolved: isResolved ?? this.isResolved,
      isWon: isWon ?? this.isWon,
      payout: payout ?? this.payout,
    );
  }
}

class K3ResolutionResult {
  final String periodId;
  final bool isWon;
  final double totalPayout;
  final double totalBetAmount;

  const K3ResolutionResult({
    required this.periodId,
    required this.isWon,
    required this.totalPayout,
    required this.totalBetAmount,
  });
}

class K3State {
  final K3TabType activeTab;
  final int timeRemaining;
  final String periodId;
  final List<K3DrawResult> history;
  final int multiplier;
  final K3HistoryTab activeHistoryTab;
  final K3BetTab activeBetTab;
  final List<K3Bet> myBets;
  final int chartPage;
  final int gameHistoryPage;

  // Parallel background tracking fields
  final Map<K3TabType, List<K3DrawResult>> allHistories;
  final Map<K3TabType, String> allPeriodIds;
  final Map<K3TabType, int> allTimeRemaining;

  // Resolution popup feedback
  final K3ResolutionResult? lastResolution;

  const K3State({
    required this.activeTab,
    required this.timeRemaining,
    required this.periodId,
    required this.history,
    required this.multiplier,
    required this.activeHistoryTab,
    required this.activeBetTab,
    required this.myBets,
    required this.chartPage,
    required this.gameHistoryPage,
    required this.allHistories,
    required this.allPeriodIds,
    required this.allTimeRemaining,
    this.lastResolution,
  });

  K3State copyWith({
    K3TabType? activeTab,
    int? timeRemaining,
    String? periodId,
    List<K3DrawResult>? history,
    int? multiplier,
    K3HistoryTab? activeHistoryTab,
    K3BetTab? activeBetTab,
    List<K3Bet>? myBets,
    int? chartPage,
    int? gameHistoryPage,
    Map<K3TabType, List<K3DrawResult>>? allHistories,
    Map<K3TabType, String>? allPeriodIds,
    Map<K3TabType, int>? allTimeRemaining,
    K3ResolutionResult? lastResolution,
    bool clearLastResolution = false,
  }) {
    return K3State(
      activeTab: activeTab ?? this.activeTab,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      periodId: periodId ?? this.periodId,
      history: history ?? this.history,
      multiplier: multiplier ?? this.multiplier,
      activeHistoryTab: activeHistoryTab ?? this.activeHistoryTab,
      activeBetTab: activeBetTab ?? this.activeBetTab,
      myBets: myBets ?? this.myBets,
      chartPage: chartPage ?? this.chartPage,
      gameHistoryPage: gameHistoryPage ?? this.gameHistoryPage,
      allHistories: allHistories ?? this.allHistories,
      allPeriodIds: allPeriodIds ?? this.allPeriodIds,
      allTimeRemaining: allTimeRemaining ?? this.allTimeRemaining,
      lastResolution: clearLastResolution ? null : (lastResolution ?? this.lastResolution),
    );
  }
}
