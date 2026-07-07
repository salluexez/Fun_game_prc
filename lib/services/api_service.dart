import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService extends ChangeNotifier {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal();

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  String? _currentUserId;
  String? _currentUserPhone;

  String? get currentUserId => _currentUserId;
  String? get currentUserPhone => _currentUserPhone;
  bool get isLoggedIn => _currentUserId != null;

  void logout() {
    _currentUserId = null;
    _currentUserPhone = null;
    notifyListeners();
  }

  void setMockUser(String? id, String? phone) {
    _currentUserId = id;
    _currentUserPhone = phone;
    notifyListeners();
  }

  Future<void> autoLogin() async {
    // Starts as logged out so that fresh boots force authentication
  }

  // 1. Authentication
  Future<Map<String, dynamic>?> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUserId = data['id'];
        _currentUserPhone = data['phone_number'];
        notifyListeners();
        return data;
      }
    } catch (e) {
      debugPrint('API Login error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> register(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUserId = data['id'];
        _currentUserPhone = data['phone_number'];
        notifyListeners();
        return data;
      }
    } catch (e) {
      debugPrint('API Register error: $e');
    }
    return null;
  }

  // 2. Wallet Queries
  Future<double> getBalance(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/wallet/balance?userId=$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return double.parse(data['balance'].toString());
      }
    } catch (e) {
      debugPrint('API GetBalance error: $e');
    }
    return 0.00;
  }

  Future<bool> deposit(String userId, double amount, String receiptUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/wallet/deposit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
          'receiptImageUrl': receiptUrl,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API Deposit error: $e');
    }
    return false;
  }

  Future<bool> withdraw(String userId, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/wallet/withdraw'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'amount': amount}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API Withdraw error: $e');
    }
    return false;
  }

  Future<List<dynamic>?> getTransactions(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/wallet/transactions?userId=$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('API GetTransactions error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/user/profile?userId=$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('API GetUserProfile error: $e');
    }
    return null;
  }

  Future<bool> updateUserUpi(String userId, String upiAddress, String upiName) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/user/upi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'upiAddress': upiAddress,
          'upiName': upiName,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API UpdateUserUpi error: $e');
    }
    return false;
  }

  Future<String> getQrUrl() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/settings/qr'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['qrUrl'] ?? '';
      }
    } catch (e) {
      debugPrint('API GetQrUrl error: $e');
    }
    return '';
  }

  Future<Map<String, dynamic>?> placeAviatorBet(String userId, double betAmount) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/aviator/bet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'betAmount': betAmount,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('API PlaceAviatorBet error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> cashoutAviatorBet(String betId, double multiplier) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/aviator/cashout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'betId': betId,
          'multiplier': multiplier,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('API CashoutAviatorBet error: $e');
    }
    return null;
  }

  Future<void> loseAviatorBet(String betId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/aviator/lose'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'betId': betId}),
      );
    } catch (e) {
      debugPrint('API LoseAviatorBet error: $e');
    }
  }

  Future<List<dynamic>?> getAviatorHistory(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/aviator/history?userId=$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('API GetAviatorHistory error: $e');
    }
    return null;
  }


  // 3. Game Queries
  Future<Map<String, dynamic>?> getActivePeriod(String gameType) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/games/active-period?gameType=$gameType'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('API GetActivePeriod error: $e');
    }
    return null;
  }

  Future<List<dynamic>> getGameHistory(String gameType) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/games/history?gameType=$gameType'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('API GetGameHistory error: $e');
    }
    return [];
  }

  // 4. Bets Queries
  Future<Map<String, dynamic>?> placeBet(String userId, String gamePeriodId, String choice, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/bets/place'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'gamePeriodId': gamePeriodId,
          'choice': choice,
          'betAmount': amount,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('API PlaceBet error: $e');
    }
    return null;
  }

  Future<List<dynamic>> getMyHistory(String userId, String gameType) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/bets/my-history?userId=$userId&gameType=$gameType'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('API GetMyHistory error: $e');
    }
    return [];
  }
}
