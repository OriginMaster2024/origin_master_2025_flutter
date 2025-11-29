import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'bpm_state.dart';
import 'bullet.dart';
import 'turret.dart';

class ShootingGame extends FlameGame
    with HasCollisionDetection, ChangeNotifier {
  final Turret playerTurret = Turret(specs: TurretSpecs.getByLevel(1));
  final Turret enemyTurret = Turret(
    specs: TurretSpecs.getByLevel(2),
    isEnemy: true,
  );

  double timeSinceLastShot = 0;
  double tiltX = 0;
  final double sensitivity = 20;

  final BpmState bpmState;
  final void Function({
    required int level,
    required int hp,
    required double percentX,
    required double percentY,
  })
  onTurretStateChange;

  int turretLevel = 1; // 1:level1, 2:level2, 3:level3
  double stableCounter = 0.0; // isStable=true が続いた秒数

  final ValueNotifier<double> stableProgress = ValueNotifier(0.0);

  bool isGameOver = false;

  ShootingGame({required this.bpmState, required this.onTurretStateChange});

  @override
  Future<void> onLoad() async {
    _initTurrets();
    add(playerTurret);
    add(enemyTurret);

    accelerometerEventStream().listen((event) {
      tiltX = event.x;
    });

    pauseEngine();
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
      if (bullet.type.isEnemy) {
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

    // BPMデータを参照（例: 発射間隔の調整などに使用可能）
    // これらの値はゲームロジックで使用可能です
    // ignore: unused_local_variable
    final currentBpm = bpmState.bpm;
    // ignore: unused_local_variable
    final isStable = bpmState.isStable;
    // ignore: unused_local_variable
    final stdDev = bpmState.stdDev;
    // ここでBPMデータをゲームロジックに反映できます
    // 例: 発射間隔の調整、難易度の変更など
    // 使用例: playerTurret.specs.shotInterval = 0.5 + (currentBpm / 200.0);

    // BPM 状態に応じたカウント
    if (turretLevel < 3) {
      if (isStable) {
        stableCounter += dt;

        // 3 秒以上安定していたらレベルアップ
        if (stableCounter >= 3.0 && turretLevel < 3) {
          turretLevel += 1;
          playerTurret.specs = TurretSpecs.getByLevel(turretLevel);
          playerTurret.size = playerTurret.specs.size.clone();
          if (turretLevel < 3) {
            stableCounter = 0.0; // リセット
          }
        }
      } else {
        stableCounter = 0.0;
      }
    }

    // 自分のタレットの状態を相手に送信
    final mirroredPercentPosition = playerTurret.getMirroredPercentPosition();
    onTurretStateChange(
      level: turretLevel,
      hp: playerTurret.hp,
      percentX: mirroredPercentPosition.x,
      percentY: mirroredPercentPosition.y,
    );

    // ゲーム終了判定
    if (playerTurret.hp <= 0 && !isGameOver) {
      endGame(isPlayerWin: false);
    }

    // UI に進捗 0〜1 を通知
    stableProgress.value = (stableCounter / 3).clamp(0.0, 1.0);
  }

  void _initTurrets() {
    playerTurret.specs = TurretSpecs.getByLevel(1);
    playerTurret.position = Vector2(
      size.x / 2 - playerTurret.specs.size.x / 2,
      size.y - playerTurret.specs.size.y - 20 - 88,
    );
    playerTurret.hp = 100;

    enemyTurret.position = Vector2(
      size.x / 2 - enemyTurret.specs.size.x / 2,
      70,
    );
    enemyTurret.hp = 100;
  }

  void updateOpponentTurret({
    required int level,
    required int hp,
    required double percentX,
    required double percentY,
  }) {
    enemyTurret.specs = TurretSpecs.getByLevel(level);
    enemyTurret.size = enemyTurret.specs.size.clone();
    enemyTurret.hp = hp;

    var positionX = size.x * percentX;
    // 画面端で制限
    if (percentX < 0) positionX = 0;
    if (positionX + enemyTurret.specs.size.x > size.x) {
      positionX = size.x - enemyTurret.specs.size.x;
    }
    enemyTurret.position = Vector2(positionX, size.y * percentY);
  }

  void endGame({required bool isPlayerWin}) {
    isGameOver = true;
    pauseEngine();
    if (isPlayerWin) {
      overlays.add('gameClear');
    } else {
      overlays.add('gameOver');
    }
  }

  void resetGame() {
    // 弾なども全部消す
    children.whereType<Bullet>().forEach((b) => b.removeFromParent());

    _initTurrets();
  }
}
