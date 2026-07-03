import 'package:flutter/material.dart';

enum FiveDTabType {
  minute1,
  minute3,
  minute5,
  minute10,
}

enum FiveDHistoryTab {
  gameHistory,
  chart,
  myHistory,
}

enum FiveDBetTab {
  A,
  B,
  C,
  D,
  E,
  SUM,
}

class FiveDDrawResult {
  final List<int> digits; // Exactly 5 digits (0-9)

  const FiveDDrawResult({
    required this.digits,
  }) : assert(digits.length == 5);

  int get sum => digits.fold(0, (sum, item) => sum + item);

  String get sumBigSmall => sum >= 23 ? 'Big' : 'Small';
  String get sumOddEven => sum % 2 != 0 ? 'Odd' : 'Even';

  String getBigSmall(int index) => digits[index] >= 5 ? 'Big' : 'Small';
  String getOddEven(int index) => digits[index] % 2 != 0 ? 'Odd' : 'Even';
}

class FiveDBet {
  final String periodId;
  final FiveDTabType tabType;
  final FiveDBetTab positionTab;
  final String choice; // "0"..."9", "Big", "Small", "Odd", "Even" (A-E) or "Big", "Small", "Odd", "Even" (SUM)
  final double amount;
  final DateTime timestamp;
  final bool isResolved;
  final bool isWon;
  final double payout;

  const FiveDBet({
    required this.periodId,
    required this.tabType,
    required this.positionTab,
    required this.choice,
    required this.amount,
    required this.timestamp,
    this.isResolved = false,
    this.isWon = false,
    this.payout = 0.0,
  });

  FiveDBet copyWith({
    bool? isResolved,
    bool? isWon,
    double? payout,
  }) {
    return FiveDBet(
      periodId: periodId,
      tabType: tabType,
      positionTab: positionTab,
      choice: choice,
      amount: amount,
      timestamp: timestamp,
      isResolved: isResolved ?? this.isResolved,
      isWon: isWon ?? this.isWon,
      payout: payout ?? this.payout,
    );
  }
}

class FiveDResolutionResult {
  final String periodId;
  final bool isWon;
  final double totalPayout;
  final double totalBetAmount;

  const FiveDResolutionResult({
    required this.periodId,
    required this.isWon,
    required this.totalPayout,
    required this.totalBetAmount,
  });
}

class FiveDState {
  final FiveDTabType activeTab;
  final int timeRemaining;
  final String periodId;
  final List<FiveDDrawResult> history;
  final int multiplier;
  final FiveDHistoryTab activeHistoryTab;
  final FiveDBetTab activeBetTab;
  final List<FiveDBet> myBets;
  final int chartPage;
  final int gameHistoryPage;
  final double balance;

  // Parallel background tracking fields
  final Map<FiveDTabType, List<FiveDDrawResult>> allHistories;
  final Map<FiveDTabType, String> allPeriodIds;
  final Map<FiveDTabType, int> allTimeRemaining;

  // Resolution popup feedback
  final FiveDResolutionResult? lastResolution;

  const FiveDState({
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
    required this.balance,
    required this.allHistories,
    required this.allPeriodIds,
    required this.allTimeRemaining,
    this.lastResolution,
  });

  FiveDState copyWith({
    FiveDTabType? activeTab,
    int? timeRemaining,
    String? periodId,
    List<FiveDDrawResult>? history,
    int? multiplier,
    FiveDHistoryTab? activeHistoryTab,
    FiveDBetTab? activeBetTab,
    List<FiveDBet>? myBets,
    int? chartPage,
    int? gameHistoryPage,
    double? balance,
    Map<FiveDTabType, List<FiveDDrawResult>>? allHistories,
    Map<FiveDTabType, String>? allPeriodIds,
    Map<FiveDTabType, int>? allTimeRemaining,
    FiveDResolutionResult? lastResolution,
    bool clearLastResolution = false,
  }) {
    return FiveDState(
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
      balance: balance ?? this.balance,
      allHistories: allHistories ?? this.allHistories,
      allPeriodIds: allPeriodIds ?? this.allPeriodIds,
      allTimeRemaining: allTimeRemaining ?? this.allTimeRemaining,
      lastResolution: clearLastResolution ? null : (lastResolution ?? this.lastResolution),
    );
  }
}
