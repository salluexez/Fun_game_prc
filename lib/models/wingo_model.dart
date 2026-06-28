import 'package:flutter/material.dart';

enum WingoTabType {
  seconds30,
  minute1,
  minute3,
  minute5,
}

enum WingoHistoryTab {
  gameHistory,
  chart,
  myHistory,
}

class DrawResult {
  final int number;
  final List<Color> colors;

  const DrawResult({
    required this.number,
    required this.colors,
  });

  String get bigSmall => number >= 5 ? 'Big' : 'Small';
}

class WingoBet {
  final String periodId;
  final WingoTabType tabType;
  final String choice;
  final double amount;
  final DateTime timestamp;
  final bool isResolved;
  final bool isWon;
  final double payout;

  const WingoBet({
    required this.periodId,
    required this.tabType,
    required this.choice,
    required this.amount,
    required this.timestamp,
    this.isResolved = false,
    this.isWon = false,
    this.payout = 0.0,
  });

  WingoBet copyWith({
    String? periodId,
    WingoTabType? tabType,
    String? choice,
    double? amount,
    DateTime? timestamp,
    bool? isResolved,
    bool? isWon,
    double? payout,
  }) {
    return WingoBet(
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

class WingoState {
  final WingoTabType activeTab;
  final int timeRemaining;
  final String periodId;
  final List<DrawResult> history;
  final int multiplier;
  final WingoHistoryTab activeHistoryTab;
  final List<WingoBet> myBets;
  final int chartPage;
  
  // Parallel background tracking fields
  final Map<WingoTabType, List<DrawResult>> allHistories;
  final Map<WingoTabType, String> allPeriodIds;
  final Map<WingoTabType, int> allTimeRemaining;

  const WingoState({
    required this.activeTab,
    required this.timeRemaining,
    required this.periodId,
    required this.history,
    required this.multiplier,
    required this.activeHistoryTab,
    required this.myBets,
    required this.chartPage,
    required this.allHistories,
    required this.allPeriodIds,
    required this.allTimeRemaining,
  });

  WingoState copyWith({
    WingoTabType? activeTab,
    int? timeRemaining,
    String? periodId,
    List<DrawResult>? history,
    int? multiplier,
    WingoHistoryTab? activeHistoryTab,
    List<WingoBet>? myBets,
    int? chartPage,
    Map<WingoTabType, List<DrawResult>>? allHistories,
    Map<WingoTabType, String>? allPeriodIds,
    Map<WingoTabType, int>? allTimeRemaining,
  }) {
    // Defensive check: if hot reload left properties uninitialized/null in memory
    WingoHistoryTab fallbackHistoryTab = WingoHistoryTab.gameHistory;
    try {
      final dynamic currentTab = this.activeHistoryTab;
      if (currentTab != null) {
        fallbackHistoryTab = currentTab as WingoHistoryTab;
      }
    } catch (_) {}

    List<WingoBet> fallbackBets = const [];
    try {
      final dynamic currentBets = this.myBets;
      if (currentBets != null) {
        fallbackBets = List<WingoBet>.from(currentBets);
      }
    } catch (_) {}

    int fallbackChartPage = 1;
    try {
      final dynamic currentPage = this.chartPage;
      if (currentPage != null) {
        fallbackChartPage = currentPage as int;
      }
    } catch (_) {}

    Map<WingoTabType, List<DrawResult>> fallbackAllHistories = const {};
    try {
      final dynamic currentAllHistories = this.allHistories;
      if (currentAllHistories != null) {
        fallbackAllHistories = Map<WingoTabType, List<DrawResult>>.from(currentAllHistories);
      }
    } catch (_) {}

    Map<WingoTabType, String> fallbackAllPeriodIds = const {};
    try {
      final dynamic currentAllPeriodIds = this.allPeriodIds;
      if (currentAllPeriodIds != null) {
        fallbackAllPeriodIds = Map<WingoTabType, String>.from(currentAllPeriodIds);
      }
    } catch (_) {}

    Map<WingoTabType, int> fallbackAllTimeRemaining = const {};
    try {
      final dynamic currentAllTimeRemaining = this.allTimeRemaining;
      if (currentAllTimeRemaining != null) {
        fallbackAllTimeRemaining = Map<WingoTabType, int>.from(currentAllTimeRemaining);
      }
    } catch (_) {}

    return WingoState(
      activeTab: activeTab ?? this.activeTab,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      periodId: periodId ?? this.periodId,
      history: history ?? this.history,
      multiplier: multiplier ?? this.multiplier,
      activeHistoryTab: activeHistoryTab ?? fallbackHistoryTab,
      myBets: myBets ?? fallbackBets,
      chartPage: chartPage ?? fallbackChartPage,
      allHistories: allHistories ?? fallbackAllHistories,
      allPeriodIds: allPeriodIds ?? fallbackAllPeriodIds,
      allTimeRemaining: allTimeRemaining ?? fallbackAllTimeRemaining,
    );
  }
}
