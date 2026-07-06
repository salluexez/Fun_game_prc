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

class WithdrawView extends StatefulWidget {
  const WithdrawView({super.key});

  @override
  State<WithdrawView> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends State<WithdrawView> {
  final _amountController = TextEditingController();
  final _upiAddressController = TextEditingController();
  final _upiNameController = TextEditingController();

  double? _enteredAmount;
  bool _isSubmitting = false;
  bool _isRefreshing = false;
  bool _isLoadingProfile = true;

  String _upiAddress = '';
  String _upiName = '';

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      final text = _amountController.text;
      if (text.isEmpty) {
        setState(() {
          _enteredAmount = null;
        });
      } else {
        final val = double.tryParse(text);
        setState(() {
          _enteredAmount = val;
        });
      }
    });
    _loadUserProfile();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiAddressController.dispose();
    _upiNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });
    final profile = await ApiService().getUserProfile(ApiService().currentUserId!);
    if (profile != null) {
      setState(() {
        _upiAddress = profile['upiAddress'] ?? '';
        _upiName = profile['upiName'] ?? '';
      });
    }
    setState(() {
      _isLoadingProfile = false;
    });
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

  void _showAddUpiModal() {
    _upiAddressController.text = _upiAddress;
    _upiNameController.text = _upiName;

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
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _upiAddress.isEmpty ? 'Add UPI Account' : 'Edit UPI Account',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'UPI Account Name',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _upiNameController,
                decoration: InputDecoration(
                  hintText: 'Enter account holder name',
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
              const SizedBox(height: 16),
              const Text(
                'UPI ID / Address',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _upiAddressController,
                decoration: InputDecoration(
                  hintText: 'Enter UPI ID (e.g. name@upi)',
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF34C43),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () async {
                    final name = _upiNameController.text.trim();
                    final address = _upiAddressController.text.trim();
                    
                    if (name.isEmpty || address.isEmpty || !address.contains('@')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid Name and UPI ID')),
                      );
                      return;
                    }
                    
                    Navigator.pop(modalContext); // Close sheet
                    
                    setState(() {
                      _isSubmitting = true;
                    });
                    
                    final success = await ApiService().updateUserUpi(
                      ApiService().currentUserId!,
                      address,
                      name,
                    );
                    
                    if (success) {
                      await _loadUserProfile();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('UPI account updated successfully!'),
                          backgroundColor: Color(0xFF2CA87E),
                        ),
                      );
                    } else {
                      setState(() {
                        _isSubmitting = false;
                      });
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update UPI account. Please try again.'),
                          backgroundColor: Color(0xFFF15147),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save UPI Details',
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

  void _handleWithdraw() async {
    final amt = _enteredAmount;
    
    if (_upiAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a UPI account first to withdraw.'),
          backgroundColor: Color(0xFFF15147),
        ),
      );
      return;
    }

    if (amt == null || amt < 500 || amt > 10000000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount between ₹500.00 and ₹10,000,000.00'),
          backgroundColor: Color(0xFFF15147),
        ),
      );
      return;
    }

    if (amt > WalletService().balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance to withdraw.'),
          backgroundColor: Color(0xFFF15147),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await ApiService().withdraw(
      ApiService().currentUserId!,
      amt,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      await WalletService().syncBalance();
      _amountController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal request submitted! Pending Admin Approval.'),
          backgroundColor: Color(0xFF2CA87E),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal failed. Please try again.'),
          backgroundColor: Color(0xFFF15147),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAmount = _enteredAmount != null && _enteredAmount! > 0;
    
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
          'Withdraw',
          style: TextStyle(color: Color(0xFF222222), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WithdrawalHistoryPage()),
              );
            },
            child: const Text(
              'Withdrawal history',
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
                // 1. Available Balance Card
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
                                'Available balance',
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

                // 2. ARPay Header Info Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCAAA4).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'A',
                          style: TextStyle(color: Color(0xFFF34C43), fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ARPay',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF222222)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Supports UPI for fast payment, and bonuses for withdrawals',
                              style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. UPI Selector / Add UPI Block
                _isLoadingProfile
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFFF34C43))),
                      )
                    : Container(
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
                            const Row(
                              children: [
                                Icon(Icons.payment, color: Color(0xFFF34C43), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Withdrawal Account (UPI)',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _upiAddress.isEmpty
                                ? InkWell(
                                    onTap: _showAddUpiModal,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade200, width: 1),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_circle_outline, color: Color(0xFFF34C43), size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Add UPI Details',
                                            style: TextStyle(
                                              color: Color(0xFFF34C43),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFCAAA4).withOpacity(0.08),
                                      border: Border.all(color: const Color(0xFFF34C43).withOpacity(0.2), width: 1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFF34C43), size: 28),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _upiName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF222222)),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _upiAddress,
                                                style: const TextStyle(color: Color(0xFF555555), fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Color(0xFFF34C43), size: 20),
                                          onPressed: _showAddUpiModal,
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),

                const SizedBox(height: 16),

                // 4. Withdrawal Amount Input
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
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              '₹',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF34C43)),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          hintText: 'Please enter the amount',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.normal),
                          fillColor: const Color(0xFFF8F9FB),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Withdrawable balance ₹${WalletService().balance.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          GestureDetector(
                            onTap: () {
                              _amountController.text = WalletService().balance.toStringAsFixed(0);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFF34C43)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'All',
                                style: TextStyle(color: Color(0xFFF34C43), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Withdrawal amount received',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '₹${_enteredAmount?.toStringAsFixed(2) ?? "0.00"}',
                            style: const TextStyle(color: Color(0xFFF34C43), fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 5. Withdrawal Instructions
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
                      _buildInstructionItem('Need to bet ₹0.28 to be able to withdraw'),
                      _buildInstructionItem('Withdraw time 00:00-23:55'),
                      _buildInstructionItem('Inday Remaining Withdrawal Times 3'),
                      _buildInstructionItem('Withdrawal amount range ₹500.00-₹10,000,000.00'),
                      _buildInstructionItem('Please confirm your beneficial account information before withdrawing. If your information is incorrect, our company will not be liable for the amount of loss'),
                      _buildInstructionItem('If your beneficial information is incorrect, please contact customer service'),
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
                  'Withdrawal Method:',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  _upiAddress.isEmpty ? 'Not set' : 'UPI',
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
              onPressed: _handleWithdraw,
              child: const Text(
                'Withdraw',
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
            child: const Icon(Icons.lens, size: 6, color: Color(0xFFF34C43)),
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
// Withdrawal History Page
// ----------------------------------------------------
class WithdrawalHistoryPage extends StatelessWidget {
  const WithdrawalHistoryPage({super.key});

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
          'Withdrawal History',
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
          
          // Filter to withdrawals only
          final withdrawals = transactions?.where((t) => t['type'] == 'withdrawal').toList() ?? [];

          if (withdrawals.isEmpty) {
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
            itemCount: withdrawals.length,
            itemBuilder: (context, index) {
              final wd = withdrawals[index];
              final amount = double.tryParse(wd['amount'].toString()) ?? 0.0;
              final status = wd['status'] ?? 'pending';
              final createdAt = DateTime.tryParse(wd['created_at']?.toString() ?? '') ?? DateTime.now();
              final dateStr = _formatDateTime(createdAt);

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
                          'Withdrawal Request',
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
                        const Text('Method:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const Text(
                          'UPI',
                          style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
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
