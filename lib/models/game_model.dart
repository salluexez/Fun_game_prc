enum GameStatus { idle, playing, won, lost, draw }

class GameModel {
  final String gameName;
  final GameStatus status;
  final int score;
  final String? message;

  const GameModel({
    required this.gameName,
    this.status = GameStatus.idle,
    this.score = 0,
    this.message,
  });

  GameModel copyWith({
    String? gameName,
    GameStatus? status,
    int? score,
    String? message,
  }) {
    return GameModel(
      gameName: gameName ?? this.gameName,
      status: status ?? this.status,
      score: score ?? this.score,
      message: message ?? this.message,
    );
  }
}
