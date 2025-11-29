import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'bullet.dart';

class Turret extends PositionComponent {
  TurretSpecs specs;
  final bool isEnemy;
  double timeSinceLastShot = 0.0;

  int hp = 500;

  Turret({
    required this.specs,
    this.isEnemy = false,
  }) {
    size = specs.size;
  }

  // specs の setter を作って size も更新
  set updateSpecs(TurretSpecs newSpecs) {
    specs = newSpecs;
    size = specs.size.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    timeSinceLastShot += dt;

    if (timeSinceLastShot >= specs.shotInterval) {
      shoot();
      timeSinceLastShot = 0.0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // タレット本体
    canvas.drawRect(size.toRect(), Paint()..color = Colors.blue);

    // HPバー
    final barWidth = size.x;
    final barHeight = 5.0;
    final barY = isEnemy ? -barHeight - 2 : size.y + 2; // 敵は上、プレイヤーは下

    // 背景バー（灰色）
    canvas.drawRect(
      Rect.fromLTWH(0, barY, barWidth, barHeight),
      Paint()..color = Colors.grey,
    );

    // HPバー（緑）
    canvas.drawRect(
      Rect.fromLTWH(0, barY, barWidth * (hp / 100), barHeight),
      Paint()..color = Colors.green,
    );
  }

  void shoot() {
    // タレット中心位置
    final bulletX = position.x + size.x / 2 - 2.5; // 弾の幅5の半分
    final bulletY = isEnemy
        ? position.y + size.y // 敵は下から発射
        : position.y;    // プレイヤーは上から発射（弾の高さ20）

    final bulletPosition = Vector2(bulletX, bulletY);
    final bullet = Bullet(bulletPosition, isEnemy: isEnemy);
    parent?.add(bullet);
  }

  void takeDamage(int amount) {
    hp -= amount;
    if (hp < 0) hp = 0;
  }
}

class TurretSpecs {
  final double shotInterval; // 弾の発射間隔（秒）
  final Vector2 size; // 発射台のサイズ（幅・高さ）

  TurretSpecs({required this.shotInterval, required this.size});

  static TurretSpecs getByLevel(int level) {
    switch (level) {
      case 1:
        return TurretSpecs(shotInterval: 0.8, size: Vector2(40, 20));
      case 2:
        return TurretSpecs(shotInterval: 0.5, size: Vector2(60, 30));
      case 3:
        return TurretSpecs(shotInterval: 0.2, size: Vector2(80, 40));
      default:
        return TurretSpecs(shotInterval: 0.8, size: Vector2(40, 20));
    }
  }
}
