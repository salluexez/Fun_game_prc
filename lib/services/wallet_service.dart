import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

class WalletService extends ChangeNotifier {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;

  Timer? _syncTimer;

  WalletService._internal() {
    _init();
    _startSyncTimer();
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

  void _startSyncTimer() {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (ApiService().isLoggedIn) {
        syncBalance();
      }
    });
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
