import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';
import '../models/game_model.dart';

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
                _buildRecommendationContent(),
                
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
                    child: _buildCategoryCard(category),
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
              return _buildCategoryCard(mediumCategories[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(GameCategory category) {
    return GestureDetector(
      onTap: () => viewModel.onCategoryPressed(category),
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

  Widget _buildRecommendationContent() {
    // Standard mock cards representing recommendations below the fold
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/main_screen_images/popular-8_UUQbeo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.gamepad, color: Color(0xFFF34C43), size: 36),
                          SizedBox(height: 8),
                          Text(
                            'Win Go 1Min',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.casino, color: Color(0xFF8B2EFF), size: 36),
                  SizedBox(height: 8),
                  Text(
                    'Trx Hash 3Min',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
