import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'bullet.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class Turret extends PositionComponent {
  final TurretSpecs specs;
  final bool isEnemy;
  double timeSinceLastShot = 0.0;
  ui.Image? image;

  int hp = 100;

  Turret({
    required this.specs,
    this.isEnemy = false,
  }) {
    size = specs.size;
  }

  @override
  Future<void> onLoad() async {
    final imagePath = isEnemy ? 'assets/airplane.png' : 'assets/ship.png';
    image = await loadUiImage(imagePath);
    return super.onLoad();
  }

  Future<ui.Image> loadUiImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
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

    if (image != null) {
      canvas.drawImageRect(
          image!,
          Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
          Rect.fromLTWH(0, barY, barWidth, barWidth * 4 / 5),
          Paint()
      );
    }
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
}

// 発射台パターン
final bigSlowTurret = TurretSpecs(shotInterval: 0.8, size: Vector2(100, 30));

final smallFastTurret = TurretSpecs(shotInterval: 0.3, size: Vector2(50, 20));
