import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'bullet.dart';

class Turret extends PositionComponent {
  final TurretSpecs specs;
  final bool isEnemy;
  double timeSinceLastShot = 0.0;

  Turret({required this.specs, this.isEnemy = false});

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
    canvas.drawRect(specs.size.toRect(), Paint()..color = Colors.blue);
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
}

class TurretSpecs {
  final double shotInterval; // 弾の発射間隔（秒）
  final Vector2 size; // 発射台のサイズ（幅・高さ）

  TurretSpecs({required this.shotInterval, required this.size});
}

// 発射台パターン
final bigSlowTurret = TurretSpecs(shotInterval: 0.8, size: Vector2(100, 30));

final smallFastTurret = TurretSpecs(shotInterval: 0.3, size: Vector2(50, 20));
