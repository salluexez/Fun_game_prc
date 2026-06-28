import 'package:flutter/material.dart';

enum WingoTabType {
  seconds30,
  minute1,
  minute3,
  minute5,
}

class DrawResult {
  final int number;
  final List<Color> colors;

  const DrawResult({
    required this.number,
    required this.colors,
  });
}

class WingoState {
  final WingoTabType activeTab;
  final int timeRemaining;
  final String periodId;
  final List<DrawResult> history;
  final int multiplier;

  const WingoState({
    required this.activeTab,
    required this.timeRemaining,
    required this.periodId,
    required this.history,
    required this.multiplier,
  });

  WingoState copyWith({
    WingoTabType? activeTab,
    int? timeRemaining,
    String? periodId,
    List<DrawResult>? history,
    int? multiplier,
  }) {
    return WingoState(
      activeTab: activeTab ?? this.activeTab,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      periodId: periodId ?? this.periodId,
      history: history ?? this.history,
      multiplier: multiplier ?? this.multiplier,
    );
  }
}
