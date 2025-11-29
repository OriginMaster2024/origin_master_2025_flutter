import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:origin_master_2025_flutter/game_screen.dart';
import 'package:uuid/uuid.dart';

import 'lobby_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}
class _StartScreenState extends State<StartScreen> {
  late final AudioPlayer _bgmPlayer;

  @override
  void initState() {
    super.initState();
    _bgmPlayer = AudioPlayer();
    _playBgm();
  }

  Future<void> _playBgm() async {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _bgmPlayer.setSource(AssetSource('music/Home_Bgm.mp3'));
    _bgmPlayer.seek(Duration.zero);
    await _bgmPlayer.resume();
  }

  @override
  void dispose() {
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景
          Image.asset(
            'assets/start_background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // FIXME: 上下にアニメーションさせる
          Image.asset(
            'assets/start_cloud_left.png',
            fit: BoxFit.fitWidth,
            width: 256,
          ),
          // FIXME: 右に寄せる
          // FIXME: 上下にアニメーションさせる
          Image.asset(
            'assets/start_cloud_right.png',
            fit: BoxFit.fitWidth,
            width: 195,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/start_title.png',
                  fit: BoxFit.fitWidth,
                  width: 300,
                ),
                const SizedBox(height: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _bgmPlayer.stop();

                        // GameWidget に遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(gameID: Uuid().v4()),
                          ),
                        ).then((_) {
                          // ゲーム画面から戻ってきたタイミングで BGM を再生
                          _playBgm();
                        });
                      },
                      child: Image.asset(
                        'assets/button_training.png',
                        fit: BoxFit.fitWidth,
                        width: 142,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        _bgmPlayer.stop();

                        // ロビーに遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                              LobbyScreen(myUserID: Uuid().v4()),
                          ),
                        ).then((_) {
                          // ゲーム画面から戻ってきたタイミングで BGM を再生
                          _playBgm();
                        });
                      },
                      child: Image.asset(
                        'assets/button_battle.png',
                        fit: BoxFit.fitWidth,
                        width: 142,
                      ),
                    ),
                  ],
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}
