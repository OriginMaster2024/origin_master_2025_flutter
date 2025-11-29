import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'shooting_game.dart';

class DamageText extends PositionComponent with HasGameReference<ShootingGame> {
  final int damage;
  double _elapsedTime = 0.0;
  static const double _duration = 0.8; // 表示時間（秒）

  DamageText({required Vector2 position, required this.damage}) {
    this.position = position;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;

    // 上方向に浮かび上がる
    position.y -= 30 * dt; // 毎秒30ピクセル上に移動

    // 時間が経過したら削除
    if (_elapsedTime >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // フェードアウトの透明度を計算（1.0から0.0へ）
    final alpha = 1.0 - (_elapsedTime / _duration).clamp(0.0, 1.0);

    // テキストスタイル
    final textStyle = TextStyle(
      fontFamily: 'Melonano',
      color: Colors.red.withValues(alpha: alpha),
      fontSize: 24,
      shadows: [
        Shadow(
          offset: const Offset(1, 1),
          blurRadius: 2,
          color: Colors.black.withValues(alpha: alpha * 0.5),
        ),
      ],
    );

    // テキストパイント
    final textPainter = TextPainter(
      text: TextSpan(text: '-$damage', style: textStyle),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // テキストを描画
    textPainter.paint(canvas, Offset.zero);
  }
}
