import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'bpm_state.dart';
import 'bullet.dart';
import 'relief_supply.dart';
import 'turret.dart';

class ShootingGame extends FlameGame
    with HasCollisionDetection, ChangeNotifier {
  final Turret playerTurret = Turret(specs: TurretSpecs.getByLevel(1));
  final Turret enemyTurret = Turret(
    specs: TurretSpecs.getByLevel(2),
    isEnemy: true,
  );

  late final AudioPlayer _bgmPlayer;

  double timeSinceLastShot = 0;
  double tiltX = 0;
  final double sensitivity = 20;

  // 救援物資のスポーン管理
  double _reliefSupplyTimer = 0.0;
  double _nextReliefSupplySpawnTime = 0.0;
  final math.Random _random = math.Random();

  final BpmState bpmState;
  final void Function({
    required int level,
    required int hp,
    required double percentX,
    required double percentY,
  })
  onTurretStateChange;
  final void Function() onEnemyHit;

  int turretLevel = 1; // 1:level1, 2:level2, 3:level3
  double stableCounter = 0.0; // isStable=true が続いた秒数

  final ValueNotifier<double> stableProgress = ValueNotifier(0.0);

  bool isGameOver = false;

  ShootingGame({
    required this.bpmState,
    required this.onTurretStateChange,
    required this.onEnemyHit,
  });

  @override
  Future<void> onLoad() async {
    // プリロードして遅延を防ぐ
    _bgmPlayer = AudioPlayer();
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setSource(AssetSource('music/Game_Bgm.mp3'));

    _initTurrets();
    add(playerTurret);
    add(enemyTurret);

    accelerometerEventStream().listen((event) {
      tiltX = event.x;
    });

    // 最初の救援物資スポーン時間を設定
    _nextReliefSupplySpawnTime = 5.0 + _random.nextDouble() * 5.0; // 5〜10秒

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

    // 救援物資のスポーン処理
    if (!isGameOver) {
      _reliefSupplyTimer += dt;
      if (_reliefSupplyTimer >= _nextReliefSupplySpawnTime) {
        _spawnReliefSupply();
        _reliefSupplyTimer = 0.0;
        _nextReliefSupplySpawnTime = 5.0 + _random.nextDouble() * 10.0; // 5〜15秒
      }
    }
  }

  void _spawnReliefSupply() {
    // 画面上部のランダムなX位置からスポーン
    final spawnX = _random.nextDouble() * (size.x - 40); // 救援物資の幅40を考慮
    final reliefSupply = ReliefSupply(
      position: Vector2(spawnX, -60), // 画面上部から開始
    );
    add(reliefSupply);
  }

  void _initTurrets() {
    playerTurret.specs = TurretSpecs.getByLevel(1);
    playerTurret.position = Vector2(
      size.x / 2 - playerTurret.specs.size.x / 2,
      size.y - playerTurret.specs.size.y - 20 - 88,
    );
    playerTurret.resetHp();

    enemyTurret.position = Vector2(
      size.x / 2 - enemyTurret.specs.size.x / 2,
      70,
    );
    enemyTurret.resetHp();
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

  void startGame() {
    _bgmPlayer.seek(Duration.zero);
    _bgmPlayer.resume();
    resumeEngine();
  }

  void endGame({required bool isPlayerWin}) {
    _bgmPlayer.stop();
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
    // 救援物資も全部消す
    children.whereType<ReliefSupply>().forEach((r) => r.removeFromParent());

    _initTurrets();
    // 救援物資タイマーをリセット
    _reliefSupplyTimer = 0.0;
    _nextReliefSupplySpawnTime = 10.0 + _random.nextDouble() * 10.0;
  }

  @override
  void onRemove() {
    // ゲーム終了時に停止して破棄
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    super.onRemove();
  }
}
