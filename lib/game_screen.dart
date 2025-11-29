import 'package:flame/game.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    bpmState = BpmState();
    game = ShootingGame(bpmState: bpmState);
  }

  @override
  void dispose() {
    bpmState.dispose();
    super.dispose();
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
                            Navigator.pop(context);
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
                            Navigator.pop(context);
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
            child: AnimatedBuilder(
              animation: game,
              builder: (context, child) {
                final progress = game.stableProgress;
                return Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress, // 0.0〜1.0
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
