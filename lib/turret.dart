import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:origin_master_2025_flutter/shooting_game.dart';

import 'bullet.dart';

class Turret extends PositionComponent
    with HasGameReference<ShootingGame>, CollisionCallbacks {
  TurretSpecs specs;
  final bool isEnemy;
  double timeSinceLastShot = 0.0;
  ui.Image? image;

  int hp = 500;

  Turret({required this.specs, this.isEnemy = false}) {
    size = specs.size;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    final imagePath = isEnemy ? 'assets/airplane.png' : 'assets/ship.png';
    image = await loadUiImage(imagePath);
  }

  // specs の setter を作って size も更新
  set updateSpecs(TurretSpecs newSpecs) {
    specs = newSpecs;
    size = specs.size.clone();
  }

  Future<ui.Image> loadUiImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
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
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // 弾の当たり判定
    if (other is Bullet) {
      if (!isEnemy && other.type.isEnemy) {
        // 自分の場合はダメージ計算をする
        takeDamage(other.damage);
        other.removeFromParent();
      } else if (isEnemy && !other.type.isEnemy) {
        // 敵の場合は弾を消すだけ
        other.removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // タレット本体
    if (image != null) {
      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.x, size.x * 4 / 5),
        Paint(),
      );
    }

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
    final bulletType = BulletType.make(1, isEnemy); // FIXME: isEnemeyとlevelで初期化する
    final bulletX = position.x + size.x / 2 - bulletType.size.x / 2; // 弾の幅の半分
    final bulletY = isEnemy
        ? position.y +
              size
                  .y // 敵は下から発射
        : position.y; // プレイヤーは上から発射（弾の高さ20）

    final bulletPosition = Vector2(bulletX, bulletY);
    final bullet = Bullet(bulletPosition, type: bulletType);
    parent?.add(bullet);
  }

  void takeDamage(int amount) {
    hp -= amount;
    if (hp < 0) hp = 0;

    if (!isEnemy) {
      // プレイヤーの場合のみ振動
      HapticFeedback.lightImpact();
    }
  }

  /// 相手目線での自分の位置を返してくれる関数
  /// 相手にbroadcastで位置情報を送る際にこの値を渡す
  Vector2 getMirroredPercentPosition() {
    final mirroredPosition = game.size - position;
    return Vector2(
      mirroredPosition.x / game.size.x,
      mirroredPosition.y / game.size.y,
    );
  }
}

class TurretSpecs {
  final int level; // レベル
  final double shotInterval; // 弾の発射間隔（秒）
  final Vector2 size; // 発射台のサイズ（幅・高さ）

  TurretSpecs({required this.level, required this.shotInterval, required this.size});

  static TurretSpecs getByLevel(int level) {
    switch (level) {
      case 1:
        return TurretSpecs(level: 1, shotInterval: 0.8, size: Vector2(40, 40 * 4 / 5));
      case 2:
        return TurretSpecs(level: 2, shotInterval: 0.5, size: Vector2(60, 60 * 4 / 5));
      case 3:
        return TurretSpecs(level: 3, shotInterval: 0.2, size: Vector2(80, 80 * 4 / 5));
      default:
        return TurretSpecs(level: 1, shotInterval: 0.8, size: Vector2(40, 40 * 4 / 5));
    }
  }
}
