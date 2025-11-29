import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Bullet extends PositionComponent
    with HasGameReference<FlameGame>, CollisionCallbacks {
  static const double speed = 300;
  final int damage;
  final bool isEnemy;

  Bullet(Vector2 position, {this.isEnemy = false, this.damage = 10}) {
    this.position = position;
    size = Vector2(5, 20);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = isEnemy ? Colors.red : Colors.green;
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void update(double dt) {
    // 敵弾は下方向、プレイヤー弾は上方向
    position.y += isEnemy ? speed * dt : -speed * dt;

    // 画面外に出たら削除
    if (position.y + size.y < 0 || position.y > game.size.y) {
      removeFromParent();
    }
  }
}
