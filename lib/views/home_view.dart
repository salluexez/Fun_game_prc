import 'package:flutter/material.dart';
import 'dart:ui';
import '../viewmodels/home_viewmodel.dart';
import '../models/game_model.dart';
import 'wingo_view.dart';
import 'k3_view.dart';
import 'five_d_view.dart';
import 'trx_wingo_view.dart';
import 'login_view.dart';
import 'register_view.dart';
import 'deposit_view.dart';
import 'withdraw_view.dart';
import '../services/api_service.dart';
import '../services/wallet_service.dart';

class HomeView extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeView({super.key, required this.viewModel});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  HomeViewModel get viewModel => widget.viewModel;

  Widget _buildAccountTab(BuildContext context) {
    return ListenableBuilder(
      listenable: ApiService(),
      builder: (context, _) {
        final isLoggedIn = ApiService().isLoggedIn;

        if (!isLoggedIn) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Icon(Icons.account_circle, size: 100, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Please login to view your account details',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF34C43),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginView()),
                        );
                      },
                      child: const Text('Log in', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF34C43)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterView()),
                        );
                      },
                      child: const Text('Register', style: TextStyle(color: Color(0xFFF34C43))),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final phone = ApiService().currentUserPhone ?? 'User';
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF34C43), Color(0xFFF8736B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 40),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.person, size: 40, color: Color(0xFFF34C43)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phone,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'UID: 9283719',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              ListenableBuilder(
                listenable: WalletService(),
                builder: (context, _) {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFF34C43)),
                                SizedBox(width: 8),
                                Text(
                                  'Wallet Balance',
                                  style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.grey),
                              onPressed: () => WalletService().syncBalance(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${WalletService().balance.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF34C43),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const DepositView()),
                                  );
                                },
                                child: const Text('Deposit', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFF34C43)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const WithdrawView()),
                                  );
                                },
                                child: const Text('Withdraw', style: TextStyle(color: Color(0xFFF34C43))),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildAccountMenuItem(Icons.description_outlined, 'Bet History', () {}),
                    const Divider(height: 1, indent: 50),
                    _buildAccountMenuItem(Icons.history_edu, 'Transaction Details', () {}),
                    const Divider(height: 1, indent: 50),
                    _buildAccountMenuItem(Icons.security, 'Security settings', () {}),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF34C43),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      ApiService().logout();
                      WalletService().syncBalance();
                    },
                    child: const Text('Log out', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF666666)),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.82),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF34C43).withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListenableBuilder(
                      listenable: viewModel,
                      builder: (context, _) {
                        return Image.asset(
                          viewModel.state.logoImagePath,
                          height: 34,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              'Zonex',
                              style: TextStyle(
                                color: Color(0xFFF34C43),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ListenableBuilder(
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
          _buildAccountTab(context),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 36, right: 36, bottom: 16, top: 4),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      alignment: _selectedIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFF34C43).withOpacity(0.15),
                                const Color(0xFFF8736B).withOpacity(0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: const Color(0xFFF34C43).withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _selectedIndex = 0;
                              });
                              _pageController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                                  color: _selectedIndex == 0 ? const Color(0xFFF34C43) : const Color(0xFF8E8E93),
                                  size: 22,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Home',
                                  style: TextStyle(
                                    color: _selectedIndex == 0 ? const Color(0xFFF34C43) : const Color(0xFF8E8E93),
                                    fontSize: 10,
                                    fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _selectedIndex = 1;
                              });
                              _pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _selectedIndex == 1 ? Icons.person : Icons.person_outline,
                                  color: _selectedIndex == 1 ? const Color(0xFFF34C43) : const Color(0xFF8E8E93),
                                  size: 22,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Account',
                                  style: TextStyle(
                                    color: _selectedIndex == 1 ? const Color(0xFFF34C43) : const Color(0xFF8E8E93),
                                    fontSize: 10,
                                    fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ],
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
      )
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
              } else if (game.title.toLowerCase().contains('trx')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrxWingoView()),
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
            'Welcome to Zonex Games works with more than 10,000 online live game dealers and slot games, all of which are verified fair games.',
          ),
          const SizedBox(height: 16),
          _buildDisclaimerRow(
            'Welcome to Zonex Games supports fast deposit and withdrawal, and looks forward to your visit.',
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
            'Welcome to Zonex Games only accepts customers above the age of 18.',
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
                        'assets/images/logo/Zonex.png',
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
