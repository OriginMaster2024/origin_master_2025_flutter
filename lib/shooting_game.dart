import 'package:flame/game.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'bullet.dart';
import 'turret.dart';

class ShootingGame extends FlameGame {
  late Turret playerTurret;
  late Turret enemyTurret;

  double timeSinceLastShot = 0;
  double tiltX = 0;
  final double sensitivity = 10;

  ShootingGame({
    required TurretSpecs playerSpec,
    required TurretSpecs enemySpec,
  }) : playerTurret = Turret(specs: playerSpec),
       enemyTurret = Turret(specs: enemySpec, isEnemy: true);

  @override
  Future<void> onLoad() async {
    // プレイヤータレットの初期位置
    playerTurret.position = Vector2(
      size.x / 2 - playerTurret.specs.size.x / 2,
      size.y - playerTurret.specs.size.y - 20,
    );
    add(playerTurret);

    // 敵タレットの固定位置（上部中央）
    enemyTurret.position = Vector2(
      size.x / 2 - enemyTurret.specs.size.x / 2,
      70,
    );
    add(enemyTurret);

    accelerometerEventStream().listen((event) {
      tiltX = event.x;
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // プレイヤータレットの移動
    playerTurret.x -= tiltX * sensitivity * dt;

    // 画面端で制限
    if (playerTurret.x < 0) playerTurret.x = 0;
    if (playerTurret.x + playerTurret.specs.size.x > size.x) {
      playerTurret.x = size.x - playerTurret.specs.size.x;
    }

    // 弾の当たり判定
    for (final bullet in children.whereType<Bullet>()) {
      if (bullet.isEnemy) {
        // 敵の弾 → プレイヤーにヒットするか
        if (bullet.toRect().overlaps(playerTurret.toRect())) {
          playerTurret.takeDamage(10);
          bullet.removeFromParent();
        }
      } else {
        // プレイヤーの弾 → 敵にヒットするか
        if (bullet.toRect().overlaps(enemyTurret.toRect())) {
          enemyTurret.takeDamage(10);
          bullet.removeFromParent();
        }
      }
    }
  }
}
