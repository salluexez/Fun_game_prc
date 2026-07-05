import 'package:flutter/material.dart';
import 'api_service.dart';

class WalletService extends ChangeNotifier {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;

  WalletService._internal() {
    _init();
  }

  double _balance = 2.03; // Shared balance starts at 2.03

  double get balance => _balance;

  Future<void> _init() async {
    await ApiService().autoLogin();
    if (ApiService().isLoggedIn) {
      final b = await ApiService().getBalance(ApiService().currentUserId!);
      _balance = b;
      notifyListeners();
    }
  }

  void deposit(double amount) {
    if (ApiService().isLoggedIn) {
      ApiService().deposit(ApiService().currentUserId!, amount, '').then((success) {
        // In live mode, balance only increases once admin approves the deposit transaction.
        // We sync balance periodically.
        syncBalance();
      });
    } else {
      _balance += amount;
      notifyListeners();
    }
  }

  bool withdraw(double amount) {
    if (_balance < amount) return false;
    _balance -= amount;
    notifyListeners();

    if (ApiService().isLoggedIn) {
      ApiService().withdraw(ApiService().currentUserId!, amount).then((success) {
        if (!success) {
          // Revert on API failure
          _balance += amount;
          notifyListeners();
        } else {
          syncBalance();
        }
      });
    }
    return true;
  }

  bool deduct(double amount) {
    if (_balance < amount) return false;
    _balance -= amount;
    notifyListeners();
    return true;
  }

  void addPayout(double amount) {
    _balance += amount;
    notifyListeners();
  }

  Future<void> syncBalance() async {
    if (ApiService().isLoggedIn) {
      final b = await ApiService().getBalance(ApiService().currentUserId!);
      _balance = b;
      notifyListeners();
    }
  }
}
