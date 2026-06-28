import 'package:flutter/material.dart';
import '../models/game_model.dart';

class HomeViewModel extends ChangeNotifier {
  GameModel _gameState = const GameModel(
    gameName: 'Retro Game Arcade',
    status: GameStatus.idle,
    score: 0,
    message: 'Welcome to the Arcade! Select a game to begin.',
  );

  GameModel get gameState => _gameState;

  // List of available games in our arcade
  final List<String> availableGames = [
    'Tic-Tac-Toe',
    'Memory Match',
    'Number Guessing',
    'Snake Classic',
  ];

  String? _selectedGame;
  String? get selectedGame => _selectedGame;

  void selectGame(String gameName) {
    _selectedGame = gameName;
    _gameState = _gameState.copyWith(
      gameName: gameName,
      status: GameStatus.idle,
      message: 'Ready to play $gameName!',
    );
    notifyListeners();
  }

  void startGame() {
    if (_selectedGame == null) return;
    _gameState = _gameState.copyWith(
      status: GameStatus.playing,
      message: 'Game in progress...',
    );
    notifyListeners();
  }

  void resetGame() {
    _selectedGame = null;
    _gameState = const GameModel(
      gameName: 'Retro Game Arcade',
      status: GameStatus.idle,
      score: 0,
      message: 'Select a game to begin.',
    );
    notifyListeners();
  }
}
