import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'bullet.dart';
import 'turret_specs.dart';

class ShootingGame extends FlameGame {
  late TurretSpecs turretSpecs;
  late RectangleComponent turret;

  double timeSinceLastShot = 0;
  double tiltX = 0;
  final double sensitivity = 10;

  ShootingGame({required this.turretSpecs});

  void setTurretSpecs(TurretSpecs specs) {
    turretSpecs = specs;
    turret.size = specs.size;
  }

  @override
  Future<void> onLoad() async {
    turret = RectangleComponent(
      size: turretSpecs.size,
      position: Vector2(size.x / 2 - turretSpecs.size.x / 2, size.y - turretSpecs.size.y - 20),
      paint: Paint()..color = const Color(0xFF0000FF),
    );
    add(turret);

    accelerometerEventStream().listen((event) {
      tiltX = event.x;
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 弾発射
    timeSinceLastShot += dt;
    if (timeSinceLastShot >= turretSpecs.shotInterval) {
      timeSinceLastShot = 0;
      final bulletPos = turret.position + Vector2(turret.size.x / 2 - 2.5, -20);
      add(Bullet(bulletPos));
    }

    // 発射台移動
    turret.x -= tiltX * sensitivity * dt;

    // 画面端で制限
    if (turret.x < 0) turret.x = 0;
    if (turret.x + turret.size.x > size.x) turret.x = size.x - turret.size.x;
  }
}
