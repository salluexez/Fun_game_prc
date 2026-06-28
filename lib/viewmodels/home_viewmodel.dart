import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_model.dart';

class HomeViewModel extends ChangeNotifier {
  late HomeState _state;
  Timer? _winningTimer;
  final Random _random = Random();

  HomeViewModel() {
    // Initial winnings seed matching the screenshot
    final initialWinnings = [
      const WinningInfo(
        username: 'Mem***LBU',
        avatarUrl: 'https://api.dicebear.com/7.x/adventurer/png?seed=LBU',
        gameImagePath: 'assets/images/main_screen_images/vendorlogo_20250819141232etgc.png',
        amount: 230.40,
      ),
      const WinningInfo(
        username: 'Mem***ZUR',
        avatarUrl: 'https://api.dicebear.com/7.x/adventurer/png?seed=ZUR',
        gameImagePath: 'assets/images/main_screen_images/vendorlogo_20250819141232etgc.png',
        amount: 4704.00,
      ),
      const WinningInfo(
        username: 'Mem***PZA',
        avatarUrl: 'https://api.dicebear.com/7.x/adventurer/png?seed=PZA',
        gameImagePath: 'assets/images/main_screen_images/vendorlogo_20250819141232etgc.png',
        amount: 1960.00,
      ),
      const WinningInfo(
        username: 'Mem***RJJ',
        avatarUrl: 'https://api.dicebear.com/7.x/adventurer/png?seed=RJJ',
        gameImagePath: 'assets/images/main_screen_images/vendorlogo_20250819141232etgc.png',
        amount: 10584.00,
      ),
      const WinningInfo(
        username: 'Mem***HMT',
        avatarUrl: 'https://api.dicebear.com/7.x/adventurer/png?seed=HMT',
        gameImagePath: 'assets/images/main_screen_images/vendorlogo_20250819141232etgc.png',
        amount: 392.00,
      ),
    ];

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
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114829pq18.png',
          isLarge: true,
          gradientColors: [Color(0xFF5CA3FF), Color(0xFF1E60FF)],
          textAlignment: Alignment.bottomRight,
        ),
        GameCategory(
          title: 'Lottery',
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114947sy3o.png',
          isLarge: true,
          gradientColors: [Color(0xFFC070FF), Color(0xFF8B2EFF)],
          textAlignment: Alignment.bottomRight,
        ),
        // Six Medium Cards (Casino, Slots, Sports, Rummy, Fishing, Original)
        GameCategory(
          title: 'Casino',
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114911i998.png',
          isLarge: false,
          gradientColors: [Color(0xFFFF8B7D), Color(0xFFFF4935)],
          textAlignment: Alignment.topRight,
        ),
        GameCategory(
          title: 'Slots',
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114929rkd9.png',
          isLarge: false,
          gradientColors: [Color(0xFFA17DFF), Color(0xFF6732FF)],
          textAlignment: Alignment.topRight,
        ),
        GameCategory(
          title: 'Sports',
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114921c1tg.png',
          isLarge: false,
          gradientColors: [Color(0xFFFFB752), Color(0xFFFF8800)],
          textAlignment: Alignment.topRight,
        ),
        GameCategory(
          title: 'Rummy',
          imagePath: 'assets/images/main_screen_images/gamecategory_2024041211490142rl.png',
          isLarge: false,
          gradientColors: [Color(0xFF68B2FF), Color(0xFF2675FF)],
          textAlignment: Alignment.bottomRight,
        ),
        GameCategory(
          title: 'Fishing',
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114848em94.png',
          isLarge: false,
          gradientColors: [Color(0xFFFF7E9B), Color(0xFFFA2C5E)],
          textAlignment: Alignment.bottomRight,
        ),
        GameCategory(
          title: 'Original',
          imagePath: 'assets/images/main_screen_images/gamecategory_20240412114937mcis.png',
          isLarge: false,
          gradientColors: [Color(0xFF5EDFFF), Color(0xFF00A2C9)],
          textAlignment: Alignment.bottomRight,
        ),
      ],
      recommendations: const [
        RecommendedGame(
          title: 'Win Go',
          imagePath: 'assets/images/main_screen_images/lotterycategory_20240123160120h4kw.png',
          gradientColors: [Color(0xFFFA6557), Color(0xFFF13D30)],
        ),
        RecommendedGame(
          title: 'K3',
          imagePath: 'assets/images/main_screen_images/lotterycategory_20240123160129bev8.png',
          gradientColors: [Color(0xFFFA6557), Color(0xFFF13D30)],
        ),
        RecommendedGame(
          title: '5D',
          imagePath: 'assets/images/main_screen_images/lotterycategory_20240123160137lok5.png',
          gradientColors: [Color(0xFFFA6557), Color(0xFFF13D30)],
        ),
        RecommendedGame(
          title: 'Trx Win Go',
          imagePath: 'assets/images/main_screen_images/lotterycategory_202401231601472sqb.png',
          gradientColors: [Color(0xFFFA6557), Color(0xFFF13D30)],
        ),
      ],
      winnings: initialWinnings,
    );

    // Auto-generate a new winner every 2.5 seconds
    _winningTimer = Timer.periodic(const Duration(seconds: 2, milliseconds: 500), (timer) {
      _generateRandomWinner();
    });
  }

  HomeState get state => _state;

  int _currentBannerIndex = 0;
  int get currentBannerIndex => _currentBannerIndex;

  void updateBannerIndex(int index) {
    _currentBannerIndex = index;
    notifyListeners();
  }

  void _generateRandomWinner() {
    // Generate random 3 letter suffix for name
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final suffix = String.fromCharCodes(
      Iterable.generate(3, (_) => alphabet.codeUnitAt(_random.nextInt(alphabet.length))),
    );
    final username = 'Mem***$suffix';
    final avatarUrl = 'https://api.dicebear.com/7.x/adventurer/png?seed=$suffix';

    const gameImagePath = 'assets/images/main_screen_images/vendorlogo_20250819141232etgc.png';

    // Random amount between 100 and 35000, formatted cleanly
    final amount = (_random.nextDouble() * 34900 + 100);
    // Rounded to two decimal places
    final roundedAmount = double.parse(amount.toStringAsFixed(2));

    final newWinner = WinningInfo(
      username: username,
      avatarUrl: avatarUrl,
      gameImagePath: gameImagePath,
      amount: roundedAmount,
    );

    // Prepend new winner and remove oldest if exceeds 5
    final updatedWinnings = List<WinningInfo>.from(_state.winnings);
    updatedWinnings.insert(0, newWinner);
    if (updatedWinnings.length > 5) {
      updatedWinnings.removeLast();
    }

    _state = HomeState(
      logoImagePath: _state.logoImagePath,
      bannerImages: _state.bannerImages,
      announcement: _state.announcement,
      categories: _state.categories,
      recommendations: _state.recommendations,
      winnings: updatedWinnings,
    );

    notifyListeners();
  }

  void onCategoryPressed(GameCategory category) {
    debugPrint('Selected category: ${category.title}');
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

  @override
  void dispose() {
    _winningTimer?.cancel();
    super.dispose();
  }
}
