import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';
import '../models/game_model.dart';

class HomeView extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final state = viewModel.gameState;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
              ),
            ),
            child: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: state.status == GameStatus.playing
                    ? _buildGamePlayScreen(state)
                    : _buildMainMenuScreen(context, state),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainMenuScreen(BuildContext context, GameModel state) {
    return Padding(
      key: const ValueKey('MainMenu'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          // App Title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF007F), Color(0xFF7F00FF)],
            ).createShader(bounds),
            child: const Text(
              'RETRO ARCADE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message ?? 'Select a game to begin.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          // Game selection list
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.availableGames.length,
              itemBuilder: (context, index) {
                final gameName = viewModel.availableGames[index];
                final isSelected = viewModel.selectedGame == gameName;

                return GestureDetector(
                  onTap: () => viewModel.selectGame(gameName),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF7F00FF).withOpacity(0.3)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF007F)
                            : Colors.white12,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF007F).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFF007F).withOpacity(0.2)
                                    : Colors.white10,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getGameIcon(gameName),
                                color: isSelected
                                    ? const Color(0xFFFF007F)
                                    : Colors.white70,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              gameName,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                                fontSize: 18,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFFFF007F),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Action Button
          ElevatedButton(
            onPressed: viewModel.selectedGame != null
                ? () => viewModel.startGame()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF007F),
              disabledBackgroundColor: Colors.white10,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: viewModel.selectedGame != null ? 8 : 0,
            ),
            child: Text(
              viewModel.selectedGame != null
                  ? 'PLAY ${viewModel.selectedGame!.toUpperCase()}'
                  : 'SELECT A GAME',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: viewModel.selectedGame != null
                    ? Colors.white
                    : Colors.white30,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGamePlayScreen(GameModel state) {
    return Padding(
      key: const ValueKey('GamePlay'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.sports_esports_outlined,
            size: 100,
            color: Color(0xFFFF007F),
          ),
          const SizedBox(height: 24),
          Text(
            state.gameName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Game Mode Activated!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF007F)),
                ),
                const SizedBox(height: 20),
                Text(
                  'Current Score: ${state.score}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Waiting for user implementation step...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white38,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          OutlinedButton(
            onPressed: () => viewModel.resetGame(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'BACK TO MENU',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGameIcon(String gameName) {
    switch (gameName) {
      case 'Tic-Tac-Toe':
        return Icons.grid_3x3;
      case 'Memory Match':
        return Icons.style;
      case 'Number Guessing':
        return Icons.question_mark;
      case 'Snake Classic':
        return Icons.gesture;
      default:
        return Icons.gamepad;
    }
  }
}
