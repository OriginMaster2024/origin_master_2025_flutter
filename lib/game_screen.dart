import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'bpm_overlay.dart';
import 'bpm_state.dart';
import 'heart_bpm.dart';
import 'shooting_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.gameID});

  final String gameID;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final BpmState bpmState;
  late final ShootingGame game;
  late final RealtimeChannel channel;

  @override
  void initState() {
    super.initState();
    bpmState = BpmState();
    channel = Supabase.instance.client.channel('game_${widget.gameID}');

    // 相手のタレットの状態を受信
    channel.onBroadcast(
      event: 'turret_state',
      callback: (payload) {
        final level = payload['level'] as int?;
        final hp = payload['hp'] as int?;
        final percentX = payload['percentX'] as double?;
        final percentY = payload['percentY'] as double?;

        if (level == null ||
            hp == null ||
            percentX == null ||
            percentY == null) {
          return;
        }

        // 相手のタレットの状態を更新
        game.updateOpponentTurret(
          level: level,
          hp: hp,
          percentX: percentX,
          percentY: percentY,
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
    );
  }

  @override
  void dispose() {
    bpmState.dispose();
    channel.unsubscribe();
    Supabase.instance.client.removeChannel(channel);
    super.dispose();
  }

  /// 自分のタレットの状態を相手に送信
  void _sendTurretState({
    required int level,
    required int hp,
    required double percentX,
    required double percentY,
  }) {
    channel.sendBroadcastMessage(
      event: 'turret_state',
      payload: {
        'level': level,
        'hp': hp,
        'percentX': percentX,
        'percentY': percentY,
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
          GameWidget<ShootingGame>(
            game: game,
            backgroundBuilder: (context) {
              return Image.asset('assets/game_background.png');
            },
            overlayBuilderMap: {
              'gameOver': (context, game) {
                return Center(
                  child: Container(
                    color: Colors.black54,
                    child: AlertDialog(
                      title: Text('ゲームオーバー'),
                      content: Text('敵の勝ちです！'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            game.overlays.remove('gameOver');
                            game.resumeEngine();
                            game.resetGame();
                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          },
                          child: Text('ホームへ戻る'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              'gameClear': (context, game) {
                return Center(
                  child: Container(
                    color: Colors.black54,
                    child: AlertDialog(
                      title: Text('ゲームクリア'),
                      content: Text('あなたの勝ちです！'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            game.overlays.remove('gameClear');
                            game.resumeEngine();
                            game.resetGame();
                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          },
                          child: Text('ホームへ戻る'),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
            child: ValueListenableBuilder<double>(
              valueListenable: game.stableProgress,
              builder: (context, progress, _) {
                return Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
