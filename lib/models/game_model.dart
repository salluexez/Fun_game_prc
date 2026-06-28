import 'package:flutter/material.dart';

class GameCategory {
  final String title;
  final String imagePath;
  final bool isLarge;
  final List<Color> gradientColors;
  final Alignment textAlignment;

  const GameCategory({
    required this.title,
    required this.imagePath,
    this.isLarge = false,
    required this.gradientColors,
    this.textAlignment = Alignment.bottomRight,
  });
}

class RecommendedGame {
  final String title;
  final String imagePath;
  final List<Color> gradientColors;

  const RecommendedGame({
    required this.title,
    required this.imagePath,
    required this.gradientColors,
  });
}

class HomeState {
  final List<String> bannerImages;
  final String announcement;
  final List<GameCategory> categories;
  final String logoImagePath;
  final List<RecommendedGame> recommendations;

  const HomeState({
    required this.bannerImages,
    required this.announcement,
    required this.categories,
    required this.logoImagePath,
    required this.recommendations,
  });
}
