import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:origin_master_2025_flutter/result_overlay.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'bpm_overlay.dart';
import 'bpm_state.dart';
import 'countdown_overlay.dart';
import 'heart_bpm.dart';
import 'shooting_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.gameID});

  final String gameID;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final BpmState bpmState;
  late final ShootingGame game;
  late final RealtimeChannel channel;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    bpmState = BpmState();
    channel = Supabase.instance.client.channel('game_${widget.gameID}');

    // 揺れアニメーションの初期化
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

    // 相手のタレットの状態を受信
    channel.onBroadcast(
      event: 'turret_state',
      callback: (payload) {
        final level = payload['level'] as int?;
        final hp = payload['hp'] as int?;
        final centerPercentX = payload['centerPercentX'] as double?;
        final centerPercentY = payload['centerPercentY'] as double?;
        final isFrozen = payload['isFrozen'] as bool?;

        if (level == null ||
            hp == null ||
            centerPercentX == null ||
            centerPercentY == null ||
            isFrozen == null) {
          return;
        }

        // 相手のタレットの状態を更新
        game.updateOpponentTurret(
          level: level,
          hp: hp,
          centerPercentX: centerPercentX,
          centerPercentY: centerPercentY,
          isFrozen: isFrozen,
        );

        // ゲーム終了判定
        if (hp <= 0 && !game.isGameOver) {
          game.endGame(isPlayerWin: true);
        }
      },
    );
    channel.subscribe();

    game = ShootingGame(
      bpmState: bpmState,
      onTurretStateChange: _sendTurretState,
      onEnemyHit: _triggerShake,
    );

    // ← ここでカウントダウン overlay を表示させる
    WidgetsBinding.instance.addPostFrameCallback((_) {
      game.overlays.add('countdown');
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    bpmState.dispose();
    channel.unsubscribe();
    Supabase.instance.client.removeChannel(channel);
    super.dispose();
  }

  /// 敵ヒット時に画面を揺らす
  void _triggerShake() {
    // ビルドフェーズと競合しないよう、次のフレームでアニメーションを開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _shakeController.forward(from: 0.0);
      }
    });
  }

  /// 揺れのオフセットを計算
  double _getShakeOffset(double animationValue) {
    // 減衰しながら揺れる（最大±8px）
    final shakeAmount = 8.0 * (1.0 - animationValue);
    // sin波を使って滑らかな揺れを生成
    // アニメーション値に基づいて複数のsin波を組み合わせて自然な揺れに
    final t = animationValue * math.pi * 8; // 4回揺れる
    return math.sin(t) * shakeAmount;
  }

  /// 自分のタレットの状態を相手に送信
  void _sendTurretState({
    required int level,
    required int hp,
    required double centerPercentX,
    required double centerPercentY,
    required bool isFrozen,
  }) {
    channel.sendBroadcastMessage(
      event: 'turret_state',
      payload: {
        'level': level,
        'hp': hp,
        'centerPercentX': centerPercentX,
        'centerPercentY': centerPercentY,
        'isFrozen': isFrozen,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景画像
          Image.asset(
            'assets/game_background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // ゲーム画面
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_getShakeOffset(_shakeAnimation.value), 0),
                child: GameWidget<ShootingGame>(
                  game: game,
                  backgroundBuilder: (context) {
                    return Image.asset('assets/game_background.png');
                  },
                  overlayBuilderMap: {
                    'countdown': (context, game) =>
                        CountdownOverlay(game: game),
                    'gameOver': (context, game) {
                      return ResultOverlay(
                        type: ResultType.lose,
                        onPressedBackButton: () {
                          game.overlays.remove('gameOver');
                          game.resetGame();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      );
                    },
                    'gameClear': (context, game) {
                      return ResultOverlay(
                        type: ResultType.win,
                        onPressedBackButton: () {
                          game.overlays.remove('gameClear');
                          game.resetGame();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      );
                    },
                  },
                ),
              );
            },
          ),
          // BPM 波形を薄くオーバーレイ
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.3, // 薄くする
              child: BpmOverlay(
                bpmState: bpmState,
                heartBPMWidget: HeartBPM(
                  cameraWidgetWidth: 0,
                  cameraWidgetHeight: 0,
                  alpha: 0.2,
                  onBPM: (bpm) {
                    bpmState.updateBpm(bpm);
                  },
                  onStabilized: (isStable, stdDev) {
                    bpmState.updateStability(isStable, stdDev);
                  },
                  onRawData: (rawData) {
                    bpmState.updateRawData(rawData);
                  },
                ),
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: ListenableBuilder(
                    listenable: bpmState,
                    builder: (context, _) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${bpmState.bpm}'.padLeft(3, ' '),
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Melonano',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'BPM',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Melonano',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // ドット絵風プログレスバー
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: game.isFrozenNotifier,
                    builder: (context, isFrozen, _) {
                      if (isFrozen) {
                        return Text(
                          '40BPMいじょうでかいとう！',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Melonano',
                            color: Colors.red.darken(0.3),
                          ),
                        );
                      }
                      return ValueListenableBuilder<double>(
                        valueListenable: game.stableProgress,
                        builder: (context, progress, _) {
                          return Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF444444), // 暗いグレー背景
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ), // 黒いボーダー
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Stack(
                                children: [
                                  // メインのバー（明るい緑）
                                  Container(color: const Color(0xFF00FF00)),
                                  // ドット絵風ハイライト（上部に白い線）
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: 2,
                                    child: Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
