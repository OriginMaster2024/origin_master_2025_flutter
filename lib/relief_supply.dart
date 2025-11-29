import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shooting_game.dart';

class ReliefSupply extends PositionComponent
    with HasGameReference<ShootingGame>, CollisionCallbacks {
  static const double fallSpeed = 100; // 落下速度（ピクセル/秒）
  ui.Image? image;

  ReliefSupply({required Vector2 position}) {
    this.position = position;
    size = Vector2(40, 60);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    image = await loadUiImage('assets/relief_supply.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 下方向に落下
    position.y += fallSpeed * dt;

    // 画面外に出たら削除
    if (position.y > game.size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (image != null) {
      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint(),
      );
    }
  }

  Future<ui.Image> loadUiImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}
