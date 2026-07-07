import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/wallet_service.dart';

class AviatorView extends StatefulWidget {
  const AviatorView({super.key});

  @override
  State<AviatorView> createState() => _AviatorViewState();
}

enum AviatorState { betting, flying, crashed }

class AviatorBet {
  String? id;
  double amount;
  bool isPlaced;
  bool isCashedOut;
  double cashoutMultiplier;
  double payout;

  AviatorBet({
    required this.amount,
    this.id,
    this.isPlaced = false,
    this.isCashedOut = false,
    this.cashoutMultiplier = 1.0,
    this.payout = 0.0,
  });
}

class SimulatedPlayer {
  final String name;
  final double betAmount;
  final double cashoutMultiplier;
  final bool willCashout;
  bool hasCashedOut;

  SimulatedPlayer({
    required this.name,
    required this.betAmount,
    required this.cashoutMultiplier,
    required this.willCashout,
    this.hasCashedOut = false,
  });
}

class _AviatorViewState extends State<AviatorView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AviatorState _gameState = AviatorState.betting;
  double _countdownSeconds = 6.0;
  double _currentMultiplier = 1.00;
  double _animationProgress = 0.0;
  double _crashMultiplier = 1.00;

  Timer? _countdownTimer;
  Timer? _gameLoopTimer;

  // Settings Toggles
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _isAnimationEnabled = true;

  // History Multipliers Pills
  final List<double> _roundHistory = [
    1.97, 1.74, 5.13, 1.19, 2.64, 34.25, 2.45, 2.46, 1.23, 1.77, 2.93, 1.11,
    4.19, 1.06, 1.42, 1.30, 2.54, 1.84, 1.22, 1.12, 5.24, 1.41, 1.11, 1.43,
  ];

  // Two independent betting panels
  final AviatorBet _bet1 = AviatorBet(amount: 10.0);
  final AviatorBet _bet2 = AviatorBet(amount: 10.0);

  // Simulated active players
  final List<SimulatedPlayer> _simulatedPlayers = [];
  final List<String> _userAvatars = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80',
    'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100&q=80',
    'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80',
  ];

  int _selectedTab = 0; // 0 = All Bets, 1 = My Bets, 2 = Top
  List<dynamic> _myBetHistory = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _startBettingPhase();
    _loadMyHistory();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _gameLoopTimer?.cancel();
    super.dispose();
  }

  // Fetch from Node.js
  Future<void> _loadMyHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    final history = await ApiService().getAviatorHistory(ApiService().currentUserId!);
    if (history != null) {
      setState(() {
        _myBetHistory = history;
      });
    }
    setState(() {
      _isLoadingHistory = false;
    });
  }

  // State loop: 1. Betting Countdown
  void _startBettingPhase() {
    setState(() {
      _gameState = AviatorState.betting;
      _countdownSeconds = 6.0;
      _currentMultiplier = 1.00;
      _animationProgress = 0.0;
      
      // Reset bets if settled
      if (_bet1.isCashedOut || _gameState == AviatorState.betting) {
        _bet1.isPlaced = false;
        _bet1.isCashedOut = false;
        _bet1.id = null;
      }
      if (_bet2.isCashedOut || _gameState == AviatorState.betting) {
        _bet2.isPlaced = false;
        _bet2.isCashedOut = false;
        _bet2.id = null;
      }

      // Generate simulated users for this round
      _generateSimulatedPlayers();
    });

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_countdownSeconds > 0.1) {
          _countdownSeconds -= 0.1;
        } else {
          _countdownTimer?.cancel();
          _startFlyingPhase();
        }
      });
    });
  }

  // State loop: 2. Flying Bezier curve
  void _startFlyingPhase() {
    // Generate crash multiplier
    final rand = math.Random().nextDouble();
    if (rand < 0.1) {
      _crashMultiplier = 1.00 + math.Random().nextDouble() * 0.1; // Instant crash (1.00x - 1.10x)
    } else if (rand < 0.5) {
      _crashMultiplier = 1.10 + math.Random().nextDouble() * 0.9; // Low crash (1.10x - 2.00x)
    } else if (rand < 0.85) {
      _crashMultiplier = 2.00 + math.Random().nextDouble() * 5.0; // Medium crash (2.00x - 7.00x)
    } else {
      _crashMultiplier = 7.00 + math.Random().nextDouble() * 25.0; // High crash (7.00x - 32.00x)
    }

    setState(() {
      _gameState = AviatorState.flying;
      _currentMultiplier = 1.00;
      _animationProgress = 0.0;
    });

    int ticks = 0;
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      ticks++;
      setState(() {
        // Multiplier climbs exponentially
        _currentMultiplier = math.pow(1.045, ticks / 2.0) as double;
        if (_currentMultiplier < 1.0) _currentMultiplier = 1.0;

        // Scale animation progress towards 1.0
        _animationProgress = (_currentMultiplier - 1.0) / (_crashMultiplier - 1.0 + 0.5);
        if (_animationProgress > 1.0) _animationProgress = 1.0;

        // Simulated players cash out dynamically
        for (var player in _simulatedPlayers) {
          if (player.willCashout && !player.hasCashedOut && _currentMultiplier >= player.cashoutMultiplier) {
            player.hasCashedOut = true;
          }
        }

        // Check if crash limit reached
        if (_currentMultiplier >= _crashMultiplier) {
          _currentMultiplier = _crashMultiplier; // Lock at crash value
          _gameLoopTimer?.cancel();
          _triggerCrash();
        }
      });
    });
  }

  // State loop: 3. Flew Away / Crashed
  void _triggerCrash() {
    setState(() {
      _gameState = AviatorState.crashed;
    });

    // Update historical pills list
    setState(() {
      _roundHistory.insert(0, double.parse(_crashMultiplier.toStringAsFixed(2)));
      if (_roundHistory.length > 25) _roundHistory.removeLast();
    });

    // Process loss on backend for any bets that did not cash out
    if (_bet1.isPlaced && !_bet1.isCashedOut && _bet1.id != null) {
      ApiService().loseAviatorBet(_bet1.id!);
    }
    if (_bet2.isPlaced && !_bet2.isCashedOut && _bet2.id != null) {
      ApiService().loseAviatorBet(_bet2.id!);
    }

    // Keep crashed message on screen for 3 seconds, then start next betting round
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _loadMyHistory();
        _startBettingPhase();
      }
    });
  }

  void _generateSimulatedPlayers() {
    _simulatedPlayers.clear();
    final names = ['Rohan', 'Amit', 'Sunil', 'Preeti', 'Karan', 'Sneha', 'Vikram', 'Divya', 'Rahul', 'Neha'];
    final r = math.Random();
    for (var name in names) {
      final willCashout = r.nextBool();
      final cashMultiplier = 1.1 + r.nextDouble() * 4.0;
      final bet = (r.nextInt(10) + 1) * 100.0;
      _simulatedPlayers.add(SimulatedPlayer(
        name: '${name.substring(0, 1)}***${r.nextInt(9)}',
        betAmount: bet,
        cashoutMultiplier: double.parse(cashMultiplier.toStringAsFixed(2)),
        willCashout: willCashout,
      ));
    }
  }

  // User Actions: Place Bet
  Future<void> _placeBet(AviatorBet bet) async {
    if (bet.isPlaced) return;

    if (bet.amount > WalletService().balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient Wallet Balance!'), backgroundColor: Colors.red),
      );
      return;
    }

    // Call Backend
    final result = await ApiService().placeAviatorBet(
      ApiService().currentUserId!,
      bet.amount,
    );

    if (result != null) {
      await WalletService().syncBalance();
      setState(() {
        bet.id = result['id'];
        bet.isPlaced = true;
        bet.isCashedOut = false;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place bet. Try again.'), backgroundColor: Colors.red),
      );
    }
  }

  // User Actions: Cashout
  Future<void> _cashoutBet(AviatorBet bet) async {
    if (!bet.isPlaced || bet.isCashedOut || bet.id == null) return;

    final multiplier = double.parse(_currentMultiplier.toStringAsFixed(2));
    final result = await ApiService().cashoutAviatorBet(bet.id!, multiplier);

    if (result != null) {
      await WalletService().syncBalance();
      setState(() {
        bet.isCashedOut = true;
        bet.cashoutMultiplier = multiplier;
        bet.payout = bet.amount * multiplier;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cashed Out successfully! Won ₹${bet.payout.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to Cash Out. Try again.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF101115), // Dark Aviator theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF16171E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text(
              'Aviator',
              style: TextStyle(color: Color(0xFFF34C43), fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // Show simple Rules Info Dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1C1E26),
                    title: const Text('Game Rules', style: TextStyle(color: Colors.white)),
                    content: const Text(
                      'Aviator is a new generation of iGaming entertainment. Place your bet, watch the multiplier rise from 1.0x, and Cash Out before the plane flies away to win!',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close', style: TextStyle(color: Color(0xFFF34C43))),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(Icons.help_outline, color: Colors.grey, size: 18),
            ),
          ],
        ),
        actions: [
          // Balance Capsule
          ListenableBuilder(
            listenable: WalletService(),
            builder: (context, _) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A382B),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF2CA87E), width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  '₹${WalletService().balance.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFF2CA87E), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: const Color(0xFF16171E),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1C1E27)),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80'),
              ),
              accountName: const Text('User Account', style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text('ID: ${ApiService().currentUserId!.substring(0, 8)}...'),
            ),
            SwitchListTile(
              title: const Text('Sound Effects', style: TextStyle(color: Colors.white, fontSize: 14)),
              value: _isSoundEnabled,
              activeColor: const Color(0xFFF34C43),
              onChanged: (val) => setState(() => _isSoundEnabled = val),
            ),
            SwitchListTile(
              title: const Text('Music Background', style: TextStyle(color: Colors.white, fontSize: 14)),
              value: _isMusicEnabled,
              activeColor: const Color(0xFFF34C43),
              onChanged: (val) => setState(() => _isMusicEnabled = val),
            ),
            SwitchListTile(
              title: const Text('Plane Animation', style: TextStyle(color: Colors.white, fontSize: 14)),
              value: _isAnimationEnabled,
              activeColor: const Color(0xFFF34C43),
              onChanged: (val) => setState(() => _isAnimationEnabled = val),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: const Text('My Bet History', style: TextStyle(color: Colors.white, fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedTab = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.rule, color: Colors.grey),
              title: const Text('Game Limits', style: TextStyle(color: Colors.white, fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1C1E26),
                    title: const Text('Limits', style: TextStyle(color: Colors.white)),
                    content: const Text(
                      'Min Bet: ₹10.00\nMax Bet: ₹10,000.00\nMax Multiplier: 1000.00x',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Historic Multiplier Pills Horizontal List
            Container(
              height: 38,
              color: const Color(0xFF16171E),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _roundHistory.length,
                itemBuilder: (context, index) {
                  final mult = _roundHistory[index];
                  Color pillColor = Colors.grey.shade800;
                  Color textColor = Colors.grey.shade300;
                  if (mult >= 10.0) {
                    pillColor = Colors.purple.shade900.withOpacity(0.5);
                    textColor = Colors.purpleAccent;
                  } else if (mult >= 2.0) {
                    pillColor = Colors.blue.shade900.withOpacity(0.5);
                    textColor = Colors.blueAccent;
                  }
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pillColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${mult.toStringAsFixed(2)}x',
                      style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),

            // 2. Main Game Animation Board
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E212E), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Canvas painting
                      Positioned.fill(
                        child: CustomPaint(
                          painter: AviatorPainter(
                            progress: _animationProgress,
                            currentMultiplier: _currentMultiplier,
                            isCrashed: _gameState == AviatorState.crashed,
                          ),
                        ),
                      ),

                      // Countdown State Overlay
                      if (_gameState == AviatorState.betting)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(color: Color(0xFFF34C43), strokeWidth: 3),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'WAITING FOR NEXT ROUND',
                                style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'STARTING IN ${_countdownSeconds.toStringAsFixed(1)}s',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                      // Flying State Overlay
                      if (_gameState == AviatorState.flying)
                        Center(
                          child: Text(
                            '${_currentMultiplier.toStringAsFixed(2)}x',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))],
                            ),
                          ),
                        ),

                      // Crashed State Overlay
                      if (_gameState == AviatorState.crashed)
                        Container(
                          color: Colors.red.withOpacity(0.15),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'FLEW AWAY',
                                  style: TextStyle(color: Color(0xFFF34C43), fontSize: 26, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'at ${_crashMultiplier.toStringAsFixed(2)}x',
                                  style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Double Betting Controls
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      _buildBettingPanel(_bet1),
                      const SizedBox(height: 10),
                      _buildBettingPanel(_bet2),
                      const SizedBox(height: 16),

                      // 4. Tab selection: All Bets / My Bets / Top
                      _buildTabsContainer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBettingPanel(AviatorBet bet) {
    final bool canPlaceBet = _gameState == AviatorState.betting;
    final bool canCashout = _gameState == AviatorState.flying && bet.isPlaced && !bet.isCashedOut;

    Color btnColor = const Color(0xFF2CA87E); // Green
    String btnText = 'BET\n${bet.amount.toStringAsFixed(0)}.00 INR';
    if (bet.isPlaced && !bet.isCashedOut) {
      if (_gameState == AviatorState.betting) {
        btnColor = const Color(0xFFBC342D);
        btnText = 'CANCEL';
      } else if (_gameState == AviatorState.flying) {
        btnColor = const Color(0xFFE67E22); // Orange Cashout
        final livePayout = bet.amount * _currentMultiplier;
        btnText = 'CASH OUT\n₹${livePayout.toStringAsFixed(2)}';
      }
    } else if (bet.isCashedOut) {
      btnColor = Colors.grey.shade800;
      btnText = 'CASHED OUT\n₹${bet.payout.toStringAsFixed(2)}';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16171E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F222F), width: 1),
      ),
      child: Row(
        children: [
          // Amount Controls Left
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!bet.isPlaced && bet.amount > 10) {
                          setState(() => bet.amount -= 10);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: const Color(0xFF20222B), shape: BoxShape.circle),
                        child: const Icon(Icons.remove, color: Colors.grey, size: 14),
                      ),
                    ),
                    Text(
                      '${bet.amount.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!bet.isPlaced) {
                          setState(() => bet.amount += 10);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: const Color(0xFF20222B), shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.grey, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [10.0, 100.0, 500.0, 1000.0].map((val) {
                    return GestureDetector(
                      onTap: () {
                        if (!bet.isPlaced) {
                          setState(() => bet.amount = val);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF20222B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${val.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Big Bet Action Button Right
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  if (canCashout) {
                    _cashoutBet(bet);
                  } else if (canPlaceBet) {
                    if (bet.isPlaced) {
                      setState(() {
                        bet.isPlaced = false;
                        bet.id = null;
                      });
                    } else {
                      _placeBet(bet);
                    }
                  }
                },
                child: Text(
                  btnText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsContainer() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16171E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildTabHeader(0, 'All Bets'),
              _buildTabHeader(1, 'My Bets'),
              _buildTabHeader(2, 'Top'),
            ],
          ),
          const Divider(height: 1, color: Colors.grey),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildTabHeader(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
          if (index == 1) {
            _loadMyHistory();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFF34C43) : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 0) {
      // 1. All Bets simulated users
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _simulatedPlayers.length,
        itemBuilder: (context, index) {
          final p = _simulatedPlayers[index];
          final payout = p.betAmount * p.cashoutMultiplier;
          return Container(
            color: p.hasCashedOut ? const Color(0xFF1A382B).withOpacity(0.2) : Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(_userAvatars[index % _userAvatars.length]),
                    ),
                    const SizedBox(width: 8),
                    Text(p.name, style: const TextStyle(color: Colors.grey, fontSize: 12.5)),
                  ],
                ),
                Text('₹${p.betAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                p.hasCashedOut
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF2CA87E).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          '${p.cashoutMultiplier}x',
                          style: const TextStyle(color: Color(0xFF2CA87E), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      )
                    : const Text('-', style: TextStyle(color: Colors.grey)),
                p.hasCashedOut
                    ? Text('₹${payout.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF2CA87E), fontSize: 12, fontWeight: FontWeight.bold))
                    : const Text('-', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      );
    } else if (_selectedTab == 1) {
      // 2. My Bets from DB
      if (_isLoadingHistory) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(color: Color(0xFFF34C43))),
        );
      }
      if (_myBetHistory.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No bets found', style: TextStyle(color: Colors.grey))),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _myBetHistory.length,
        itemBuilder: (context, index) {
          final bet = _myBetHistory[index];
          final amount = double.tryParse(bet['amount'].toString()) ?? 0.0;
          final status = bet['status'] ?? 'pending';
          final mult = double.tryParse(bet['multiplier'].toString()) ?? 0.0;
          final payout = double.tryParse(bet['payout'].toString()) ?? 0.0;
          
          final isWon = status == 'won';
          final isLost = status == 'lost';

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade900, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bet: ₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bet['timestamp'] != null
                          ? bet['timestamp'].toString().split('T')[0]
                          : '',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                if (isWon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF2CA87E).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      '${mult.toStringAsFixed(2)}x',
                      style: const TextStyle(color: Color(0xFF2CA87E), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Text(status.toUpperCase(), style: TextStyle(color: isLost ? Colors.red : Colors.orange, fontSize: 11)),
                
                Text(
                  isWon ? '+₹${payout.toStringAsFixed(2)}' : '-₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isWon ? const Color(0xFF2CA87E) : Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // 3. Top leaderboards
      final items = [
        {'name': 'u***1', 'bet': 5800.0, 'mult': 83.33, 'win': 483310.0},
        {'name': 'u***4', 'bet': 4000.0, 'mult': 64.93, 'win': 259720.0},
        {'name': 'u***9', 'bet': 1200.0, 'mult': 123.40, 'win': 148080.0},
        {'name': 'u***0', 'bet': 8000.0, 'mult': 15.55, 'win': 124400.0},
        {'name': 'u***2', 'bet': 500.0, 'mult': 210.15, 'win': 105075.0},
      ];
      return Column(
        children: items.map<Widget>((it) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade900, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(it['name'] as String, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text('₹${(it['bet'] as double).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.purple.shade900.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    '${it['mult']}x',
                    style: const TextStyle(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '₹${(it['win'] as double).toStringAsFixed(0)}',
                  style: const TextStyle(color: Color(0xFF2CA87E), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
  }
}

class AviatorPainter extends CustomPainter {
  final double progress;
  final double currentMultiplier;
  final bool isCrashed;

  AviatorPainter({
    required this.progress,
    required this.currentMultiplier,
    required this.isCrashed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background grid lines
    final paintGrid = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;
    
    final gridCount = 10;
    for (int i = 1; i < gridCount; i++) {
      double x = size.width / gridCount * i;
      double y = size.height / gridCount * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintGrid);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    if (isCrashed) return; // Don't draw the trail if crashed

    // Quadratic path math
    final Path path = Path();
    final double startX = 30.0;
    final double startY = size.height - 30.0;
    
    final double endX = startX + (size.width - startX - 50.0) * progress;
    final double endY = startY - (startY - 50.0) * (progress * progress); // Quadratic curve acceleration

    path.moveTo(startX, startY);
    path.quadraticBezierTo(
      startX + (endX - startX) * 0.5,
      startY, // Smooth curve control point
      endX,
      endY,
    );

    // Glowing red line path
    final paintLine = Paint()
      ..color = const Color(0xFFF34C43)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    
    canvas.drawPath(path, paintLine);

    // Red shader background fill
    final Path fillPath = Path()
      ..moveTo(startX, startY)
      ..quadraticBezierTo(startX + (endX - startX) * 0.5, startY, endX, endY)
      ..lineTo(endX, startY)
      ..close();
    
    final paintFill = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFF34C43).withOpacity(0.18),
          const Color(0xFFF34C43).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(startX, endY, endX, startY));
    
    canvas.drawPath(fillPath, paintFill);

    // Draw little flying red plane at the end tip
    final paintPlane = Paint()
      ..color = const Color(0xFFF34C43)
      ..style = PaintingStyle.fill;
    
    canvas.save();
    canvas.translate(endX, endY);
    // Rotate upwards during ascent
    canvas.rotate(-0.55 * progress); 

    // Render simple airplane vector shape
    final Path planePath = Path();
    planePath.moveTo(-16, -4);
    planePath.lineTo(16, -2);
    planePath.lineTo(20, 0);
    planePath.lineTo(16, 2);
    planePath.lineTo(-16, 4);

    // Wings
    planePath.moveTo(0, -3);
    planePath.lineTo(4, -16);
    planePath.lineTo(9, -16);
    planePath.lineTo(6, -3);
    planePath.moveTo(0, 3);
    planePath.lineTo(4, 16);
    planePath.lineTo(9, 16);
    planePath.lineTo(6, 3);

    // Tail
    planePath.moveTo(-13, -2);
    planePath.lineTo(-11, -7);
    planePath.lineTo(-8, -7);
    planePath.lineTo(-9, -2);
    planePath.moveTo(-13, 2);
    planePath.lineTo(-11, 7);
    planePath.lineTo(-8, 7);
    planePath.lineTo(-9, 2);

    canvas.drawPath(planePath, paintPlane);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AviatorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.currentMultiplier != currentMultiplier ||
        oldDelegate.isCrashed != isCrashed;
  }
}
