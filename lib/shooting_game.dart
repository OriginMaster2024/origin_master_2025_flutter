import 'package:flame/game.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'bpm_state.dart';
import 'bullet.dart';
import 'turret.dart';

class ShootingGame extends FlameGame with HasCollisionDetection {
  final Turret playerTurret = Turret(specs: TurretSpecs.getByLevel(1));
  final Turret enemyTurret = Turret(
    specs: TurretSpecs.getByLevel(2),
    isEnemy: true,
  );

  double timeSinceLastShot = 0;
  double tiltX = 0;
  final double sensitivity = 20;

  final BpmState bpmState;

  int turretLevel = 1; // 1:level1, 2:level2, 3:level3
  double stableCounter = 0.0; // isStable=true が続いた秒数
  double unstableCounter = 0.0; // isStable=false が続いた秒数

  ShootingGame({required this.bpmState});

  @override
  Future<void> onLoad() async {
    initTurrets();
    add(playerTurret);
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
    if (isStable) {
      stableCounter += dt;
      unstableCounter = 0.0;

      // 3 秒以上安定していたらレベルアップ
      if (stableCounter >= 3.0 && turretLevel < 3) {
        turretLevel += 1;
        playerTurret.specs = TurretSpecs.getByLevel(turretLevel);
        playerTurret.size = playerTurret.specs.size.clone();
        stableCounter = 0.0; // リセット
      }
    } else {
      unstableCounter += dt;
      stableCounter = 0.0;

      // 0.2 秒以上不安定でレベルダウン
      if (unstableCounter >= 0.2 && turretLevel > 1) {
        turretLevel -= 1;
        playerTurret.specs = TurretSpecs.getByLevel(turretLevel);
        playerTurret.size = playerTurret.specs.size.clone();
        unstableCounter = 0.0; // リセット
      }
    }

    // ゲーム終了判定
    if (playerTurret.hp <= 0) {
      pauseEngine();
      overlays.add('gameOver');
    } else if (enemyTurret.hp <= 0) {
      pauseEngine();
      overlays.add('gameClear');
    }
  }

  void initTurrets() {
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

  void resetGame() {
    // 弾なども全部消す
    children.whereType<Bullet>().forEach((b) => b.removeFromParent());

    initTurrets();
  }
}
