import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class Bullet extends PositionComponent with HasGameReference<FlameGame> {
  static const double speed = 300;
  final bool isEnemy;
  ui.Image? image;

  Bullet(Vector2 position, {this.isEnemy = false}) {
    this.position = position;
    size = Vector2(5, 20);
  }

  @override
  Future<void> onLoad() async {
    final imagePath = 'assets/grape.png';
    image = await loadUiImage(imagePath);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = isEnemy ? Colors.red : Colors.green;
    canvas.drawRect(size.toRect(), paint);

    // FIXME: サイズを変える
    if (image != null) {
      canvas.drawImageRect(
          image!,
          Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
          Rect.fromLTWH(0, 0, size.x, size.y),
          Paint()
      );
    }
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

  Future<ui.Image> loadUiImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}

enum BulletType {
  playerLevel1,
  playerLevel2,
  playerLevel3,

  enemyLevel1,
  enemyLevel2,
  enemyLevel3;
}