import 'package:flame/components.dart';

class TurretSpecs {
  final double shotInterval; // 弾の発射間隔（秒）
  final Vector2 size;        // 発射台のサイズ（幅・高さ）

  TurretSpecs({required this.shotInterval, required this.size});
}

// 発射台パターン
final bigSlowTurret = TurretSpecs(
  shotInterval: 0.8,
  size: Vector2(100, 30),
);

final smallFastTurret = TurretSpecs(
  shotInterval: 0.3,
  size: Vector2(50, 20),
);
