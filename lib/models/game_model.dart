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

class HomeState {
  final List<String> bannerImages;
  final String announcement;
  final List<GameCategory> categories;
  final String logoImagePath;

  const HomeState({
    required this.bannerImages,
    required this.announcement,
    required this.categories,
    required this.logoImagePath,
  });
}
