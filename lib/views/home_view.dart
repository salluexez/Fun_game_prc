import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';
import '../models/game_model.dart';
import 'wingo_view.dart';
import 'k3_view.dart';
import 'five_d_view.dart';

class HomeView extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC), // Light grey background matching Daman app
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Daman Logo
                  ListenableBuilder(
                    listenable: viewModel,
                    builder: (context, _) {
                      return Image.asset(
                        viewModel.state.logoImagePath,
                        height: 26,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback in case asset loading fails
                          return const Text(
                            'Daman',
                            style: TextStyle(
                              color: Color(0xFFF34C43),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Log in & Register Buttons
                  Row(
                    children: [
                      // Log in Button
                      SizedBox(
                        height: 34,
                        child: OutlinedButton(
                          onPressed: viewModel.onLoginPressed,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFF34C43), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: Color(0xFFF34C43),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Register Button
                      GestureDetector(
                        onTap: viewModel.onRegisterPressed,
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF75C53), Color(0xFFF23D31)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final state = viewModel.state;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                
                // 1. Banner Slider
                _buildBannerSlider(state),
                
                const SizedBox(height: 12),
                
                // 2. Announcement Ticker
                _buildAnnouncementTicker(context, state),
                
                const SizedBox(height: 12),
                
                // 3. Grid of Category Cards
                _buildCategoriesGrid(context, state),
                
                const SizedBox(height: 16),
                
                // 4. Platform Recommendation Section Header
                _buildPlatformRecommendationHeader(),
                
                // 5. Mock Recommendations (visually completes the screen layout)
                _buildRecommendationContent(context),
                
                const SizedBox(height: 16),
                
                // 6. Winning Information Section Header
                _buildWinningInfoHeader(),
                
                // 7. Dynamic Winning Information List
                WinningWinningsTicker(winnings: state.winnings),
                
                const SizedBox(height: 16),
                
                // 8. Platform Disclaimer & Information Container
                _buildPlatformDisclaimerCard(),
                
                const SizedBox(height: 12),
                
                // 9. Platform Menu Options Card
                _buildPlatformMenuCard(),
                
                // 10. Add to Desktop Capsule Button
                _buildAddToDesktopButton(),
                
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerSlider(HomeState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PageView.builder(
          itemCount: state.bannerImages.length,
          onPageChanged: viewModel.updateBannerIndex,
          itemBuilder: (context, index) {
            return Image.asset(
              state.bannerImages[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B11FF), Color(0xFFB511FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Banner ${index + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnnouncementTicker(BuildContext context, HomeState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Speaker Icon
          const Icon(
            Icons.volume_up,
            color: Color(0xFFF34C43),
            size: 20,
          ),
          const SizedBox(width: 8),
          // Scrolling Text Container
          Expanded(
            child: SizedBox(
              height: 20,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Center(
                    child: Text(
                      state.announcement,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Detail button with flame icon
          GestureDetector(
            onTap: viewModel.onDetailPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF9695C), Color(0xFFF13E33)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'Detail',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, HomeState state) {
    final largeCategories = state.categories.where((c) => c.isLarge).toList();
    final mediumCategories = state.categories.where((c) => !c.isLarge).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // 1. Two Large Categories (Popular, Lottery)
          Row(
            children: largeCategories.map((category) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: AspectRatio(
                    aspectRatio: 1.8,
                    child: _buildCategoryCard(context, category),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          
          // 2. Six Medium Categories (Casino, Slots, Sports, Rummy, Fishing, Original) in 3 columns
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mediumCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.45,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return _buildCategoryCard(context, mediumCategories[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, GameCategory category) {
    return GestureDetector(
      onTap: () {
        if (category.title == 'Lottery') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WingoView()),
          );
        } else {
          viewModel.onCategoryPressed(category);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: category.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Cleanly sized category image aligned center-left
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 6.0, bottom: 6.0),
                  child: FractionallySizedBox(
                    heightFactor: category.isLarge ? 0.88 : 0.80,
                    child: Image.asset(
                      category.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
              // Aligned text title overlay
              Align(
                alignment: category.textAlignment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  child: Text(
                    category.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: category.isLarge ? 15.5 : 12.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 1),
                          blurRadius: 2.5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformRecommendationHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Flame icon + Title
          const Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: Color(0xFFF34C43),
                size: 22,
              ),
              SizedBox(width: 4),
              Text(
                'Platform recommendation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),
          // Right: "All 6 >" Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12, width: 0.8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'All 6',
                  style: TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF777777),
                  size: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationContent(BuildContext context) {
    final recommendations = viewModel.state.recommendations;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recommendations.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.78,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final game = recommendations[index];
          return GestureDetector(
            onTap: () {
              if (game.title.toLowerCase().contains('k3')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const K3View()),
                );
              } else if (game.title.toLowerCase().contains('5d')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FiveDView()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WingoView()),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: game.gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      game.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 12.0),
                        child: Image.asset(
                          game.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWinningInfoHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFF34C43),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Winning information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformDisclaimerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDisclaimerRow(
            'The platform advocates fairness, justice, and openness. We mainly operate fair lottery, blockchain games, live casinos, and slot machine games.',
          ),
          const SizedBox(height: 16),
          _buildDisclaimerRow(
            'Welcome to Daman Games works with more than 10,000 online live game dealers and slot games, all of which are verified fair games.',
          ),
          const SizedBox(height: 16),
          _buildDisclaimerRow(
            'Welcome to Daman Games supports fast deposit and withdrawal, and looks forward to your visit.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Gambling can be addictive, please play rationally.',
            style: TextStyle(
              color: Color(0xFFF75C56),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome to Daman Games only accepts customers above the age of 18.',
            style: TextStyle(
              color: Color(0xFFF75C56),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2.0),
          child: Text(
            '♦ ',
            style: TextStyle(
              color: Color(0xFFF75C56),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformMenuCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.public,
            title: 'Language',
            onTap: () => viewModel.onCategoryPressed(
              const GameCategory(
                title: 'Language',
                imagePath: '',
                gradientColors: [],
              ),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.campaign,
            title: 'Announcement',
            onTap: () => viewModel.onDetailPressed(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.support_agent,
            title: '24/7 Customer service',
            onTap: () => viewModel.onCategoryPressed(
              const GameCategory(
                title: 'Customer Service',
                imagePath: '',
                gradientColors: [],
              ),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.menu_book,
            title: "Beginner's Guide",
            onTap: () => viewModel.onCategoryPressed(
              const GameCategory(
                title: 'Beginner Guide',
                imagePath: '',
                gradientColors: [],
              ),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.inventory_2,
            title: 'About us',
            onTap: () => viewModel.onCategoryPressed(
              const GameCategory(
                title: 'About Us',
                imagePath: '',
                gradientColors: [],
              ),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.file_download,
            title: 'Download APP',
            showDivider: false,
            onTap: () => viewModel.onCategoryPressed(
              const GameCategory(
                title: 'Download App',
                imagePath: '',
                gradientColors: [],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFA6557),
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        color: Color(0xFFF1F3F9),
        height: 1,
        thickness: 1,
      ),
    );
  }

  Widget _buildAddToDesktopButton() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFA776D), Color(0xFFF15147)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF15147).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => debugPrint('Add to Desktop clicked'),
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo/h5setting_20240423194834yt8f.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Add to Desktop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Animated list ticker that handles adding new winnings smoothly
// -------------------------------------------------------------
class WinningWinningsTicker extends StatefulWidget {
  final List<WinningInfo> winnings;

  const WinningWinningsTicker({super.key, required this.winnings});

  @override
  State<WinningWinningsTicker> createState() => _WinningWinningsTickerState();
}

class _WinningWinningsTickerState extends State<WinningWinningsTicker> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<WinningInfo> _localList = [];

  @override
  void initState() {
    super.initState();
    _localList.addAll(widget.winnings);
  }

  @override
  void didUpdateWidget(covariant WinningWinningsTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.winnings.isEmpty) return;

    // Check if a new winning item was added at the top
    if (oldWidget.winnings.isEmpty || 
        widget.winnings.first.username != oldWidget.winnings.first.username) {
      final newItem = widget.winnings.first;
      
      // 1. Insert the new item at index 0 in the AnimatedList
      _localList.insert(0, newItem);
      _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 600));

      // 2. If list exceeds maximum displayed winners (5), remove the last item
      if (_localList.length > 5) {
        final removedItem = _localList.removeAt(5);
        _listKey.currentState?.removeItem(
          5,
          (context, animation) => _buildWinningItemCard(removedItem, animation),
          duration: const Duration(milliseconds: 600),
        );
      }
    }
  }

  List<Color> _getGameGradient(String path) {
    if (path.contains('lotterycategory_')) {
      return const [Color(0xFFFA6557), Color(0xFFF13D30)];
    }
    if (path.contains('gamecategory_20240412114911i998.png')) {
      return const [Color(0xFFFF8B7D), Color(0xFFFF4935)]; // Casino
    }
    if (path.contains('gamecategory_20240412114929rkd9.png')) {
      return const [Color(0xFFA17DFF), Color(0xFF6732FF)]; // Slots
    }
    if (path.contains('gamecategory_20240412114921c1tg.png')) {
      return const [Color(0xFFFFB752), Color(0xFFFF8800)]; // Sports
    }
    if (path.contains('gamecategory_2024041211490142rl.png')) {
      return const [Color(0xFF68B2FF), Color(0xFF2675FF)]; // Rummy
    }
    if (path.contains('gamecategory_20240412114848em94.png')) {
      return const [Color(0xFFFF7E9B), Color(0xFFFA2C5E)]; // Fishing
    }
    if (path.contains('gamecategory_20240412114937mcis.png')) {
      return const [Color(0xFF5EDFFF), Color(0xFF00A2C9)]; // Original
    }
    return const [Color(0xFFFA6557), Color(0xFFF13D30)];
  }

  Widget _buildWinningItemCard(WinningInfo info, Animation<double> animation) {
    // Combine Fade and Slide transition for an elegant scrolling drop effect
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    ));

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: offsetAnimation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: 0.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Cartoon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF1F3F9),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      info.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.account_circle,
                        color: Colors.grey,
                        size: 38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Masked Username
                Expanded(
                  child: Text(
                    info.username,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                // Vendor Game Image
                Container(
                  height: 38,
                  width: 66,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      info.gameImagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Receive text and amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Receive ',
                            style: TextStyle(
                              color: Color(0xFF222222),
                              fontSize: 12.5,
                            ),
                          ),
                          TextSpan(
                            text: '₹${info.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF222222),
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Winning amount',
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      initialItemCount: _localList.length,
      itemBuilder: (context, index, animation) {
        return _buildWinningItemCard(_localList[index], animation);
      },
    );
  }
}
