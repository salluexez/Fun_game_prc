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
  followStrategy,
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
  final String choice;
  final double amount;
  final DateTime timestamp;
  final bool isResolved;
  final bool isWon;
  final double payout;

  const WingoBet({
    required this.periodId,
    required this.choice,
    required this.amount,
    required this.timestamp,
    this.isResolved = false,
    this.isWon = false,
    this.payout = 0.0,
  });

  WingoBet copyWith({
    String? periodId,
    String? choice,
    double? amount,
    DateTime? timestamp,
    bool? isResolved,
    bool? isWon,
    double? payout,
  }) {
    return WingoBet(
      periodId: periodId ?? this.periodId,
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

  const WingoState({
    required this.activeTab,
    required this.timeRemaining,
    required this.periodId,
    required this.history,
    required this.multiplier,
    required this.activeHistoryTab,
    required this.myBets,
  });

  WingoState copyWith({
    WingoTabType? activeTab,
    int? timeRemaining,
    String? periodId,
    List<DrawResult>? history,
    int? multiplier,
    WingoHistoryTab? activeHistoryTab,
    List<WingoBet>? myBets,
  }) {
    // Defensive check: if hot reload left activeHistoryTab or myBets uninitialized/null in memory
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

    return WingoState(
      activeTab: activeTab ?? this.activeTab,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      periodId: periodId ?? this.periodId,
      history: history ?? this.history,
      multiplier: multiplier ?? this.multiplier,
      activeHistoryTab: activeHistoryTab ?? fallbackHistoryTab,
      myBets: myBets ?? fallbackBets,
    );
  }
}
