import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/wallet_service.dart';
import 'login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToPrivacy = false;
  bool _isLoading = false;

  String _countryCode = '+91';

  Future<void> _handleRegister() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (phone.isEmpty) {
      _showError('Please enter the phone number');
      return;
    }
    if (phone.length < 10) {
      _showError('Please enter a valid 10-digit phone number');
      return;
    }
    if (password.isEmpty) {
      _showError('Please set a password');
      return;
    }
    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }
    if (!_agreeToPrivacy) {
      _showError('Please read and agree to the Privacy Agreement');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final apiService = ApiService();
    // Complete phone string
    final fullPhone = '$_countryCode$phone';

    final result = await apiService.register(fullPhone, password);

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      // Sync balance
      await WalletService().syncBalance();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Color(0xFF2CA87E),
          ),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Go back to Home
        }
      }
    } else {
      _showError('Registration failed. Phone number might already be registered.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF15147),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF34C43),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF34C43), Color(0xFFF8736B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo/Zonex.png',
                      height: 32,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'Zonex',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Register',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Please register by phone number or email',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            
            // Body Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phone registration tab indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.phone_android, color: Color(0xFFF15147)),
                          const SizedBox(height: 6),
                          const Text(
                            'Register your phone',
                            style: TextStyle(color: Color(0xFFF15147), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 140,
                            color: const Color(0xFFF15147),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Phone Number Input
                  const Row(
                    children: [
                      Icon(Icons.phone_android, color: Color(0xFFF15147), size: 16),
                      SizedBox(width: 8),
                      Text('Phone number', style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _countryCode,
                            items: ['+91', '+1', '+44', '+86'].map((code) {
                              return DropdownMenuItem<String>(
                                value: code,
                                child: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _countryCode = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Please enter the phone number',
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Set Password Input
                  const Row(
                    children: [
                      Icon(Icons.lock_outline, color: Color(0xFFF15147), size: 16),
                      SizedBox(width: 8),
                      Text('Set password', style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Set password',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      fillColor: const Color(0xFFF5F5F5),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Input
                  const Row(
                    children: [
                      Icon(Icons.lock_outline, color: Color(0xFFF15147), size: 16),
                      SizedBox(width: 8),
                      Text('Confirm password', style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      fillColor: const Color(0xFFF5F5F5),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Invite Code Input
                  const Row(
                    children: [
                      Icon(Icons.card_giftcard, color: Color(0xFFF15147), size: 16),
                      SizedBox(width: 8),
                      Text('Invite code', style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _inviteCodeController,
                    decoration: InputDecoration(
                      hintText: 'Please enter the invitation code',
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

                  // Terms & Privacy Agreement Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToPrivacy,
                        activeColor: const Color(0xFFF15147),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _agreeToPrivacy = val;
                            });
                          }
                        },
                      ),
                      const Text(
                        'I have read and agree ',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const Text(
                        '【Privacy Agreement】',
                        style: TextStyle(color: Color(0xFFF15147), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8736B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Register',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // I have an account Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF8736B)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginView()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('I have an account ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text('Login', style: TextStyle(color: Color(0xFFF15147), fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
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
}
