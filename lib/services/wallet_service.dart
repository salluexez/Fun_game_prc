import 'package:flutter/material.dart';

class WalletService extends ChangeNotifier {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;

  WalletService._internal();

  double _balance = 2.03; // Shared balance starts at 2.03

  double get balance => _balance;

  void deposit(double amount) {
    _balance += amount;
    notifyListeners();
  }

  bool withdraw(double amount) {
    if (_balance < amount) return false;
    _balance -= amount;
    notifyListeners();
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
}
