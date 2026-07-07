import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BetHistoryView extends StatefulWidget {
  const BetHistoryView({super.key});

  @override
  State<BetHistoryView> createState() => _BetHistoryViewState();
}

class _BetHistoryViewState extends State<BetHistoryView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String userId = ApiService().currentUserId ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bet History',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF34C43),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFF34C43),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Wingo'),
            Tab(text: 'K3'),
            Tab(text: '5D'),
            Tab(text: 'Aviator'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStandardGameHistoryList(userId, 'wingo'),
          _buildStandardGameHistoryList(userId, 'k3'),
          _buildStandardGameHistoryList(userId, '5d'),
          _buildAviatorHistoryList(userId),
        ],
      ),
    );
  }

  Widget _buildStandardGameHistoryList(String userId, String gameType) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService().getMyHistory(userId, gameType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFF34C43))));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No bets placed yet.');
        }

        final bets = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bets.length,
          itemBuilder: (context, index) {
            final bet = bets[index];
            final String status = (bet['status'] ?? 'pending').toString().toLowerCase();
            final double amount = double.tryParse(bet['amount'].toString()) ?? 0.0;
            final double winAmount = double.tryParse(bet['win_amount']?.toString() ?? '0.0') ?? 0.0;
            final String createdAt = bet['created_at']?.toString() ?? '';
            final String displayDate = createdAt.length > 19 ? createdAt.substring(0, 19).replaceFirst('T', ' ') : createdAt;

            Color statusColor = Colors.orange;
            String statusText = 'Pending';
            String amountPrefix = '';

            if (status == 'won') {
              statusColor = Colors.green;
              statusText = 'Won';
              amountPrefix = '+₹${winAmount.toStringAsFixed(2)}';
            } else if (status == 'lost') {
              statusColor = Colors.grey.shade600;
              statusText = 'Lost';
              amountPrefix = '-₹${amount.toStringAsFixed(2)}';
            } else {
              amountPrefix = '₹${amount.toStringAsFixed(2)}';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Period: ${bet['period_name'] ?? 'N/A'}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select option', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            (bet['bet_value'] ?? 'N/A').toString().toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Bet Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '₹${amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Payout', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            amountPrefix,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: status == 'won' ? Colors.green : (status == 'lost' ? Colors.grey : Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F3F9)),
                  const SizedBox(height: 10),
                  Text(
                    displayDate,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAviatorHistoryList(String userId) {
    return FutureBuilder<List<dynamic>?>(
      future: ApiService().getAviatorHistory(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFF34C43))));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No Aviator bets placed yet.');
        }

        final bets = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bets.length,
          itemBuilder: (context, index) {
            final bet = bets[index];
            final double betAmount = double.tryParse(bet['bet_amount']?.toString() ?? '0.0') ?? 0.0;
            final double cashoutMultiplier = double.tryParse(bet['cashout_multiplier']?.toString() ?? '0.0') ?? 0.0;
            final double winAmount = double.tryParse(bet['win_amount']?.toString() ?? '0.0') ?? 0.0;
            final String status = (bet['status'] ?? 'lost').toString().toLowerCase();
            final String createdAt = bet['created_at']?.toString() ?? '';
            final String displayDate = createdAt.length > 19 ? createdAt.substring(0, 19).replaceFirst('T', ' ') : createdAt;

            Color statusColor = status == 'won' ? Colors.green : Colors.grey.shade600;
            String statusText = status == 'won' ? 'Won' : 'Lost';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.flight_takeoff, color: Color(0xFFF34C43), size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Aviator Crash',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bet Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '₹${betAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Multiplier', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            status == 'won' ? '${cashoutMultiplier.toStringAsFixed(2)}x' : '0.00x',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Payout', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            status == 'won' ? '+₹${winAmount.toStringAsFixed(2)}' : '-₹${betAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: status == 'won' ? Colors.green : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F3F9)),
                  const SizedBox(height: 10),
                  Text(
                    displayDate,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
