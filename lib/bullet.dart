import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Bullet extends PositionComponent {
  static const double speed = 300;

  Bullet(Vector2 position) {
    this.position = position;
    size = Vector2(5, 20);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.red;
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void update(double dt) {
    position.y -= speed * dt;
    if (position.y + size.y < 0) {
      removeFromParent();
    }
  }
}
