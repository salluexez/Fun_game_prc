import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wingo_model.dart';
import '../viewmodels/wingo_viewmodel.dart';

class WingoView extends StatelessWidget {
  const WingoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WingoViewModel>.value(
      value: WingoViewModel(),
      child: const _WingoContent(),
    );
  }
}

class _WingoContent extends StatelessWidget {
  const _WingoContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WingoViewModel>(context);
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF34C43),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo/h5setting_20240423194834yt8f.png',
          height: 28,
          errorBuilder: (context, error, stackTrace) => const Text(
            'Daman',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.white, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.support_agent, color: Colors.white, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Announcement Bar
            _buildAnnouncementBar(context),

            const SizedBox(height: 12),

            // 2. Game Tabs (30s, 1m, 3m, 5m)
            _buildGameTabs(context, viewModel, state),

            const SizedBox(height: 16),

            // 3. Ticket Timer Panel (Notched Card)
            _buildTicketTimerPanel(context, viewModel, state),

            const SizedBox(height: 16),

            // 4. Color & Number Bet Selection Options
            _buildBetControlsCard(context, viewModel, state),

            const SizedBox(height: 16),

            // 5. History Tabs Selector
            _buildHistoryTabs(context, viewModel, state),

            const SizedBox(height: 12),

            // 6. Selected History Content (Table or Placeholder)
            _buildHistoryContent(context, viewModel, state),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.volume_up, color: Color(0xFFF34C43), size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Daman is a secured website using encryption to protect your privacy.',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 12.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFA776D), Color(0xFFF15147)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.whatshot, color: Colors.white, size: 12),
                SizedBox(width: 3),
                Text(
                  'Detail',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTabs(BuildContext context, WingoViewModel viewModel, WingoState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          _buildTabItem(context, viewModel, state, WingoTabType.seconds30, 'WinGo\n30sec'),
          _buildTabItem(context, viewModel, state, WingoTabType.minute1, 'WinGo\n1 Min'),
          _buildTabItem(context, viewModel, state, WingoTabType.minute3, 'WinGo\n3 Min'),
          _buildTabItem(context, viewModel, state, WingoTabType.minute5, 'WinGo\n5 Min'),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    WingoViewModel viewModel,
    WingoState state,
    WingoTabType tabType,
    String label,
  ) {
    final isSelected = state.activeTab == tabType;

    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.selectTab(tabType),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFA776D), Color(0xFFF15147)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/main_screen_images/wingo times.png',
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.alarm,
                  color: isSelected ? Colors.white : Colors.grey[400],
                  size: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF888888),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketTimerPanel(BuildContext context, WingoViewModel viewModel, WingoState state) {
    final formatSeconds = _formatTime(state.timeRemaining);
    final minutesDigits = formatSeconds.substring(0, 2).split('');
    final secondsDigits = formatSeconds.substring(3, 5).split('');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 140,
      child: Stack(
        children: [
          // Base card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFA776D), Color(0xFFF15147)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                // Left Half
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // How to play button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white70, width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'How to play',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      // Tab title
                      Text(
                        _getTabTitle(state.activeTab),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: state.history.take(5)
                            .map((res) => _buildDrawResultCircle(res, viewModel))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                // Right Half
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Time remaining',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Time digits card row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildDigitCard(minutesDigits[0]),
                          const SizedBox(width: 2),
                          _buildDigitCard(minutesDigits[1]),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text(
                              ':',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          _buildDigitCard(secondsDigits[0]),
                          const SizedBox(width: 2),
                          _buildDigitCard(secondsDigits[1]),
                        ],
                      ),
                      // Period Number
                      Text(
                        state.periodId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Left notch cutout circle overlay
          Positioned(
            left: -8,
            top: 62,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF7F8FC),
              ),
            ),
          ),
          // Right notch cutout circle overlay
          Positioned(
            right: -8,
            top: 62,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF7F8FC),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitCard(String digit) {
    return Container(
      width: 20,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: const TextStyle(
          color: Color(0xFFF15147),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawResultCircle(DrawResult result, WingoViewModel viewModel) {
    final colors = result.colors;
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(right: 5.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white38, width: 0.8),
        gradient: colors.length > 1
            ? LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.5, 0.5],
              )
            : null,
        color: colors.length == 1 ? colors.first : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${result.number}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBetControlsCard(BuildContext context, WingoViewModel viewModel, WingoState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. Red, Violet, Green Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildColorBetButton(context, viewModel, 'Green', const Color(0xFF2CA87E)),
              const SizedBox(width: 8),
              _buildColorBetButton(context, viewModel, 'Violet', const Color(0xFF9E5CFF)),
              const SizedBox(width: 8),
              _buildColorBetButton(context, viewModel, 'Red', const Color(0xFFF34C43)),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Number Grid (0-9)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return _buildNumberButton(context, viewModel, index);
            },
          ),

          const SizedBox(height: 16),

          // 3. Multiplier Row
          _buildMultiplierRow(context, viewModel, state),

          const SizedBox(height: 16),

          // 4. Big and Small buttons
          Row(
            children: [
              Expanded(
                child: _buildBigSmallButton(context, viewModel, 'Big', const Color(0xFFFFA84C)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBigSmallButton(context, viewModel, 'Small', const Color(0xFF5CA3FF)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorBetButton(
    BuildContext context,
    WingoViewModel viewModel,
    String label,
    Color color,
  ) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          elevation: 0,
        ),
        onPressed: () => _showBetBottomSheet(context, viewModel, label),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNumberButton(BuildContext context, WingoViewModel viewModel, int number) {
    final colors = viewModel.getColorsForNumber(number);

    return InkWell(
      onTap: () => _showBetBottomSheet(context, viewModel, '$number'),
      borderRadius: BoxShape.circle == null ? null : BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(2.5),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: colors.length > 1
                ? LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.5, 0.5],
                  )
                : null,
            color: colors.length == 1 ? colors.first : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiplierRow(BuildContext context, WingoViewModel viewModel, WingoState state) {
    final multipliers = [1, 5, 10, 20, 50, 100];

    return Row(
      children: [
        // Random Selection Button
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFF15147), width: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          onPressed: () {
            final randomVal = Random().nextInt(10);
            _showBetBottomSheet(context, viewModel, '$randomVal');
          },
          child: const Text(
            'Random',
            style: TextStyle(color: Color(0xFFF15147), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        // Multipliers List
        Expanded(
          child: SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: multipliers.length,
              itemBuilder: (context, index) {
                final mult = multipliers[index];
                final isSelected = state.multiplier == mult;

                return GestureDetector(
                  onTap: () => viewModel.selectMultiplier(mult),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6.0),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2CA87E) : const Color(0xFFF1F3F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'X$mult',
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF555555),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBigSmallButton(
    BuildContext context,
    WingoViewModel viewModel,
    String label,
    Color color,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        elevation: 0,
      ),
      onPressed: () => _showBetBottomSheet(context, viewModel, label),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showBetBottomSheet(BuildContext context, WingoViewModel viewModel, String choice) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _BetConfirmPanel(
          viewModel: viewModel,
          choice: choice,
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getTabTitle(WingoTabType tab) {
    switch (tab) {
      case WingoTabType.seconds30:
        return 'WinGo 30sec';
      case WingoTabType.minute1:
        return 'WinGo 1 Min';
      case WingoTabType.minute3:
        return 'WinGo 3 Min';
      case WingoTabType.minute5:
        return 'WinGo 5 Min';
    }
  }

  Widget _buildHistoryTabs(BuildContext context, WingoViewModel viewModel, WingoState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildHistoryTabButton(viewModel, state, WingoHistoryTab.gameHistory, 'Game history'),
          const SizedBox(width: 8),
          _buildHistoryTabButton(viewModel, state, WingoHistoryTab.chart, 'Chart'),
          const SizedBox(width: 8),
          _buildHistoryTabButton(viewModel, state, WingoHistoryTab.myHistory, 'My history'),
        ],
      ),
    );
  }

  Widget _buildHistoryTabButton(
    WingoViewModel viewModel,
    WingoState state,
    WingoHistoryTab tabType,
    String label,
  ) {
    final isSelected = state.activeHistoryTab == tabType;
    return GestureDetector(
      onTap: () => viewModel.selectHistoryTab(tabType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFA776D), Color(0xFFF15147)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF777777),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryContent(BuildContext context, WingoViewModel viewModel, WingoState state) {
    switch (state.activeHistoryTab) {
      case WingoHistoryTab.gameHistory:
        return _buildGameHistoryTable(context, viewModel, state);
      case WingoHistoryTab.chart:
        return _buildChartContent(context, viewModel, state);
      case WingoHistoryTab.myHistory:
        if (state.myBets.isEmpty) {
          return _buildPlaceholderTab('Your personal bet history is empty.');
        }
        return _buildMyHistoryList(context, viewModel, state);
    }
  }

  Widget _buildMyHistoryList(BuildContext context, WingoViewModel viewModel, WingoState state) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: state.myBets.length,
      itemBuilder: (context, index) {
        final bet = state.myBets[index];
        return _buildMyBetCard(context, viewModel, state, bet);
      },
    );
  }

  Widget _buildMyBetCard(
    BuildContext context,
    WingoViewModel viewModel,
    WingoState state,
    WingoBet bet,
  ) {
    final badgeDecor = _getBadgeDecoration(bet.choice, viewModel);

    Color statusColor;
    String statusText;
    Color payoutColor;
    String payoutText;

    if (!bet.isResolved) {
      statusColor = Colors.grey;
      statusText = 'Waiting';
      payoutColor = const Color(0xFF666666);
      payoutText = '₹${bet.amount.toStringAsFixed(2)}';
    } else if (bet.isWon) {
      statusColor = const Color(0xFF2CA87E);
      statusText = 'Succeed';
      payoutColor = const Color(0xFF2CA87E);
      payoutText = '+₹${bet.payout.toStringAsFixed(2)}';
    } else {
      statusColor = const Color(0xFFF34C43);
      statusText = 'Failed';
      payoutColor = const Color(0xFFF34C43);
      payoutText = '-₹${bet.amount.toStringAsFixed(2)}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Badge
          Container(
            width: 48,
            height: 48,
            decoration: badgeDecor,
            alignment: Alignment.center,
            child: Text(
              bet.choice,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Center Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      bet.periodId,
                      style: const TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: Color(0xFF666666),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(bet.timestamp),
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          // Right Status & Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: statusColor, width: 1.0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                payoutText,
                style: TextStyle(
                  color: payoutColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _getBadgeDecoration(String choice, WingoViewModel viewModel) {
    final number = int.tryParse(choice);
    if (number != null) {
      final colors = viewModel.getColorsForNumber(number);
      if (colors.length == 1) {
        return BoxDecoration(
          color: colors.first,
          borderRadius: BorderRadius.circular(10),
        );
      } else {
        return BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.5, 0.5],
          ),
          borderRadius: BorderRadius.circular(10),
        );
      }
    }

    Color badgeColor;
    if (choice == 'Big') {
      badgeColor = const Color(0xFFFFA84C);
    } else if (choice == 'Small') {
      badgeColor = const Color(0xFF5CA3FF);
    } else if (choice == 'Green') {
      badgeColor = const Color(0xFF2CA87E);
    } else if (choice == 'Red') {
      badgeColor = const Color(0xFFF34C43);
    } else if (choice == 'Violet') {
      badgeColor = const Color(0xFF9E5CFF);
    } else {
      badgeColor = Colors.grey;
    }

    return BoxDecoration(
      color: badgeColor,
      borderRadius: BorderRadius.circular(10),
    );
  }

  String _formatDateTime(DateTime dt) {
    final year = dt.year;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  Widget _buildPlaceholderTab(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildGameHistoryTable(BuildContext context, WingoViewModel viewModel, WingoState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Table Header Row
            Container(
              color: const Color(0xFFF15147),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Period',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Number',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Big Small',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Color',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Table Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.history.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFFF1F3F9),
                height: 1,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final result = state.history[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          _getPeriodIdForIndex(state.periodId, index),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Number Column (Styled gradient or solid text)
                      Expanded(
                        flex: 2,
                        child: _buildGradientNumberText(result.number, result.colors),
                      ),
                      // Big Small Column
                      Expanded(
                        flex: 2,
                        child: Text(
                          result.bigSmall,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Color Dots Column
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: result.colors.map((color) {
                            return Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.symmetric(horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientNumberText(int number, List<Color> colors) {
    if (colors.length == 1) {
      return Text(
        '$number',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.first,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    // Render gradient text for split colors (0 and 5)
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        '$number',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPeriodIdForIndex(String currentPeriod, int index) {
    try {
      final base = currentPeriod.substring(0, currentPeriod.length - 4);
      final count = int.parse(currentPeriod.substring(currentPeriod.length - 4));
      final targetCount = count - (index + 1);
      final targetCountStr = targetCount.toString().padLeft(4, '0');
      return '$base$targetCountStr';
    } catch (_) {
      return currentPeriod;
    }
  }

  // --- Wingo Chart Tab View implementation ---

  Widget _buildChartContent(BuildContext context, WingoViewModel viewModel, WingoState state) {
    const double periodWidth = 135.0;
    const double bigSmallWidth = 35.0;

    // Get statistics calculated from WingoViewModel
    final missing = viewModel.getMissingStatistics();
    final avgMissing = viewModel.getAvgMissingStatistics();
    final frequency = viewModel.getFrequencyStatistics();
    final maxConsecutive = viewModel.getMaxConsecutiveStatistics();

    // Limit display rows to 10 items per page slice
    final startIndex = (state.chartPage - 1) * 10;
    final displayedHistory = state.history.skip(startIndex).take(10).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header Row
            Container(
              color: const Color(0xFFF15147),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const SizedBox(
                    width: periodWidth,
                    child: Text(
                      'Period',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Number',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: bigSmallWidth),
                ],
              ),
            ),

            // Statistics Section
            Container(
              height: 36.0,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF1F3F9), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: periodWidth,
                    child: Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Statistic',
                          style: TextStyle(
                            color: Color(0xFF222222),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '(last 100 Periods)',
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: bigSmallWidth),
                ],
              ),
            ),
            _buildStatRow('Winning Numbers', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], periodWidth, bigSmallWidth, isWinningNumberRow: true),
            _buildStatRow('Missing', missing, periodWidth, bigSmallWidth),
            _buildStatRow('Avg missing', avgMissing, periodWidth, bigSmallWidth),
            _buildStatRow('Frequency', frequency, periodWidth, bigSmallWidth),
            _buildStatRow('Max consecutive', maxConsecutive, periodWidth, bigSmallWidth),

            const SizedBox(height: 10),

            // Draws & Trend Path Line Section
            CustomPaint(
              painter: WingoTrendLinePainter(
                history: displayedHistory,
                rowHeight: 44.0,
                periodWidth: periodWidth,
                bigSmallWidth: bigSmallWidth,
              ),
              child: Column(
                children: List.generate(displayedHistory.length, (index) {
                  final result = displayedHistory[index];
                  final globalIndex = startIndex + index;
                  final periodId = _getPeriodIdForIndex(state.periodId, globalIndex);
                  return _buildChartRow(result, periodId, periodWidth, bigSmallWidth, index);
                }),
              ),
            ),

            const SizedBox(height: 10),

            // Pagination Controls Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFF1F3F9), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: state.chartPage > 1 ? () => viewModel.prevPage() : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: state.chartPage > 1 ? const Color(0xFFF7F8FC) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: state.chartPage > 1 ? const Color(0xFF555555) : const Color(0xFFCCCCCC),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    '${state.chartPage}/50',
                    style: const TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: state.chartPage < 50 ? () => viewModel.nextPage() : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: state.chartPage < 50 ? const Color(0xFFF15147) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: state.chartPage < 50 ? Colors.white : const Color(0xFFCCCCCC),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    List<dynamic> values,
    double periodWidth,
    double bigSmallWidth, {
    bool isWinningNumberRow = false,
    bool isPlainTextOnly = false,
  }) {
    return Container(
      height: 36.0,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F3F9), width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: periodWidth,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isWinningNumberRow || label == 'Statistic'
                        ? const Color(0xFF222222)
                        : const Color(0xFF888888),
                    fontSize: 12,
                    fontWeight: isWinningNumberRow || label == 'Statistic'
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: List.generate(10, (num) {
                final val = values[num];
                Widget childWidget;

                if (isPlainTextOnly) {
                  childWidget = Text(
                    '$val',
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                } else if (isWinningNumberRow) {
                  childWidget = Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF15147), width: 1.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$val',
                      style: const TextStyle(
                        color: Color(0xFFF15147),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  childWidget = Text(
                    '$val',
                    style: const TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }

                return Expanded(
                  child: Center(child: childWidget),
                );
              }),
            ),
          ),
          SizedBox(width: bigSmallWidth),
        ],
      ),
    );
  }

  Widget _buildChartRow(
    DrawResult result,
    String periodId,
    double periodWidth,
    double bigSmallWidth,
    int index,
  ) {
    return Container(
      height: 44.0,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F3F9), width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: periodWidth,
            child: Center(
              child: Text(
                periodId,
                style: const TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: List.generate(10, (num) {
                final isWinning = result.number == num;
                return Expanded(
                  child: Center(
                    child: _buildChartNumberCircle(num, isWinning, result.colors),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            width: bigSmallWidth,
            child: Center(
              child: _buildBigSmallBadge(result.bigSmall),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartNumberCircle(int num, bool isWinning, List<Color> colors) {
    if (!isWinning) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFEBEBEB), width: 1.0),
        ),
        alignment: Alignment.center,
        child: Text(
          '$num',
          style: const TextStyle(
            color: Color(0xFFCCCCCC),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    BoxDecoration decor;
    if (colors.length == 1) {
      decor = BoxDecoration(
        shape: BoxShape.circle,
        color: colors.first,
      );
    } else {
      decor = BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.5, 0.5],
        ),
      );
    }

    return Container(
      width: 20,
      height: 20,
      decoration: decor,
      alignment: Alignment.center,
      child: Text(
        '$num',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBigSmallBadge(String bigSmall) {
    final isBig = bigSmall == 'Big';
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isBig ? const Color(0xFFFFA84C) : const Color(0xFF5CA3FF),
      ),
      alignment: Alignment.center,
      child: Text(
        isBig ? 'B' : 'S',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Trend Line Custom Painter
// -------------------------------------------------------------
class WingoTrendLinePainter extends CustomPainter {
  final List<DrawResult> history;
  final double rowHeight;
  final double periodWidth;
  final double bigSmallWidth;

  WingoTrendLinePainter({
    required this.history,
    required this.rowHeight,
    required this.periodWidth,
    required this.bigSmallWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;

    final linePaint = Paint()
      ..color = const Color(0xFFF15147)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Calculate gridWidth dynamically from constraints
    final gridWidth = size.width - periodWidth - bigSmallWidth;
    final colWidth = gridWidth / 10;

    for (int i = 0; i < history.length; i++) {
      final winningNumber = history[i].number;
      final cx = periodWidth + (winningNumber * colWidth) + (colWidth / 2);
      final cy = (i * rowHeight) + (rowHeight / 2);

      if (i == 0) {
        path.moveTo(cx, cy);
      } else {
        path.lineTo(cx, cy);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant WingoTrendLinePainter oldDelegate) {
    return oldDelegate.history != history ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.periodWidth != periodWidth ||
        oldDelegate.bigSmallWidth != bigSmallWidth;
  }
}

// -------------------------------------------------------------
// Interactive Bet Confirmation Bottom Sheet
// -------------------------------------------------------------
class _BetConfirmPanel extends StatefulWidget {
  final WingoViewModel viewModel;
  final String choice;

  const _BetConfirmPanel({
    required this.viewModel,
    required this.choice,
  });

  @override
  State<_BetConfirmPanel> createState() => _BetConfirmPanelState();
}

class _BetConfirmPanelState extends State<_BetConfirmPanel> {
  late int _quantity;
  int _betAmount = 10; // Default base amount

  @override
  void initState() {
    super.initState();
    _quantity = widget.viewModel.state.multiplier;
  }

  @override
  Widget build(BuildContext context) {
    final finalAmount = _betAmount * _quantity;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WinGo Bet: ${widget.choice}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),
          // Base Bet Amount Selectors
          const Text(
            'Unit Bet Amount (₹)',
            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [10, 50, 100, 500, 1000].map((amt) {
              final isSelected = _betAmount == amt;
              return GestureDetector(
                onTap: () => setState(() => _betAmount = amt),
                child: Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF15147) : const Color(0xFFF1F3F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹$amt',
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF555555),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Quantity Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Multiplier Quantity',
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFF15147)),
                    onPressed: () {
                      if (_quantity > 1) {
                        setState(() => _quantity--);
                      }
                    },
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFFF15147)),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Total Bet Display & Final Action Buttons
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Total Bet: ',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      TextSpan(
                        text: '₹${finalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFF15147),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF15147),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  widget.viewModel.placeBet(widget.choice, finalAmount);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bet of ₹$finalAmount placed successfully!'),
                      backgroundColor: const Color(0xFF2CA87E),
                    ),
                  );
                },
                child: const Text('Confirm Bet', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
