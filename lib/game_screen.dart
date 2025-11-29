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
          // ゲーム画面
          GameWidget<ShootingGame>(
            game: game,
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
                          },
                          child: Text('リスタート'),
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
                          },
                          child: Text('リスタート'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            },
          ),
          // 下部: BPM/安定性テキスト/グラフ
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BpmOverlay(
              bpmState: bpmState,
              heartBPMWidget: SizedBox(
                width: 64,
                height: 64,
                child: HeartBPM(
                  cameraWidgetWidth: 64,
                  cameraWidgetHeight: 64,
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
        ],
      ),
    );
  }
}
