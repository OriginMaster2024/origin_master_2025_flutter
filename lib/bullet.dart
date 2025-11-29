import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class Bullet extends PositionComponent with HasGameReference<FlameGame> {
  static const double speed = 300;
  final bool isEnemy;
  final BulletType type;
  ui.Image? image;

  Bullet(Vector2 position, {this.isEnemy = false, required this.type}) {
    this.position = position;
    size = type.size;
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

  String get imagePath {
    switch (this) {
      case BulletType.playerLevel1:
        return 'assets/grape.png';
      case BulletType.playerLevel2:
        return 'assets/grape.png';
      case BulletType.playerLevel3:
        return 'assets/grape.png';
      case BulletType.enemyLevel1:
        return 'assets/grape.png';
      case BulletType.enemyLevel2:
        return 'assets/grape.png';
      case BulletType.enemyLevel3:
        return 'assets/grape.png';
    }
  }

  Vector2 get size {
    switch (this) {
      case BulletType.playerLevel1:
        return Vector2(24, 32);
      case BulletType.playerLevel2:
        return Vector2(5, 20);
      case BulletType.playerLevel3:
        return Vector2(5, 20);
      case BulletType.enemyLevel1:
        return Vector2(5, 20);
      case BulletType.enemyLevel2:
        return Vector2(5, 20);
      case BulletType.enemyLevel3:
        return Vector2(5, 20);
    }
  }

  static BulletType make(int level, bool isEnemy) {
    if (isEnemy) {
      if (level == 3) {
        return BulletType.enemyLevel3;
      } else if (level == 2) {
        return BulletType.enemyLevel2;
      } else {
        return BulletType.enemyLevel1;
      }
    } else {
      if (level == 3) {
        return BulletType.playerLevel3;
      } else if (level == 2) {
        return BulletType.playerLevel2;
      } else {
        return BulletType.playerLevel1;
      }
    }
  }
}