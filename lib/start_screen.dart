import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:origin_master_2025_flutter/game_screen.dart';
import 'package:uuid/uuid.dart';

import 'button_tap_sound_service.dart';
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
          Positioned(
            top: 40,
            left: 0,
            child:
                // FIXME: 上下にアニメーションさせる
                Image.asset(
                  'assets/start_cloud_left.png',
                  fit: BoxFit.fitWidth,
                  width: 256,
                ),
          ),
          Positioned(
            top: -40,
            right: 0,
            child:
                // FIXME: 右に寄せる
                // FIXME: 上下にアニメーションさせる
                Image.asset(
                  'assets/start_cloud_right.png',
                  fit: BoxFit.fitWidth,
                  width: 195,
                ),
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
                        HapticFeedback.mediumImpact();
                        ButtonTapSoundService().playTapSound();

                        // GameWidget に遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GameScreen(gameID: Uuid().v4()),
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
                        HapticFeedback.mediumImpact();
                        ButtonTapSoundService().playTapSound();

                        // ロビーに遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute<bool?>(
                            builder: (context) => LobbyScreen(
                              myUserID: Uuid().v4(),
                              bgmPlayer: _bgmPlayer,
                            ),
                          ),
                        ).then((skipPlayingBgm) {
                          if (skipPlayingBgm == null || !skipPlayingBgm) {
                            // ゲーム画面から戻ってきたタイミングで BGM を再生
                            _playBgm();
                          }
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
            ),
          ),
        ],
      ),
    );
  }
}
