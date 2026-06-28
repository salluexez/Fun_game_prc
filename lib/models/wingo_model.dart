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

class WingoState {
  final WingoTabType activeTab;
  final int timeRemaining;
  final String periodId;
  final List<DrawResult> history;
  final int multiplier;
  final WingoHistoryTab activeHistoryTab;

  const WingoState({
    required this.activeTab,
    required this.timeRemaining,
    required this.periodId,
    required this.history,
    required this.multiplier,
    required this.activeHistoryTab,
  });

  WingoState copyWith({
    WingoTabType? activeTab,
    int? timeRemaining,
    String? periodId,
    List<DrawResult>? history,
    int? multiplier,
    WingoHistoryTab? activeHistoryTab,
  }) {
    // Defensive check: if hot reload left this.activeHistoryTab uninitialized/null in memory
    WingoHistoryTab fallbackHistoryTab = WingoHistoryTab.gameHistory;
    try {
      final dynamic currentTab = this.activeHistoryTab;
      if (currentTab != null) {
        fallbackHistoryTab = currentTab as WingoHistoryTab;
      }
    } catch (_) {}

    return WingoState(
      activeTab: activeTab ?? this.activeTab,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      periodId: periodId ?? this.periodId,
      history: history ?? this.history,
      multiplier: multiplier ?? this.multiplier,
      activeHistoryTab: activeHistoryTab ?? fallbackHistoryTab,
    );
  }
}
