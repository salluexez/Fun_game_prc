import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/wallet_service.dart';

String _formatDateTime(DateTime dt) {
  final year = dt.year;
  final month = dt.month.toString().padLeft(2, '0');
  final day = dt.day.toString().padLeft(2, '0');
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  final second = dt.second.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute:$second';
}

class DepositView extends StatefulWidget {
  const DepositView({super.key});

  @override
  State<DepositView> createState() => _DepositViewState();
}

class _DepositViewState extends State<DepositView> {
  final _amountController = TextEditingController();
  final _utrController = TextEditingController();

  String _selectedChannel = 'Phonepe_QR';
  double? _selectedAmount;
  bool _isSubmitting = false;
  bool _isRefreshing = false;

  final List<double> _quickAmounts = [500, 1000, 2000, 5000, 10000, 20000, 50000];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      final text = _amountController.text;
      if (text.isEmpty) {
        setState(() {
          _selectedAmount = null;
        });
      } else {
        final val = double.tryParse(text);
        setState(() {
          _selectedAmount = val;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _refreshBalance() async {
    setState(() {
      _isRefreshing = true;
    });
    await WalletService().syncBalance();
    setState(() {
      _isRefreshing = false;
    });
  }

  void _selectQuickAmount(double amt) {
    setState(() {
      _selectedAmount = amt;
      _amountController.text = amt.toStringAsFixed(0);
    });
  }

  void _showPaymentModal(double amount) async {
    setState(() {
      _isSubmitting = true;
    });

    // Fetch Admin QR Code URL
    final qrUrl = await ApiService().getQrUrl();

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scan & Pay',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Amount to Pay: ₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF34C43)),
                    ),
                    const SizedBox(height: 16),
                    // Display Offline QR Code
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          qrUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.qr_code, size: 80, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Scan this QR code using PhonePe, Paytm or UPI App',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter UTR / Transaction ID',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _utrController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter 12-digit UPI UTR number',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  fillColor: const Color(0xFFF5F5F5),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF34C43),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () async {
                    final utr = _utrController.text.trim();
                    if (utr.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid Transaction Ref/UTR number')),
                      );
                      return;
                    }
                    Navigator.pop(context); // Close sheet
                    
                    setState(() {
                      _isSubmitting = true;
                    });
                    
                    final success = await ApiService().deposit(
                      ApiService().currentUserId!,
                      amount,
                      utr, // Using UTR reference as the receipt identifier
                    );
                    
                    setState(() {
                      _isSubmitting = false;
                      _utrController.clear();
                    });

                    if (success) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Deposit request submitted! Pending Admin Approval.'),
                          backgroundColor: Color(0xFF2CA87E),
                        ),
                      );
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Submission failed. Please try again.'),
                          backgroundColor: Color(0xFFF15147),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Submit Order',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleDeposit() {
    final amt = _selectedAmount;
    if (amt == null || amt < 500 || amt > 50000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount between ₹500.00 and ₹50,000.00'),
          backgroundColor: Color(0xFFF15147),
        ),
      );
      return;
    }
    _showPaymentModal(amt);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAmount = _selectedAmount != null && _selectedAmount! > 0;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF333333), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Deposit',
          style: TextStyle(color: Color(0xFF222222), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DepositHistoryPage()),
              );
            },
            child: const Text(
              'Deposit history',
              style: TextStyle(color: Color(0xFF666666), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Balance Card
                ListenableBuilder(
                  listenable: WalletService(),
                  builder: (context, _) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF7726A), Color(0xFFF34C43)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF34C43).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.stars, color: Colors.white70, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Balance',
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '₹${WalletService().balance.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 12),
                              _isRefreshing
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : GestureDetector(
                                      onTap: _refreshBalance,
                                      child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                                    ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '**** ****',
                              style: TextStyle(color: Colors.white38, letterSpacing: 3, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),



                // 4. Deposit Amount
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: const Color(0xFFF34C43), size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Deposit amount',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Amount Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: _quickAmounts.length,
                        itemBuilder: (context, index) {
                          final amt = _quickAmounts[index];
                          final isSelected = _selectedAmount == amt;
                          
                          // Format display text (e.g. 1000 -> 1K)
                          String label = amt.toStringAsFixed(0);
                          if (amt == 1000) label = '1K';
                          if (amt == 1500) label = '1.5K';
                          if (amt == 2000) label = '2K';
                          if (amt == 3000) label = '3K';

                          return OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isSelected ? const Color(0xFFF34C43).withOpacity(0.05) : Colors.transparent,
                              side: BorderSide(
                                color: isSelected ? const Color(0xFFF34C43) : Colors.grey.shade200,
                                width: isSelected ? 1.5 : 1,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => _selectQuickAmount(amt),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '₹  ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? const Color(0xFFF34C43) : Colors.grey,
                                  ),
                                ),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? const Color(0xFFF34C43) : const Color(0xFF444444),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Custom Input Field
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              '₹',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF34C43)),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          hintText: '500.00 - 50,000.00',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal),
                          fillColor: const Color(0xFFF8F9FB),
                          filled: true,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.grey, size: 18),
                            onPressed: () {
                              _amountController.clear();
                              setState(() {
                                _selectedAmount = null;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 5. Recharge Instructions
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.menu_book, color: const Color(0xFFF34C43), size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Recharge instructions',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildInstructionItem('If the transfer time is up, please fill out the deposit form again.'),
                      _buildInstructionItem('The transfer amount must match the order you created, otherwise the money cannot be credited successfully.'),
                      _buildInstructionItem('If you transfer the wrong amount, our company will not be responsible for the lost amount!'),
                      _buildInstructionItem('Note: do not cancel the deposit order after the money has been transferred.'),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Spacing for bottom floating bar
              ],
            ),
          ),

          // 6. Loading Indicator Overlay
          if (_isSubmitting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFF34C43)),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recharge Method:',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedChannel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF222222)),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasAmount ? const Color(0xFFF34C43) : const Color(0xFFE4E4E6),
                foregroundColor: hasAmount ? Colors.white : const Color(0xFF888888),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              onPressed: _handleDeposit,
              child: const Text(
                'Deposit',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, right: 10),
            child: const Icon(Icons.lens, size: 6, color: Color(0xFFF34C43)), // diamond-like or circular point
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF555555), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// Deposit History Page
// ----------------------------------------------------
class DepositHistoryPage extends StatelessWidget {
  const DepositHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF333333), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Deposit History',
          style: TextStyle(color: Color(0xFF222222), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: ApiService().getTransactions(ApiService().currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF34C43)));
          }
          final transactions = snapshot.data;
          
          // Filter to deposits only
          final deposits = transactions?.where((t) => t['type'] == 'deposit').toList() ?? [];

          if (deposits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'No data',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deposits.length,
            itemBuilder: (context, index) {
              final dep = deposits[index];
              final amount = double.tryParse(dep['amount'].toString()) ?? 0.0;
              final status = dep['status'] ?? 'pending';
              final createdAt = DateTime.tryParse(dep['created_at']?.toString() ?? '') ?? DateTime.now();
              final dateStr = _formatDateTime(createdAt);
              final utr = dep['receipt_image_url'] ?? '';

              Color statusColor = Colors.orange;
              if (status == 'approved') statusColor = const Color(0xFF2CA87E);
              if (status == 'rejected') statusColor = const Color(0xFFF15147);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Deposit Request',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text(
                          '₹${amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF222222)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('UTR / Reference:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text(
                          utr.isEmpty ? 'N/A' : utr,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Date:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text(
                          dateStr,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
