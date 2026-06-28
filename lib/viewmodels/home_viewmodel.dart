import 'package:flutter/material.dart';
import '../models/game_model.dart';

class HomeViewModel extends ChangeNotifier {
  late final HomeState _state;

  HomeViewModel() {
    _state = HomeState(
      logoImagePath: 'assets/images/logo/h5setting_20240423194834yt8f.png',
      bannerImages: const [
        'assets/images/main_screen_images/Banner_202305270515371rsv.png',
        'assets/images/main_screen_images/Banner_20230306180818gxxn.png',
      ],
      announcement: 'The website upgrade is complete. Before logging in, clear the browser cache. Add our official customer service line.',
      categories: const [
        // Two Large Cards (Popular, Lottery)
        GameCategory(
          title: 'Popular',
          imagePath: 'assets/images/main_screen_images/popular-8_UUQbeo.png',
          isLarge: true,
          gradientColors: [Color(0xFF5CA3FF), Color(0xFF1E60FF)],
        ),
        GameCategory(
          title: 'Lottery',
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114848em94.png',
          isLarge: true,
          gradientColors: [Color(0xFFC070FF), Color(0xFF8B2EFF)],
        ),
        // Six Medium Cards (Casino, Slots, Sports, Rummy, Fishing, Original)
        GameCategory(
          title: 'Casino',
          imagePath: 'assets/images/main_screen_images/gamecategory_2024041211490142rl.png',
          isLarge: false,
          gradientColors: [Color(0xFFFF8B7D), Color(0xFFFF4935)],
        ),
        GameCategory(
          title: 'Slots',
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114911i998.png',
          isLarge: false,
          gradientColors: [Color(0xFFA17DFF), Color(0xFF6732FF)],
        ),
        GameCategory(
          title: 'Sports',
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114921c1tg.png',
          isLarge: false,
          gradientColors: [Color(0xFFFFB752), Color(0xFFFF8800)],
        ),
        GameCategory(
          title: 'Rummy',
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114929rkd9.png',
          isLarge: false,
          gradientColors: [Color(0xFF68B2FF), Color(0xFF2675FF)],
        ),
        GameCategory(
          title: 'Fishing',
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114937mcis.png',
          isLarge: false,
          gradientColors: [Color(0xFFFF7E9B), Color(0xFFFA2C5E)],
        ),
        GameCategory(
          title: 'Original',
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114947sy3o.png',
          isLarge: false,
          gradientColors: [Color(0xFF5EDFFF), Color(0xFF00A2C9)],
        ),
      ],
    );
  }

  HomeState get state => _state;

  int _currentBannerIndex = 0;
  int get currentBannerIndex => _currentBannerIndex;

  void updateBannerIndex(int index) {
    _currentBannerIndex = index;
    notifyListeners();
  }

  void onCategoryPressed(GameCategory category) {
    debugPrint('Selected category: ${category.title}');
    // We can add navigation or action logic here when they choose a category
  }

  void onLoginPressed() {
    debugPrint('Login pressed');
  }

  void onRegisterPressed() {
    debugPrint('Register pressed');
  }

  void onDetailPressed() {
    debugPrint('Announcement details pressed');
  }
}
