import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/k3_model.dart';
import '../viewmodels/k3_viewmodel.dart';

class K3View extends StatelessWidget {
  const K3View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<K3ViewModel>.value(
      value: K3ViewModel(),
      child: const _K3Content(),
    );
  }
}

class _K3Content extends StatefulWidget {
  const _K3Content();

  @override
  State<_K3Content> createState() => _K3ContentState();
}

class _K3ContentState extends State<_K3Content> {
  String? _twoSameDouble;
  int? _twoSameSingle;
  final Set<int> _threeDiffSingles = {};
  final Set<int> _twoDiffSingles = {};

  void _showResolutionDialog(BuildContext context, K3ResolutionResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final isWin = result.isWon;

        // Auto-dismiss dialog after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (dialogContext.mounted) {
            Navigator.pop(dialogContext);
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: isWin
                  ? const LinearGradient(
                      colors: [Color(0xFFF15147), Color(0xFFFFA84C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF3A3D4D), Color(0xFF5E627A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    isWin ? Icons.emoji_events : Icons.mood_bad,
                    color: isWin ? const Color(0xFFFFA84C) : const Color(0xFF5E627A),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isWin ? 'Congratulations!' : 'Sorry!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isWin ? 'You win with amount:' : 'You lose your money:',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isWin
                      ? '+₹${result.totalPayout.toStringAsFixed(2)}'
                      : '-₹${result.totalBetAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isWin ? const Color(0xFF2FFE9D) : const Color(0xFFFF6D6D),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Period ID: ${result.periodId}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: isWin ? const Color(0xFFF15147) : const Color(0xFF3A3D4D),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      isWin ? 'Close' : 'Try Again',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<K3ViewModel>(context);
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
          'assets/images/logo/Zonex.png',
          height: 28,
          errorBuilder: (context, error, stackTrace) => const Text(
            'Zonex K3',
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

            // 3. Period & Countdown Panel
            _buildPeriodTimerPanel(context, viewModel, state),

            const SizedBox(height: 16),

            // 4. Dice Roll tray
            _buildDiceTrayPanel(context, state),

            const SizedBox(height: 16),

            // 5. Sic Bo Total Bet Selection Options
            _buildBetControlsCard(context, viewModel, state),

            const SizedBox(height: 16),

            // 6. History Selector tabs
            _buildHistoryTabs(context, viewModel, state),

            const SizedBox(height: 12),

            // 7. Dynamic Paginated Content
            _buildHistoryContent(context, viewModel, state),

            const SizedBox(height: 30),
          ],
        ),
      ),
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
              'Attention ! Attention ! To all Zonex Games members...',
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

  Widget _buildWalletCard(BuildContext context, K3ViewModel viewModel, K3State state) {
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
                  // Silent mock refresh action
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

  void _showMockWithdrawDialog(BuildContext context, K3ViewModel viewModel) {
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

  void _showMockDepositDialog(BuildContext context, K3ViewModel viewModel) {
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

  Widget _buildGameTabs(BuildContext context, K3ViewModel viewModel, K3State state) {
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
          _buildTabItem(context, viewModel, state, K3TabType.minute1, 'K3 1 Min'),
          _buildTabItem(context, viewModel, state, K3TabType.minute3, 'K3 3 Min'),
          _buildTabItem(context, viewModel, state, K3TabType.minute5, 'K3 5 Min'),
          _buildTabItem(context, viewModel, state, K3TabType.minute10, 'K3 10 Min'),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    K3ViewModel viewModel,
    K3State state,
    K3TabType tabType,
    String title,
  ) {
    final isSelected = state.activeTab == tabType;

    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.selectTab(tabType),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF15147) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/main_screen_images/wingo times.png',
                width: 26,
                height: 26,
                // Fallback to Icon if watch asset is missing
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.timer,
                  color: isSelected ? Colors.white : const Color(0xFF888888),
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF666666),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTimerPanel(BuildContext context, K3ViewModel viewModel, K3State state) {
    // Format minutes and seconds
    final minutes = (state.timeRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (state.timeRemaining % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Period Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showHowToPlayDialog(context, state.activeTab),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFF15147), width: 1.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.menu_book, color: Color(0xFFF15147), size: 13),
                      SizedBox(width: 3),
                      Text(
                        'How to play',
                        style: TextStyle(color: Color(0xFFF15147), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.periodId,
                style: const TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Timer Countdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Time remaining',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildDigitCard(minutes[0]),
                  const SizedBox(width: 2),
                  _buildDigitCard(minutes[1]),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      ':',
                      style: TextStyle(color: Color(0xFFF15147), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildDigitCard(seconds[0]),
                  const SizedBox(width: 2),
                  _buildDigitCard(seconds[1]),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHowToPlayDialog(BuildContext context, K3TabType activeTab) {
    String tabTitle = 'K3 1min';
    if (activeTab == K3TabType.minute3) tabTitle = 'K3 3min';
    if (activeTab == K3TabType.minute5) tabTitle = 'K3 5min';
    if (activeTab == K3TabType.minute10) tabTitle = 'K3 10min';

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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fast 3 open with 3 numbers in each period as the opening number, The opening numbers are 111 to 666 Natural number, No zeros in the array, And the opening numbers are in no particular order, Quick 3 is to guess all or part of the 3 winning numbers.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.45),
                      ),
                      const SizedBox(height: 16),
                      _buildRuleSection('Sum Value', 'Place a bet on the sum of three numbers'),
                      _buildRuleSection('Choose 3 same number all', 'For all the same three numbers (111、222、...、666) Make an all-inclusive bet'),
                      _buildRuleSection('Choose 3 same number single', 'From all the same three numbers (111、...、666) Choose a group of numbers in any of them to place bets'),
                      _buildRuleSection('Choose 2 Same Multiple', 'Place a bet on two designated same numbers and an arbitrary number among the three numbers'),
                      _buildRuleSection('Choose 2 Same Single', 'Place a bet on two designated same numbers and a designated different number among the three numbers'),
                      _buildRuleSection('3 numbers different', 'Place a bet on three different numbers'),
                      _buildRuleSection('2 numbers different', 'Place a bet on two designated different numbers and an arbitrary number among the three numbers'),
                      _buildRuleSection('Choose 3 Consecutive number all', 'For all three consecutive numbers (123、234、345、456) Place a bet'),
                      const Divider(height: 24),
                      const Text(
                        'Description of winning and odds:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 12),
                      _buildRuleSection('Sum Value', 'A bet with the same opening number and value is the winning'),
                      _buildRuleSection('Choose 3 same number all', 'If the opening numbers are any three of the same number, it is the winning'),
                      _buildRuleSection('Choose 3 same number single', 'A bet that is exactly the same as the opening number is the winning'),
                      _buildRuleSection('Choose 2 Same Multiple', 'The same number as the two same numbers in the opening number (except for the three same numbers) is the winning'),
                      _buildRuleSection('Choose 2 Same Single', 'A bet that is exactly the same as the two designated same numbers and one designated different number is the winning'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildRuleSection(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF666666), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitCard(String digit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        digit,
        style: const TextStyle(
          color: Color(0xFFF15147),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDiceTrayPanel(BuildContext context, K3State state) {
    final recentDraw = state.history.isNotEmpty
        ? state.history.first.dice
        : const [1, 1, 1];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF008D5B), // Green Sic Bo rollboard
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF008D5B).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.arrow_left, color: Colors.white54, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDice(recentDraw[0]),
                _buildDice(recentDraw[1]),
                _buildDice(recentDraw[2]),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_right, color: Colors.white54, size: 28),
        ],
      ),
    );
  }

  Widget _buildDice(int value) {
    final dot = Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFEB3B), // Yellow dot
      ),
    );

    final empty = const SizedBox(width: 6, height: 6);

    List<List<Widget>> grid;
    switch (value) {
      case 1:
        grid = [
          [empty, empty, empty],
          [empty, dot, empty],
          [empty, empty, empty],
        ];
        break;
      case 2:
        grid = [
          [dot, empty, empty],
          [empty, empty, empty],
          [empty, empty, dot],
        ];
        break;
      case 3:
        grid = [
          [dot, empty, empty],
          [empty, dot, empty],
          [empty, empty, dot],
        ];
        break;
      case 4:
        grid = [
          [dot, empty, dot],
          [empty, empty, empty],
          [dot, empty, dot],
        ];
        break;
      case 5:
        grid = [
          [dot, empty, dot],
          [empty, dot, empty],
          [dot, empty, dot],
        ];
        break;
      case 6:
      default:
        grid = [
          [dot, empty, dot],
          [dot, empty, dot],
          [dot, empty, dot],
        ];
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE53935), // Red dice
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: grid.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: row,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String odds) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF222222),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'odds($odds)',
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.help, color: Color(0xFFF15147), size: 14),
        ],
      ),
    );
  }

  Widget _buildSquareBox({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF15147) : color,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.white, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF222222),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _checkTwoSameTrigger(K3ViewModel viewModel) {
    if (_twoSameDouble != null && _twoSameSingle != null) {
      final choice = 'pair_unique_${_twoSameDouble}_$_twoSameSingle';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBetBottomSheet(context, viewModel, choice);
        setState(() {
          _twoSameDouble = null;
          _twoSameSingle = null;
        });
      });
    }
  }

  void _checkThreeDiffTrigger(K3ViewModel viewModel) {
    if (_threeDiffSingles.length == 3) {
      final sortedList = _threeDiffSingles.toList()..sort();
      final choice = 'diff_3_${sortedList.join('_')}';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBetBottomSheet(context, viewModel, choice);
        setState(() {
          _threeDiffSingles.clear();
        });
      });
    }
  }

  void _checkTwoDiffTrigger(K3ViewModel viewModel) {
    if (_twoDiffSingles.length == 2) {
      final sortedList = _twoDiffSingles.toList()..sort();
      final choice = 'diff_2_${sortedList.join('_')}';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBetBottomSheet(context, viewModel, choice);
        setState(() {
          _twoDiffSingles.clear();
        });
      });
    }
  }

  Widget _buildBetControlsCard(BuildContext context, K3ViewModel viewModel, K3State state) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Board Tabs
          Row(
            children: [
              _buildBoardTabItem(context, viewModel, state, 'Total', K3BetTab.total),
              _buildBoardTabItem(context, viewModel, state, '2 same', K3BetTab.twoSame),
              _buildBoardTabItem(context, viewModel, state, '3 same', K3BetTab.threeSame),
              _buildBoardTabItem(context, viewModel, state, 'Different', K3BetTab.different),
            ],
          ),
          const SizedBox(height: 20),

          // Dynamic Board Sections
          if (state.activeBetTab == K3BetTab.total) ...[
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 3))),
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 4))),
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 5))),
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 6))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 7))),
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 8))),
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 9))),
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 10))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 11))),
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 12))),
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 13))),
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 14))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 15))),
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 16))),
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 17))),
                    Expanded(child: Center(child: _buildSumSelectionCircle(context, viewModel, 18))),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                _buildOutcomeButton(context, viewModel, 'Small', const Color(0xFF5CA3FF), '2X'),
                const SizedBox(width: 8),
                _buildOutcomeButton(context, viewModel, 'Big', const Color(0xFFFFA84C), '2X'),
                const SizedBox(width: 8),
                _buildOutcomeButton(context, viewModel, 'Even', const Color(0xFF2CA87E), '2X'),
                const SizedBox(width: 8),
                _buildOutcomeButton(context, viewModel, 'Odd', const Color(0xFFF15147), '2X'),
              ],
            ),
          ] else if (state.activeBetTab == K3BetTab.twoSame) ...[
            _buildSectionHeader('2 matching numbers', '13.83'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (idx) {
                final doubleVal = '${idx + 1}${idx + 1}';
                return _buildSquareBox(
                  label: doubleVal,
                  color: const Color(0xFFE8EAF6),
                  isSelected: false,
                  onTap: () => _showBetBottomSheet(context, viewModel, 'two_matching_$doubleVal'),
                );
              }),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('A pair of unique numbers', '69.12'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (idx) {
                final doubleVal = '${idx + 1}${idx + 1}';
                final isSelected = _twoSameDouble == doubleVal;
                return _buildSquareBox(
                  label: doubleVal,
                  color: const Color(0xFFFFE0B2),
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _twoSameDouble = null;
                      } else {
                        _twoSameDouble = doubleVal;
                        _checkTwoSameTrigger(viewModel);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (idx) {
                final singleVal = idx + 1;
                final isSelected = _twoSameSingle == singleVal;
                return _buildSquareBox(
                  label: '$singleVal',
                  color: const Color(0xFFC8E6C9),
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _twoSameSingle = null;
                      } else {
                        _twoSameSingle = singleVal;
                        _checkTwoSameTrigger(viewModel);
                      }
                    });
                  },
                );
              }),
            ),
          ] else if (state.activeBetTab == K3BetTab.threeSame) ...[
            _buildSectionHeader('3 of the same number', '207.36'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (idx) {
                final tripleVal = '${idx + 1}${idx + 1}${idx + 1}';
                return _buildSquareBox(
                  label: tripleVal,
                  color: const Color(0xFFE8EAF6),
                  isSelected: false,
                  onTap: () => _showBetBottomSheet(context, viewModel, 'three_matching_$tripleVal'),
                );
              }),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Any 3 of the same number', '34.56'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showBetBottomSheet(context, viewModel, 'any_three_same'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC80),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Any 3 of the same number',
                  style: TextStyle(
                    color: Color(0xFFE65100),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else if (state.activeBetTab == K3BetTab.different) ...[
            _buildSectionHeader('3 different numbers', '34.56'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (idx) {
                final val = idx + 1;
                final isSelected = _threeDiffSingles.contains(val);
                return _buildSquareBox(
                  label: '$val',
                  color: const Color(0xFFE8EAF6),
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _threeDiffSingles.remove(val);
                      } else {
                        if (_threeDiffSingles.length < 3) {
                          _threeDiffSingles.add(val);
                          _checkThreeDiffTrigger(viewModel);
                        }
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('3 continuous numbers', '8.64'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showBetBottomSheet(context, viewModel, 'three_continuous'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC80),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '3 continuous numbers',
                  style: TextStyle(
                    color: Color(0xFFE65100),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('2 different numbers', '6.91'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (idx) {
                final val = idx + 1;
                final isSelected = _twoDiffSingles.contains(val);
                return _buildSquareBox(
                  label: '$val',
                  color: const Color(0xFFE8EAF6),
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _twoDiffSingles.remove(val);
                      } else {
                        if (_twoDiffSingles.length < 2) {
                          _twoDiffSingles.add(val);
                          _checkTwoDiffTrigger(viewModel);
                        }
                      }
                    });
                  },
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBoardTabItem(
    BuildContext context,
    K3ViewModel viewModel,
    K3State state,
    String title,
    K3BetTab tab,
  ) {
    final isSelected = state.activeBetTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _twoSameDouble = null;
            _twoSameSingle = null;
            _threeDiffSingles.clear();
            _twoDiffSingles.clear();
          });
          viewModel.selectBetTab(tab);
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF15147) : const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF888888),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSumSelectionCircle(BuildContext context, K3ViewModel viewModel, int number) {
    final isOdd = number % 2 != 0;
    final color = isOdd ? const Color(0xFFF34C43) : const Color(0xFF2CA87E);

    final Map<int, String> multipliers = {
      3: '207.36', 4: '69.12', 5: '34.56', 6: '20.74', 7: '13.83', 8: '9.88',
      9: '8.3', 10: '7.68', 11: '7.68', 12: '8.3', 13: '9.88', 14: '13.83',
      15: '20.74', 16: '34.56', 17: '69.12', 18: '207.36'
    };
    final mult = multipliers[number] ?? '2.0';

    return GestureDetector(
      onTap: () => _showBetBottomSheet(context, viewModel, 'sum_$number'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2.0),
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${mult}X',
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeButton(
    BuildContext context,
    K3ViewModel viewModel,
    String label,
    Color color,
    String mult,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showBetBottomSheet(context, viewModel, label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mult,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBetBottomSheet(BuildContext context, K3ViewModel viewModel, String choice) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return _BetConfirmPanel(viewModel: viewModel, choice: choice);
      },
    );
  }

  Widget _buildHistoryTabs(BuildContext context, K3ViewModel viewModel, K3State state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildHistoryTabButton(viewModel, state, K3HistoryTab.gameHistory, 'Game history'),
          const SizedBox(width: 8),
          _buildHistoryTabButton(viewModel, state, K3HistoryTab.chart, 'Chart'),
          const SizedBox(width: 8),
          _buildHistoryTabButton(viewModel, state, K3HistoryTab.myHistory, 'My history'),
        ],
      ),
    );
  }

  Widget _buildHistoryTabButton(
    K3ViewModel viewModel,
    K3State state,
    K3HistoryTab tab,
    String text,
  ) {
    final isSelected = state.activeHistoryTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.selectHistoryTab(tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF15147) : const Color(0xFFF0F1F5),
            borderRadius: BorderRadius.circular(24.0),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF888888),
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryContent(BuildContext context, K3ViewModel viewModel, K3State state) {
    switch (state.activeHistoryTab) {
      case K3HistoryTab.gameHistory:
        return _buildGameHistoryTable(context, viewModel, state);
      case K3HistoryTab.chart:
        return _buildChartContent(context, viewModel, state);
      case K3HistoryTab.myHistory:
        if (state.myBets.isEmpty) {
          return _buildPlaceholderTab('Your personal bet history is empty.');
        }
        return _buildMyHistoryList(context, viewModel, state);
    }
  }

  Widget _buildPlaceholderTab(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.hourglass_empty, color: Color(0xFFCCCCCC), size: 40),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGameHistoryTable(BuildContext context, K3ViewModel viewModel, K3State state) {
    final startIndex = (state.gameHistoryPage - 1) * 10;
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
                      'Sum',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Size',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Odd Even',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedHistory.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F3F9), height: 1),
              itemBuilder: (context, index) {
                final result = displayedHistory[index];
                final globalIndex = startIndex + index;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          _getPeriodIdForIndex(state.periodId, globalIndex),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF555555), fontSize: 12.5, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${result.sum}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFF15147), fontSize: 13.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          result.bigSmall,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF333333), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          result.oddEven,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF333333), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF1F3F9))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: state.gameHistoryPage > 1 ? () => viewModel.prevGameHistoryPage() : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: state.gameHistoryPage > 1 ? const Color(0xFFF7F8FC) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: state.gameHistoryPage > 1 ? const Color(0xFF555555) : const Color(0xFFCCCCCC),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    '${state.gameHistoryPage}/50',
                    style: const TextStyle(color: Color(0xFF555555), fontSize: 14.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: state.gameHistoryPage < 50 ? () => viewModel.nextGameHistoryPage() : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: state.gameHistoryPage < 50 ? const Color(0xFFF15147) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: state.gameHistoryPage < 50 ? Colors.white : const Color(0xFFCCCCCC),
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

  Widget _buildChartContent(BuildContext context, K3ViewModel viewModel, K3State state) {
    const double periodWidth = 110.0;
    const double rightWidth = 35.0;

    final missing = viewModel.getMissingStatistics();
    final frequency = viewModel.getFrequencyStatistics();

    final startIndex = (state.chartPage - 1) * 10;
    final displayedHistory = state.history.skip(startIndex).take(10).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
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
                    child: Center(
                      child: Text(
                        'Sum',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: rightWidth),
                ],
              ),
            ),

            _buildStatRow('Statistic', ['(last 100 Periods)'], periodWidth, rightWidth, isStatisticRow: true),
            _buildStatRow('Winning Sums', [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], periodWidth, rightWidth, isWinningNumberRow: true),
            _buildStatRow('Missing', missing, periodWidth, rightWidth),
            _buildStatRow('Frequency', frequency, periodWidth, rightWidth),

            const SizedBox(height: 10),

            CustomPaint(
              painter: K3TrendLinePainter(
                history: displayedHistory,
                rowHeight: 44.0,
                periodWidth: periodWidth,
                rightWidth: rightWidth,
              ),
              child: Column(
                children: List.generate(displayedHistory.length, (index) {
                  final result = displayedHistory[index];
                  final globalIndex = startIndex + index;
                  final periodId = _getPeriodIdForIndex(state.periodId, globalIndex);
                  return _buildChartRow(result, periodId, periodWidth, rightWidth, index);
                }),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF1F3F9))),
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
                    style: const TextStyle(color: Color(0xFF555555), fontSize: 14.5, fontWeight: FontWeight.bold),
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
    double rightWidth, {
    bool isWinningNumberRow = false,
    bool isStatisticRow = false,
  }) {
    return Container(
      height: 36.0,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F3F9))),
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
                    color: isWinningNumberRow || label == 'Statistic' ? const Color(0xFF222222) : const Color(0xFF888888),
                    fontSize: 11,
                    fontWeight: isWinningNumberRow || label == 'Statistic' ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: isStatisticRow
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      values.first as String,
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Row(
                    children: List.generate(16, (idx) {
                      final val = values[idx];
                      Widget childWidget;

                      if (isWinningNumberRow) {
                        childWidget = Text(
                          '$val',
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(color: Color(0xFFF15147), fontSize: 9.0, fontWeight: FontWeight.bold),
                        );
                      } else {
                        childWidget = Text(
                          '$val',
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(color: Color(0xFF777777), fontSize: 8.0, fontWeight: FontWeight.w500),
                        );
                      }

                      return Expanded(
                        child: Center(child: childWidget),
                      );
                    }),
                  ),
          ),
          SizedBox(width: rightWidth),
        ],
      ),
    );
  }

  Widget _buildChartRow(
    K3DrawResult result,
    String periodId,
    double periodWidth,
    double rightWidth,
    int index,
  ) {
    return Container(
      height: 44.0,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F3F9))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: periodWidth,
            child: Center(
              child: Text(
                periodId,
                style: const TextStyle(color: Color(0xFF555555), fontSize: 11.5, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: List.generate(16, (idx) {
                final targetSum = idx + 3;
                final isWinning = result.sum == targetSum;
                final isOdd = targetSum % 2 != 0;
                final color = isOdd ? const Color(0xFFF34C43) : const Color(0xFF2CA87E);

                return Expanded(
                  child: Center(
                    child: isWinning
                        ? Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                            alignment: Alignment.center,
                            child: Text(
                              '$targetSum',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          )
                        : const Text(
                            '-',
                            style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 11),
                          ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            width: rightWidth,
            child: Center(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: result.bigSmall == 'Big' ? const Color(0xFFFFA84C) : const Color(0xFF5CA3FF),
                ),
                alignment: Alignment.center,
                child: Text(
                  result.bigSmall == 'Big' ? 'B' : 'S',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyHistoryList(BuildContext context, K3ViewModel viewModel, K3State state) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: state.myBets.length,
      itemBuilder: (context, index) {
        final bet = state.myBets[index];
        return _buildMyBetCard(context, viewModel, bet);
      },
    );
  }

  Widget _buildMyBetCard(BuildContext context, K3ViewModel viewModel, K3Bet bet) {
    final bool isWin = bet.isWon;
    final bool isResolved = bet.isResolved;

    String cleanChoice = bet.choice;
    if (bet.choice.startsWith('sum_')) {
      cleanChoice = 'Sum ${bet.choice.substring(4)}';
    } else if (bet.choice.startsWith('two_matching_')) {
      cleanChoice = '2 Matching: ${bet.choice.substring(13)}';
    } else if (bet.choice.startsWith('pair_unique_')) {
      final parts = bet.choice.substring(12).split('_');
      cleanChoice = 'Pair: ${parts[0]} & ${parts[1]}';
    } else if (bet.choice.startsWith('three_matching_')) {
      cleanChoice = '3 Matching: ${bet.choice.substring(15)}';
    } else if (bet.choice == 'any_three_same') {
      cleanChoice = 'Any 3 Same';
    } else if (bet.choice == 'three_continuous') {
      cleanChoice = '3 Continuous';
    } else if (bet.choice.startsWith('diff_3_')) {
      final parts = bet.choice.substring(7).split('_');
      cleanChoice = '3 Diff: ${parts.join(',')}';
    } else if (bet.choice.startsWith('diff_2_')) {
      final parts = bet.choice.substring(7).split('_');
      cleanChoice = '2 Diff: ${parts.join(',')}';
    }

    // Try to find the draw result rolled for this bet's period
    K3DrawResult? drawResult;
    if (isResolved) {
      try {
        final state = viewModel.state;
        final currentPeriod = state.allPeriodIds[bet.tabType] ?? state.periodId;
        final currentCount = int.parse(currentPeriod.substring(currentPeriod.length - 4));
        final betCount = int.parse(bet.periodId.substring(bet.periodId.length - 4));
        final index = currentCount - betCount - 1;
        final tabHistory = state.allHistories[bet.tabType] ?? state.history;
        if (index >= 0 && index < tabHistory.length) {
          drawResult = tabHistory[index];
        }
      } catch (_) {}
    }

    final String formattedDate = '${bet.timestamp.year}-${bet.timestamp.month.toString().padLeft(2, '0')}-${bet.timestamp.day.toString().padLeft(2, '0')} ${bet.timestamp.hour.toString().padLeft(2, '0')}:${bet.timestamp.minute.toString().padLeft(2, '0')}:${bet.timestamp.second.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF15147),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cleanChoice,
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bet.periodId,
                    style: const TextStyle(color: Color(0xFF555555), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
              ),
              if (drawResult != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Result: ',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 11),
                    ),
                    Text(
                      '${drawResult.sum} ',
                      style: const TextStyle(color: Color(0xFFF34C43), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    ...drawResult.dice.map((d) {
                      return Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF15147),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$d',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isResolved
                        ? (isWin ? const Color(0xFF2CA87E) : const Color(0xFFF34C43))
                        : const Color(0xFF888888),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  isResolved ? (isWin ? 'Succeed' : 'Failed') : 'Waiting',
                  style: TextStyle(
                    color: isResolved
                        ? (isWin ? const Color(0xFF2CA87E) : const Color(0xFFF34C43))
                        : const Color(0xFF888888),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isResolved
                    ? (isWin
                        ? '+₹${bet.payout.toStringAsFixed(2)}'
                        : '-₹${bet.amount.toStringAsFixed(2)}')
                    : '₹${bet.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isResolved
                      ? (isWin ? const Color(0xFF2CA87E) : const Color(0xFFF34C43))
                      : const Color(0xFF555555),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
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
}

// --- Bet Sheet Confirmer Panel matching Wingo ---
class _BetConfirmPanel extends StatefulWidget {
  final K3ViewModel viewModel;
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
  int _betAmount = 10;

  @override
  void initState() {
    super.initState();
    _quantity = widget.viewModel.state.multiplier;
  }

  @override
  Widget build(BuildContext context) {
    final finalAmount = _betAmount * _quantity;

    String displayChoice = widget.choice;
    if (widget.choice.startsWith('sum_')) {
      displayChoice = 'Sum ${widget.choice.substring(4)}';
    }

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
                'K3 Bet: $displayChoice',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF888888)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Unit Bet Amount (₹)',
            style: TextStyle(fontSize: 13, color: Color(0xFF666666), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [10, 50, 100, 500, 1000].map((amount) {
              final isSel = _betAmount == amount;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _betAmount = amount),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFF15147) : const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '₹$amount',
                      style: TextStyle(
                        color: isSel ? Colors.white : const Color(0xFF555555),
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
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
                style: TextStyle(fontSize: 13, color: Color(0xFF666666), fontWeight: FontWeight.w500),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Bet', style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
                  Text(
                    '₹${finalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF15147)),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF15147),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  widget.viewModel.placeBet(widget.choice, finalAmount);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bet of ₹$finalAmount placed successfully!'),
                      backgroundColor: const Color(0xFF2CA87E),
                    ),
                  );
                },
                child: const Text('Confirm Bet', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class K3TrendLinePainter extends CustomPainter {
  final List<K3DrawResult> history;
  final double rowHeight;
  final double periodWidth;
  final double rightWidth;

  K3TrendLinePainter({
    required this.history,
    required this.rowHeight,
    required this.periodWidth,
    required this.rightWidth,
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
    final gridWidth = size.width - periodWidth - rightWidth;
    final colWidth = gridWidth / 16;

    for (int i = 0; i < history.length; i++) {
      final winningSum = history[i].sum;
      final idx = winningSum - 3;
      final cx = periodWidth + (idx * colWidth) + (colWidth / 2);
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
  bool shouldRepaint(covariant K3TrendLinePainter oldDelegate) {
    return oldDelegate.history != history ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.periodWidth != periodWidth ||
        oldDelegate.rightWidth != rightWidth;
  }
}
