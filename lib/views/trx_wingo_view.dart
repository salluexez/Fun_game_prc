import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/trx_wingo_model.dart';
import '../viewmodels/trx_wingo_viewmodel.dart';

class TrxWingoView extends StatelessWidget {
  const TrxWingoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TrxWingoViewModel>.value(
      value: TrxWingoViewModel(),
      child: const _TrxWingoContent(),
    );
  }
}

class _TrxWingoContent extends StatefulWidget {
  const _TrxWingoContent();

  @override
  State<_TrxWingoContent> createState() => _TrxWingoContentState();
}

class _TrxWingoContentState extends State<_TrxWingoContent> {
  void _showResolutionDialog(BuildContext context, TrxWingoResolutionResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final isWin = result.isWon;

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
              gradient: LinearGradient(
                colors: isWin
                    ? [const Color(0xFFFFDF00), const Color(0xFFFFA84C)]
                    : [const Color(0xFF757575), const Color(0xFF424242)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isWin ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  isWin ? 'Congratulations!' : 'Sorry!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isWin ? 'You won the round' : 'Better luck next time',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Period ID:',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  result.periodId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isWin
                      ? '+₹${result.totalPayout.toStringAsFixed(2)}'
                      : '-₹${result.totalBetAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isWin ? const Color(0xFF2CA87E) : const Color(0xFFF15147),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.white,
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
    final viewModel = Provider.of<TrxWingoViewModel>(context);
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
        title: Image.asset(
          'assets/images/logo/Zonex.png',
          height: 28,
          errorBuilder: (context, error, stackTrace) => const Text(
            'Zonex TRX Wingo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildWalletHeader(context, viewModel, state),
            const SizedBox(height: 12),
            _buildPeriodTimerPanel(context, viewModel, state),
            const SizedBox(height: 16),
            _buildLotteryResultsBalls(state),
            const SizedBox(height: 16),
            _buildBetSelectionSection(context, viewModel, state),
            const SizedBox(height: 20),
            _buildHistoryTabs(context, viewModel, state),
            const SizedBox(height: 12),
            _buildHistoryContent(context, viewModel, state),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletHeader(BuildContext context, TrxWingoViewModel viewModel, TrxWingoState state) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF34C43), Color(0xFFF15147)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Color(0xFFF15147), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '₹${state.balance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.grey, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Wallet balance refreshed successfully'),
                            backgroundColor: Color(0xFF2CA87E),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Text('Wallet balance', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF15147),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _showWithdrawDialog(context, viewModel),
                        child: const Text('Withdraw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2CA87E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _showDepositDialog(context, viewModel),
                        child: const Text('Deposit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.volume_up, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'TRX Win Go hashes are verified via public blockchain explorer.',
                    style: TextStyle(color: Colors.white, fontSize: 11, overflow: TextOverflow.ellipsis),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Detail',
                    style: TextStyle(color: Color(0xFFF15147), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildPeriodTimerPanel(BuildContext context, TrxWingoViewModel viewModel, TrxWingoState state) {
    final minutes = (state.timeRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (state.timeRemaining % 60).toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF15147),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Period',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showHowToPlayDialog(context, state.activeTab),
                icon: const Icon(Icons.menu_book, size: 12, color: Color(0xFFF15147)),
                label: const Text('How to play', style: TextStyle(color: Color(0xFFF15147), fontSize: 10)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  side: const BorderSide(color: Color(0xFFF15147)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final url = Uri.parse('https://tronscan.org/');
                  if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    debugPrint('Opened Tronscan');
                  }
                },
                icon: const Icon(Icons.search, size: 12, color: Color(0xFFF15147)),
                label: const Text('Public Chain Query', style: TextStyle(color: Color(0xFFF15147), fontSize: 10)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  side: const BorderSide(color: Color(0xFFF15147)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.periodId,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
              ),
              Row(
                children: [
                  const Text(
                    'Draw time ',
                    style: TextStyle(fontSize: 10, color: Color(0xFF888888), fontWeight: FontWeight.w500),
                  ),
                  _buildTimeDigitBox(minutes[0]),
                  const SizedBox(width: 2),
                  _buildTimeDigitBox(minutes[1]),
                  const Text(
                    ' : ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF15147)),
                  ),
                  _buildTimeDigitBox(seconds[0]),
                  const SizedBox(width: 2),
                  _buildTimeDigitBox(seconds[1]),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDigitBox(String digit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        digit,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF15147)),
      ),
    );
  }

  Widget _buildLotteryResultsBalls(TrxWingoState state) {
    final lastDraw = state.history.isNotEmpty ? state.history.first : null;
    final chars = lastDraw != null ? lastDraw.last5HashChars : ['5', 'B', '4', '8', '5'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          const Text(
            'Latest Hash Result Characters (Last 5)',
            style: TextStyle(fontSize: 11, color: Color(0xFF888888), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: chars.map((char) {
              final isDigit = int.tryParse(char) != null;
              final Color textCol;
              final List<Color> bgCols;
              final BoxBorder? border;

              if (isDigit) {
                final dVal = int.parse(char);
                textCol = Colors.white;
                bgCols = _getColorsForNumber(dVal);
                border = null;
              } else {
                // Hex letter (a-f)
                textCol = const Color(0xFF444444);
                bgCols = [Colors.white];
                border = Border.all(color: const Color(0xFFDDDDDD), width: 1.5);
              }

              return Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: border,
                  gradient: bgCols.length > 1
                      ? LinearGradient(colors: bgCols, begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                  color: bgCols.length == 1 ? bgCols.first : null,
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  char,
                  style: TextStyle(
                    color: textCol,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Color> _getColorsForNumber(int num) {
    if (num == 0) return [const Color(0xFFF15147), const Color(0xFF9E5CFF)];
    if (num == 5) return [const Color(0xFF2CA87E), const Color(0xFF9E5CFF)];
    if (num % 2 == 0) return [const Color(0xFFF15147)];
    return [const Color(0xFF2CA87E)];
  }

  Widget _buildBetSelectionSection(BuildContext context, TrxWingoViewModel viewModel, TrxWingoState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildColorSelectionButton(context, viewModel, 'Green', const Color(0xFF2CA87E))),
              const SizedBox(width: 12),
              Expanded(child: _buildColorSelectionButton(context, viewModel, 'Violet', const Color(0xFF9E5CFF))),
              const SizedBox(width: 12),
              Expanded(child: _buildColorSelectionButton(context, viewModel, 'Red', const Color(0xFFF15147))),
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
              childAspectRatio: 1.0,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildNumberSelectionCircle(context, viewModel, index);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSizeSelectionButton(context, viewModel, 'Big', const Color(0xFFFFA84C))),
              const SizedBox(width: 12),
              Expanded(child: _buildSizeSelectionButton(context, viewModel, 'Small', const Color(0xFF4C8CFF))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelectionButton(BuildContext context, TrxWingoViewModel viewModel, String choice, Color color) {
    return InkWell(
      onTap: () => _showBettingDialog(context, viewModel, choice),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          choice,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNumberSelectionCircle(BuildContext context, TrxWingoViewModel viewModel, int num) {
    final colors = _getColorsForNumber(num);
    return InkWell(
      onTap: () => _showBettingDialog(context, viewModel, num.toString()),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: colors.length > 1
              ? LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          color: colors.length == 1 ? colors.first : null,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          num.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSizeSelectionButton(BuildContext context, TrxWingoViewModel viewModel, String choice, Color color) {
    return InkWell(
      onTap: () => _showBettingDialog(context, viewModel, choice),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          choice,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showBettingDialog(BuildContext context, TrxWingoViewModel viewModel, String choice) {
    final scaffoldContext = context;
    int baseBet = 10;
    int multiplier = viewModel.state.multiplier;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final totalCost = baseBet * multiplier;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Join $choice',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF15147)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Money', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [10, 100, 1000, 10000].map((amt) {
                      final isSelected = baseBet == amt;
                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            baseBet = amt;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF15147) : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '₹$amt',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Multiplier', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (multiplier > 1) {
                                setModalState(() {
                                  multiplier--;
                                });
                              }
                            },
                          ),
                          Text(
                            '${multiplier}X',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setModalState(() {
                                multiplier++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF15147),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            // Instant validation check
                            if (viewModel.state.balance < totalCost) {
                              Navigator.pop(context); // Pop betting sheet instantly
                              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Insufficient balance!'),
                                  backgroundColor: Color(0xFFF15147),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              viewModel.setMultiplier(multiplier);
                              viewModel.placeBet(choice, totalCost);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                SnackBar(
                                  content: Text('Placed bet $choice successfully!'),
                                  backgroundColor: const Color(0xFF2CA87E),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Bet ₹$totalCost',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTabs(BuildContext context, TrxWingoViewModel viewModel, TrxWingoState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHistoryTabButton(viewModel, state, TrxWingoHistoryTab.gameHistory, 'Game history'),
          _buildHistoryTabButton(viewModel, state, TrxWingoHistoryTab.chart, 'Chart'),
          _buildHistoryTabButton(viewModel, state, TrxWingoHistoryTab.myHistory, 'My history'),
        ],
      ),
    );
  }

  Widget _buildHistoryTabButton(
    TrxWingoViewModel viewModel,
    TrxWingoState state,
    TrxWingoHistoryTab tab,
    String label,
  ) {
    final isSelected = state.activeHistoryTab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => viewModel.selectHistoryTab(tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFDF0EF) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? const Color(0xFFF15147) : Colors.transparent),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFF15147) : const Color(0xFF666666),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryContent(BuildContext context, TrxWingoViewModel viewModel, TrxWingoState state) {
    switch (state.activeHistoryTab) {
      case TrxWingoHistoryTab.gameHistory:
        return _buildGameHistoryContent(context, viewModel, state);
      case TrxWingoHistoryTab.chart:
        return _buildChartContent(viewModel, state);
      case TrxWingoHistoryTab.myHistory:
        return _buildMyHistoryContent(viewModel, state);
    }
  }

  Widget _buildGameHistoryContent(BuildContext context, TrxWingoViewModel viewModel, TrxWingoState state) {
    final pageSize = 10;
    final totalItems = state.history.length;
    final maxPage = (totalItems / pageSize).ceil();
    final page = state.gameHistoryPage;

    final paginatedList = state.history.skip((page - 1) * pageSize).take(pageSize).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.0),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(2.0),
              3: FlexColumnWidth(2.0),
              4: FlexColumnWidth(2.0),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF0EF),
                ),
                children: ['Period', 'Block height', 'Block time', 'Hash value', 'Result'].map((col) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      col,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF222222)),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
              ...paginatedList.map((draw) {
                final displayPeriod = draw.periodId.length > 7
                    ? "${draw.periodId.substring(0, 3)}**${draw.periodId.substring(draw.periodId.length - 4)}"
                    : draw.periodId;

                final lastCol = draw.colors;
                final isSplit = lastCol.length > 1;

                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        displayPeriod,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            draw.blockHeight.toString(),
                            style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () async {
                              final url = Uri.parse('https://tronscan.org/block/${draw.blockHeight}/transactions');
                              if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                debugPrint('Opened block detail');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF15147),
                              ),
                              child: const Icon(Icons.help_outline, size: 8, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        draw.blockTime,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        draw.hashValue,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isSplit
                                  ? LinearGradient(colors: lastCol, begin: Alignment.topLeft, end: Alignment.bottomRight)
                                  : null,
                              color: isSplit ? null : lastCol.first,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              draw.resultNumber.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: draw.bigSmall == 'B' ? const Color(0xFFFFA84C) : const Color(0xFF4C8CFF),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              draw.bigSmall,
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: page > 1 ? () => viewModel.setGameHistoryPage(page - 1) : null,
                color: page > 1 ? const Color(0xFFF15147) : Colors.grey,
              ),
              Text('$page / $maxPage', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: page < maxPage ? () => viewModel.setGameHistoryPage(page + 1) : null,
                color: page < maxPage ? const Color(0xFFF15147) : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent(TrxWingoViewModel viewModel, TrxWingoState state) {
    final pageSize = 10;
    final totalItems = state.history.length;
    final maxPage = (totalItems / pageSize).ceil();
    final page = state.chartPage;

    final paginatedList = state.history.skip((page - 1) * pageSize).take(pageSize).toList();

    final missing = viewModel.calculateMissing();
    final avgMissing = viewModel.calculateAvgMissing();
    final frequency = viewModel.calculateFrequency();
    final maxConsecutive = viewModel.calculateMaxConsecutive();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Statistic (last 100 Periods)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333)),
            ),
          ),
          const SizedBox(height: 12),
          _buildStatsRow('Missing', missing),
          _buildStatsRow('Avg missing', avgMissing),
          _buildStatsRow('Frequency', frequency),
          _buildStatsRow('Max consecutive', maxConsecutive),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(7.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFDF0EF)),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Period', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(10, (idx) {
                        return SizedBox(
                          width: 14,
                          child: Text(
                            idx.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF222222)),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: TrxWingoTrendLinePainter(paginatedList: paginatedList),
                ),
              ),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(7.5),
                },
                children: paginatedList.map((draw) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          draw.periodId,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(10, (idx) {
                            final isWinning = draw.resultNumber == idx;
                            return SizedBox(
                              width: 14,
                              child: isWinning
                                  ? Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFF15147),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        idx.toString(),
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : Text(
                                      idx.toString(),
                                      style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 9),
                                      textAlign: TextAlign.center,
                                    ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: page > 1 ? () => viewModel.setChartPage(page - 1) : null,
                color: page > 1 ? const Color(0xFFF15147) : Colors.grey,
              ),
              Text('$page / $maxPage', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: page < maxPage ? () => viewModel.setChartPage(page + 1) : null,
                color: page < maxPage ? const Color(0xFFF15147) : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(String title, List<int> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: values.map((val) {
                return SizedBox(
                  width: 14,
                  child: Text(
                    val.toString(),
                    style: const TextStyle(fontSize: 10, color: Color(0xFF222222)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyHistoryContent(TrxWingoViewModel viewModel, TrxWingoState state) {
    if (state.myBets.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Text('No records found', style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.myBets.length,
        itemBuilder: (context, index) {
          final bet = state.myBets[index];
          final payout = bet.payout;
          final isSucceed = bet.isResolved && bet.isWon;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF15147).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bet.choice,
                            style: const TextStyle(color: Color(0xFFF15147), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bet.periodId,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${bet.timestamp.hour.toString().padLeft(2, '0')}:${bet.timestamp.minute.toString().padLeft(2, '0')}:${bet.timestamp.second.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: bet.isResolved
                              ? (isSucceed ? const Color(0xFF2CA87E) : const Color(0xFFF15147))
                              : Colors.orange,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bet.isResolved ? (isSucceed ? 'Succeed' : 'Failed') : 'Waiting',
                        style: TextStyle(
                          color: bet.isResolved
                              ? (isSucceed ? const Color(0xFF2CA87E) : const Color(0xFFF15147))
                              : Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bet.isResolved
                          ? (isSucceed ? '+₹${payout.toStringAsFixed(2)}' : '-₹${bet.amount.toStringAsFixed(2)}')
                          : '₹${bet.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: bet.isResolved
                            ? (isSucceed ? const Color(0xFF2CA87E) : const Color(0xFFF15147))
                            : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, TrxWingoViewModel viewModel) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Withdraw Funds', style: TextStyle(color: Color(0xFFF15147))),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (₹)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final amt = double.tryParse(controller.text);
                if (amt != null && amt > 0) {
                  final success = viewModel.withdraw(amt);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Withdrew ₹$amt successfully!' : 'Insufficient balance!'),
                      backgroundColor: success ? const Color(0xFF2CA87E) : const Color(0xFFF15147),
                    ),
                  );
                }
              },
              child: const Text('Withdraw', style: TextStyle(color: Color(0xFFF15147), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDepositDialog(BuildContext context, TrxWingoViewModel viewModel) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deposit Funds', style: TextStyle(color: Color(0xFF2CA87E))),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount (₹)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final amt = double.tryParse(controller.text);
                if (amt != null && amt > 0) {
                  viewModel.deposit(amt);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deposited ₹$amt successfully!'),
                      backgroundColor: const Color(0xFF2CA87E),
                    ),
                  );
                }
              },
              child: const Text('Deposit', style: TextStyle(color: Color(0xFF2CA87E), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showHowToPlayDialog(BuildContext context, TrxWingoTabType activeTab) {
    String tabTitle = 'TRXwingo 1Min';
    String intro = '1 minutes 1 game, within 55 second need to place bet, before 5 second unable to place bet';
    if (activeTab == TrxWingoTabType.seconds30) {
      tabTitle = 'TRXwingo 30Sec';
      intro = '30 seconds 1 game, within 25 second need to place bet, before 5 second unable to place bet';
    } else if (activeTab == TrxWingoTabType.minute3) {
      tabTitle = 'TRXwingo 3Min';
      intro = '3 minutes 1 game, within 2 minute and 55 second need to place bet, before 5 second unable to place bet';
    } else if (activeTab == TrxWingoTabType.minute5) {
      tabTitle = 'TRXwingo 5Min';
      intro = '5 minutes 1 game, within 4 minute and 55 second need to place bet, before 5 second unable to place bet';
    }

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
                        'What is a hash value?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'A person of Bitcoin\'s fundamental value is exposed to one knowledge, one hash value.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hash is a value algorithm calculated with a hash function (or hash function/hash), and we can also translate it into a hash, so the hash value is also called a hash value. . To understand hash values, you must understand hash functions. A hash function can computationally transform an input of arbitrary length into an output of fixed length.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Functions all have the property that if the input value is the same, the output hash value is the same. If the input value is different, the output hash value is usually different, but if the event is extremely small. If the hash value is solved when the input value changes, the hash function has a hash value that is non-reversible and easy to verify, and if there is indeed a derived value, if it is possible to achieve the hash value of the output input value, you can Hash value for immediate verification.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The value of each block is unique, eternal and unrevealable, undeniable at the time, the awards circulating in the blockchain are automatically tampered with, and the records cannot be tampered with.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'USDT have how many type?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1) Based on Bitcoin platform Omni-USDT, deposit address is Bitcoin address, withdrawal is bitcoin network.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '2) Bases on Ethereum platform ERC20 protocol, deposit address is based on ETH address, withdrawal also based on ETH network.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '3) Based on TRC20-USDT, TRC20 protocal and TRX Network, deposit address using TRON address, withdrawal using TRON network.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Trx WinGo is based on TRC20 Protocal and TRX network (TRC20-USDT) Block hash last 1 digit to giving the result, (Can click the Block Height to check the Block Hash)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF444444), height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'How To Play:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1) $intro',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '2) After the betting close, latest has value will be the result',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '3) Bet for whole day, One day total bet is 1440 time.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '4) If you bet of 100, will deduct 2 fee, so your betting amount will be 98',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '5) 3 minute 1 time, 5 minute 1 time, 10 minute 1 time rule same as the 1 minute 1 time, except open result time not same.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '6) Block hash last digit will be the result:',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Example:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF555555))),
                            Text('Hash Value **b569, result will be 9', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
                            Text('Hash Value **d14c, result will be 4 (numeric character)', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildHowToPlaySection('When you bet on Green:', 'If the result either 1,3,7,9, you will get (98*2)=196, if the result is 5, you will get (98*1.5)=147'),
                      _buildHowToPlaySection('When you bet on Red:', 'If the result either 2,4,6,8, you will get (98*2)=196, if the result is 0, you will get (98*1.5)=147'),
                      _buildHowToPlaySection('When you bet on Purple/Violet:', 'If the result either 0 or 5, you will get (98*4.5)=441'),
                      _buildHowToPlaySection('When you bet on Number bet:', 'When the result is same as your bet, you will get (98*9)882'),
                      _buildHowToPlaySection('When you bet on Big:', 'When the result showing either 5,6,7,8,9, you will get (98*2)=196'),
                      _buildHowToPlaySection('When you bet on Small:', 'When the result showing either 0,1,2,3,4, you will get (98*2)=196'),
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

  Widget _buildHowToPlaySection(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF444444)),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF666666), height: 1.4),
          ),
        ],
      ),
    );
  }
}

class TrxWingoTrendLinePainter extends CustomPainter {
  final List<TrxDrawResult> paginatedList;

  const TrxWingoTrendLinePainter({required this.paginatedList});

  @override
  void paint(Canvas canvas, Size size) {
    if (paginatedList.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFF15147)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final cellWidth = (size.width * 0.75) / 10;
    final startX = size.width * 0.25;

    final points = <Offset>[];

    for (int i = 0; i < paginatedList.length; i++) {
      final draw = paginatedList[i];
      final winningDigit = draw.resultNumber;
      
      final y = 10.0 + (i * 35.0) + 7.0; // matching row vertical spacing (padding + half diameter)
      final x = startX + (winningDigit * cellWidth) + (cellWidth / 2);
      points.add(Offset(x, y));
    }

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant TrxWingoTrendLinePainter oldDelegate) {
    return oldDelegate.paginatedList != paginatedList;
  }
}
