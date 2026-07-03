import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/five_d_model.dart';
import '../viewmodels/five_d_viewmodel.dart';

class FiveDView extends StatelessWidget {
  const FiveDView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: FiveDViewModel(),
      child: const _FiveDContent(),
    );
  }
}

class _FiveDContent extends StatefulWidget {
  const _FiveDContent();

  @override
  State<_FiveDContent> createState() => _FiveDContentState();
}

class _FiveDContentState extends State<_FiveDContent> {
  int _activePositionIndex = 0; // For Chart tab position selection (A-E index: 0-4)

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FiveDViewModel>(context);
    final state = viewModel.state;

    if (state.lastResolution != null) {
      final res = state.lastResolution!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResolutionDialog(context, res);
        viewModel.clearResolution();
      });
    }

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
            'Daman 5D',
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
            Container(
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
              child: Column(
                children: [
                  _buildWalletCard(context, viewModel, state),
                  _buildAnnouncementBar(context),
                  const SizedBox(height: 16),
                  _buildGameTabs(context, viewModel, state),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lottery Results Panel
            _buildLotteryResultsPanel(context, state),

            const SizedBox(height: 16),

            // Period & Countdown Panel
            _buildPeriodTimerPanel(context, viewModel, state),

            const SizedBox(height: 16),

            // Digit Reel / Lottery Drum
            _buildDigitReelPanel(context, state),

            const SizedBox(height: 16),

            // Position & Sum Bet selection Controls
            _buildBetControlsCard(context, viewModel, state),

            const SizedBox(height: 16),

            // History Tab Selector
            _buildHistoryTabs(context, viewModel, state),

            const SizedBox(height: 12),

            // History Content (Game History, Chart, My History)
            _buildHistoryContent(context, viewModel, state),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, FiveDViewModel viewModel, FiveDState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      padding: const EdgeInsets.all(16.0),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₹${state.balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Silent refresh
                },
                child: const Icon(Icons.refresh, color: Color(0xFF888888), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet, color: Color(0xFFF15147), size: 16),
              SizedBox(width: 6),
              Text(
                'Wallet balance',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF15147),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    _showMockWithdrawDialog(context, viewModel);
                  },
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2CA87E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    _showMockDepositDialog(context, viewModel);
                  },
                  child: const Text(
                    'Deposit',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMockWithdrawDialog(BuildContext context, FiveDViewModel viewModel) {
    final controller = TextEditingController(text: '10.00');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Color(0xFFF15147)),
              SizedBox(width: 8),
              Text('Withdraw Funds', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter amount to withdraw (Dummy Money):', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixText: '₹',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFF15147))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15147),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0.0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                  return;
                }
                final success = viewModel.withdraw(amount);
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully withdrew ₹${amount.toStringAsFixed(2)}!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Insufficient balance for withdrawal!')),
                  );
                }
              },
              child: const Text('Withdraw', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showMockDepositDialog(BuildContext context, FiveDViewModel viewModel) {
    final controller = TextEditingController(text: '100.00');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Row(
            children: [
              Icon(Icons.add_circle, color: Color(0xFF2CA87E)),
              SizedBox(width: 8),
              Text('Deposit Funds', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter amount to deposit (Dummy Money):', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixText: '₹',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2CA87E))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2CA87E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0.0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                  return;
                }
                viewModel.deposit(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Successfully deposited ₹${amount.toStringAsFixed(2)}!')),
                );
              },
              child: const Text('Deposit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnnouncementBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.volume_up, color: Color(0xFFF34C43), size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'All Recharge payment methods on DamanGames are working fine...',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 12.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF34C43),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.whatshot, color: Colors.white, size: 12),
                SizedBox(width: 2),
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

  Widget _buildGameTabs(BuildContext context, FiveDViewModel viewModel, FiveDState state) {
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
          _buildTabItem(context, viewModel, state, FiveDTabType.minute1, '5D 1 Min'),
          _buildTabItem(context, viewModel, state, FiveDTabType.minute3, '5D 3 Min'),
          _buildTabItem(context, viewModel, state, FiveDTabType.minute5, '5D 5 Min'),
          _buildTabItem(context, viewModel, state, FiveDTabType.minute10, '5D 10 Min'),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    FiveDViewModel viewModel,
    FiveDState state,
    FiveDTabType tabType,
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
                height: 24,
                width: 24,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.alarm,
                  size: 24,
                  color: isSelected ? Colors.white : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF666666),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLotteryResultsPanel(BuildContext context, FiveDState state) {
    if (state.history.isEmpty) return const SizedBox.shrink();
    final latest = state.history.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Lottery\nresults',
            style: TextStyle(fontSize: 13, color: Color(0xFF666666), fontWeight: FontWeight.bold, height: 1.3),
          ),
          Row(
            children: [
              _buildResultDigitCircle(latest.digits[0], 'A'),
              const SizedBox(width: 6),
              _buildResultDigitCircle(latest.digits[1], 'B'),
              const SizedBox(width: 6),
              _buildResultDigitCircle(latest.digits[2], 'C'),
              const SizedBox(width: 6),
              _buildResultDigitCircle(latest.digits[3], 'D'),
              const SizedBox(width: 6),
              _buildResultDigitCircle(latest.digits[4], 'E'),
              const SizedBox(width: 8),
              const Text('=', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFF15147),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${latest.sum}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultDigitCircle(int digit, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            '$digit',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPeriodTimerPanel(BuildContext context, FiveDViewModel viewModel, FiveDState state) {
    final minutes = (state.timeRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (state.timeRemaining % 60).toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showHowToPlayDialog(context, state.activeTab),
                icon: const Icon(Icons.menu_book, size: 14, color: Color(0xFFF15147)),
                label: const Text('How to play', style: TextStyle(color: Color(0xFFF15147), fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  side: const BorderSide(color: Color(0xFFF15147)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.periodId,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Time remaining', style: TextStyle(fontSize: 11, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildTimeDigitBox(minutes[0]),
                  const SizedBox(width: 3),
                  _buildTimeDigitBox(minutes[1]),
                  const Text(' : ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF15147))),
                  _buildTimeDigitBox(seconds[0]),
                  const SizedBox(width: 3),
                  _buildTimeDigitBox(seconds[1]),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHowToPlayDialog(BuildContext context, FiveDTabType activeTab) {
    String tabTitle = '5D 1min';
    if (activeTab == FiveDTabType.minute3) tabTitle = '5D 3min';
    if (activeTab == FiveDTabType.minute5) tabTitle = '5D 5min';
    if (activeTab == FiveDTabType.minute10) tabTitle = '5D 10min';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF15147),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '• $tabTitle •',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '5D lottery game rules',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Draw instructions',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF555555)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A 5-digit number (00000-99999) will be drawn randomly in each period.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'for example:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'The draw number for this Period is 12345',
                      style: TextStyle(fontSize: 13, color: Color(0xFF555555), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('A = 1', style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4)),
                          Text('B = 2', style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4)),
                          Text('C = 3', style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4)),
                          Text('D = 4', style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4)),
                          Text('E = 5', style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF15147),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeDigitBox(String digit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0EF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        digit,
        style: const TextStyle(color: Color(0xFFF15147), fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDigitReelPanel(BuildContext context, FiveDState state) {
    if (state.history.isEmpty) return const SizedBox.shrink();
    final latest = state.history.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00B07C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final digit = latest.digits[index];
          return Container(
            width: 50,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '$digit',
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF5D6B82)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBetControlsCard(BuildContext context, FiveDViewModel viewModel, FiveDState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Sub-tabs A, B, C, D, E, SUM
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: FiveDBetTab.values.map((tab) {
              final isSelected = state.activeBetTab == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => viewModel.selectBetTab(tab),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF15147) : const Color(0xFFF7F8FC),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab == FiveDBetTab.SUM ? 'SUM' : tab.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF555555),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Render selectors based on BetTab (SUM or Position A-E)
          if (state.activeBetTab == FiveDBetTab.SUM)
            _buildSumBetSelectionGrid(context, viewModel)
          else
            _buildPositionBetSelectionGrid(context, viewModel, state.activeBetTab),
        ],
      ),
    );
  }

  Widget _buildSumBetSelectionGrid(BuildContext context, FiveDViewModel viewModel) {
    return Row(
      children: [
        _buildCategoryButton(context, viewModel, FiveDBetTab.SUM, 'Big', const Color(0xFFFFA84C)),
        const SizedBox(width: 8),
        _buildCategoryButton(context, viewModel, FiveDBetTab.SUM, 'Small', const Color(0xFF4C8CFF)),
        const SizedBox(width: 8),
        _buildCategoryButton(context, viewModel, FiveDBetTab.SUM, 'Odd', const Color(0xFF2CA87E)),
        const SizedBox(width: 8),
        _buildCategoryButton(context, viewModel, FiveDBetTab.SUM, 'Even', const Color(0xFF9E5CFF)),
      ],
    );
  }

  Widget _buildCategoryButton(BuildContext context, FiveDViewModel viewModel, FiveDBetTab positionTab, String choice, Color color) {
    final displayLabel = choice.endsWith('2') ? choice.substring(0, choice.length - 1) : choice;
    return Expanded(
      child: InkWell(
        onTap: () => _showBettingDialog(context, viewModel, positionTab, choice),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            displayLabel,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionBetSelectionGrid(BuildContext context, FiveDViewModel viewModel, FiveDBetTab tab) {
    return Column(
      children: [
        Row(
          children: [
            _buildCategoryButton(context, viewModel, tab, 'Big2', const Color(0xFFFFA84C)),
            const SizedBox(width: 8),
            _buildCategoryButton(context, viewModel, tab, 'Small2', const Color(0xFF4C8CFF)),
            const SizedBox(width: 8),
            _buildCategoryButton(context, viewModel, tab, 'Odd2', const Color(0xFF2CA87E)),
            const SizedBox(width: 8),
            _buildCategoryButton(context, viewModel, tab, 'Even2', const Color(0xFF9E5CFF)),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showBettingDialog(context, viewModel, tab, '$index'),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$index',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '9X',
                  style: TextStyle(fontSize: 10, color: Color(0xFF888888), fontWeight: FontWeight.w500),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showBettingDialog(BuildContext context, FiveDViewModel viewModel, FiveDBetTab tab, String choice) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return _BetConfirmSheet(viewModel: viewModel, positionTab: tab, choice: choice);
      },
    );
  }

  Widget _buildHistoryTabs(BuildContext context, FiveDViewModel viewModel, FiveDState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          _buildHistoryTabItem(context, viewModel, state, FiveDHistoryTab.gameHistory, 'Game history'),
          _buildHistoryTabItem(context, viewModel, state, FiveDHistoryTab.chart, 'Chart'),
          _buildHistoryTabItem(context, viewModel, state, FiveDHistoryTab.myHistory, 'My history'),
        ],
      ),
    );
  }

  Widget _buildHistoryTabItem(
    BuildContext context,
    FiveDViewModel viewModel,
    FiveDState state,
    FiveDHistoryTab tab,
    String label,
  ) {
    final isSelected = state.activeHistoryTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.selectHistoryTab(tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF15147) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF666666),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryContent(BuildContext context, FiveDViewModel viewModel, FiveDState state) {
    switch (state.activeHistoryTab) {
      case FiveDHistoryTab.gameHistory:
        return _buildGameHistoryList(context, viewModel, state);
      case FiveDHistoryTab.chart:
        return _buildChartGrid(context, viewModel, state);
      case FiveDHistoryTab.myHistory:
        return _buildPersonalBets(context, viewModel, state);
    }
  }

  Widget _buildGameHistoryList(BuildContext context, FiveDViewModel viewModel, FiveDState state) {
    final itemsPerPage = 10;
    final startIndex = (state.gameHistoryPage - 1) * itemsPerPage;
    final pagedHistory = state.history.skip(startIndex).take(itemsPerPage).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF15147),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 3, child: Text('Period', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 4, child: Center(child: Text('Result', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
                Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
              ],
            ),
          ),

          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pagedHistory.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final draw = pagedHistory[index];
              
              // Calculate periodId based on index page offset
              final int baseSuffix = int.parse(state.periodId.substring(state.periodId.length - 4));
              final rowSuffix = baseSuffix - startIndex - index - 1;
              final prefix = state.periodId.substring(0, state.periodId.length - 4);
              final periodStr = '$prefix${rowSuffix.toString().padLeft(4, '0')}';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 3, child: Text(periodStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF333333)))),
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHistoryMiniCircle(draw.digits[0]),
                          const SizedBox(width: 4),
                          _buildHistoryMiniCircle(draw.digits[1]),
                          const SizedBox(width: 4),
                          _buildHistoryMiniCircle(draw.digits[2]),
                          const SizedBox(width: 4),
                          _buildHistoryMiniCircle(draw.digits[3]),
                          const SizedBox(width: 4),
                          _buildHistoryMiniCircle(draw.digits[4]),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF15147),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text('${draw.sum}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Pager
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (state.gameHistoryPage > 1) {
                      viewModel.prevGameHistoryPage();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF888888)),
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  '${state.gameHistoryPage}/50',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: () {
                    if (state.gameHistoryPage < 50) {
                      viewModel.nextGameHistoryPage();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF15147),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryMiniCircle(int digit) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Text('$digit', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
    );
  }

  Widget _buildChartGrid(BuildContext context, FiveDViewModel viewModel, FiveDState state) {
    // 5D Chart view selection sub tabs
    final positionLetters = ['A', 'B', 'C', 'D', 'E'];
    final itemsPerPage = 10;
    final startIndex = (state.chartPage - 1) * itemsPerPage;
    final pagedHistory = state.history.skip(startIndex).take(itemsPerPage).toList();

    // Statistics lists
    final missingValues = viewModel.calculateMissing(_activePositionIndex);
    final avgMissing = viewModel.calculateAvgMissing(_activePositionIndex);
    final frequency = viewModel.calculateFrequency(_activePositionIndex);
    final maxConsecutive = viewModel.calculateMaxConsecutive(_activePositionIndex);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-tabs A, B, C, D, E
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: List.generate(5, (index) {
                final isSel = _activePositionIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activePositionIndex = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFF15147) : const Color(0xFFF7F8FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        positionLetters[index],
                        style: TextStyle(
                          color: isSel ? Colors.white : const Color(0xFF555555),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: const Text(
              'Statistic (last 100 Periods)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333)),
            ),
          ),

          // Statistics rows
          _buildStatRow('Missing', missingValues),
          _buildStatRow('Avg missing', avgMissing),
          _buildStatRow('Frequency', frequency),
          _buildStatRow('Max consecutive', maxConsecutive),

          const SizedBox(height: 12),

          // Trend Diagram Table
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: const Color(0xFFF15147),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Period', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 7, child: Center(child: Text('Number', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
              ],
            ),
          ),

          // Layout chart grid with trend line painter overlay
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: FiveDTrendLinePainter(
                        history: pagedHistory,
                        rowHeight: 40.0,
                        periodWidth: constraints.maxWidth * 0.3,
                        rightWidth: constraints.maxWidth * 0.18,
                        activePositionIndex: _activePositionIndex,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pagedHistory.length,
                    itemBuilder: (context, index) {
                      final draw = pagedHistory[index];
                      final winningDigit = draw.digits[_activePositionIndex];

                      // Suffix sequence calculation
                      final int baseSuffix = int.parse(state.periodId.substring(state.periodId.length - 4));
                      final rowSuffix = baseSuffix - startIndex - index - 1;
                      final prefix = state.periodId.substring(0, state.periodId.length - 4);
                      final periodStr = '$prefix${rowSuffix.toString().padLeft(4, '0')}';

                      final isBig = winningDigit >= 5;
                      final isOdd = winningDigit % 2 != 0;

                      return Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                        ),
                        child: Row(
                          children: [
                            // Period column
                            Expanded(
                              flex: 3,
                              child: Text(
                                periodStr,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF555555)),
                              ),
                            ),
                            // Numbers 0-9 column
                            Expanded(
                              flex: 7,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: List.generate(10, (num) {
                                      final isWin = winningDigit == num;
                                      return Container(
                                        width: 16,
                                        height: 16,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isWin ? const Color(0xFFF15147) : Colors.transparent,
                                          border: isWin ? null : Border.all(color: Colors.grey.shade200),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$num',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isWin ? Colors.white : Colors.grey[400],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  // Right Big/Small, Odd/Even indicators
                                  Row(
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: isBig ? const Color(0xFFFFA84C) : const Color(0xFF4C8CFF),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          isBig ? 'B' : 'S',
                                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: isOdd ? const Color(0xFF2CA87E) : const Color(0xFF9E5CFF),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          isOdd ? 'O' : 'E',
                                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),

          // Pager
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (state.chartPage > 1) {
                      viewModel.prevPage();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF888888)),
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  '${state.chartPage}/50',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: () {
                    if (state.chartPage < 50) {
                      viewModel.nextPage();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF15147),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, List<int> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF888888), fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(10, (index) {
                return Container(
                  width: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  alignment: Alignment.center,
                  child: Text(
                    '${values[index]}',
                    style: const TextStyle(fontSize: 8.5, color: Color(0xFF444444), fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalBets(BuildContext context, FiveDViewModel viewModel, FiveDState state) {
    if (state.myBets.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.center,
        child: const Text('No records found', style: TextStyle(color: Color(0xFF888888))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.myBets.length,
      itemBuilder: (context, index) {
        final bet = state.myBets[index];
        final isWon = bet.isWon;

        Color choiceColor = const Color(0xFFF15147);
        if (bet.choice == 'Big' || bet.choice == 'Big2') choiceColor = const Color(0xFFFFA84C);
        if (bet.choice == 'Small' || bet.choice == 'Small2') choiceColor = const Color(0xFF4C8CFF);
        if (bet.choice == 'Odd' || bet.choice == 'Odd2') choiceColor = const Color(0xFF2CA87E);
        if (bet.choice == 'Even' || bet.choice == 'Even2') choiceColor = const Color(0xFF9E5CFF);

        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: choiceColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${bet.positionTab.name} - ${bet.choice}',
                          style: TextStyle(color: choiceColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${bet.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Period: ${bet.periodId}',
                    style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    bet.timestamp.toString().substring(0, 19),
                    style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 10),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isWon ? const Color(0xFF2CA87E) : const Color(0xFFF15147),
                  ),
                ),
                child: Text(
                  isWon ? '+₹${bet.payout.toStringAsFixed(2)}' : '-₹${bet.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isWon ? const Color(0xFF2CA87E) : const Color(0xFFF15147),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResolutionDialog(BuildContext context, FiveDResolutionResult result) {
    // 3-Second Auto-dismiss dialog
    Future.delayed(const Duration(seconds: 3), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final double finalPayout = result.totalPayout;
        final double finalLoss = result.totalBetAmount;
        final isWon = result.isWon;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isWon
                    ? [const Color(0xFFFFA84C), const Color(0xFFF15147)]
                    : [const Color(0xFF8A95A5), const Color(0xFF5A6472)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isWon ? Icons.emoji_events : Icons.mood_bad,
                  color: Colors.white,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  isWon ? 'Congratulations!' : 'Sorry!',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isWon ? 'You won bets in period' : 'Better luck next time in period',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                Text(
                  result.periodId,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    isWon ? '+₹${finalPayout.toStringAsFixed(2)}' : '-₹${finalLoss.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Automatically closes in 3 seconds...',
                  style: TextStyle(color: Colors.white60, fontSize: 9.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BetConfirmSheet extends StatefulWidget {
  final FiveDViewModel viewModel;
  final FiveDBetTab positionTab;
  final String choice;

  const _BetConfirmSheet({
    required this.viewModel,
    required this.positionTab,
    required this.choice,
  });

  @override
  State<_BetConfirmSheet> createState() => _BetConfirmSheetState();
}

class _BetConfirmSheetState extends State<_BetConfirmSheet> {
  int _betAmount = 10;
  int _quantity = 1;

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
                '5D Bet: ${widget.positionTab.name} - ${widget.choice}',
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
                  if (finalAmount > widget.viewModel.state.balance) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Insufficient balance! Please deposit funds.'),
                        backgroundColor: Color(0xFFF15147),
                      ),
                    );
                    return;
                  }
                  widget.viewModel.placeBet(widget.positionTab, widget.choice, finalAmount);
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

class FiveDTrendLinePainter extends CustomPainter {
  final List<FiveDDrawResult> history;
  final double rowHeight;
  final double periodWidth;
  final double rightWidth;
  final int activePositionIndex;

  FiveDTrendLinePainter({
    required this.history,
    required this.rowHeight,
    required this.periodWidth,
    required this.rightWidth,
    required this.activePositionIndex,
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

    final gridWidth = size.width - periodWidth - rightWidth;
    final colWidth = gridWidth / 10;

    for (int i = 0; i < history.length; i++) {
      final winningDigit = history[i].digits[activePositionIndex];
      final cx = periodWidth + (winningDigit * colWidth) + (colWidth / 2);
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
  bool shouldRepaint(covariant FiveDTrendLinePainter oldDelegate) {
    return oldDelegate.history != history ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.periodWidth != periodWidth ||
        oldDelegate.rightWidth != rightWidth ||
        oldDelegate.activePositionIndex != activePositionIndex;
  }
}
