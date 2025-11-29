import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shooting_game.dart';

class CountdownOverlay extends StatefulWidget {
  final ShootingGame game;

  const CountdownOverlay({super.key, required this.game});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int counter = 3;
  final AudioPlayer _audioPlayer = AudioPlayer(); // 1つのプレイヤーを使い回す
  late final AssetSource _countdownSound;

  @override
  void initState() {
    super.initState();

    // 音源を事前ロード
    _countdownSound = AssetSource('music/Count_Down.mp3');
    _audioPlayer.setSource(_countdownSound);

    _startCountdown();
  }

  void _startCountdown() {
    _playSoundAndHaptic(); // 最初のカウント音

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter == 1) {
        timer.cancel();
        widget.game.overlays.remove('countdown');
        widget.game.resumeEngine(); // ← ゲーム開始！
      } else {
        _playSoundAndHaptic();
        setState(() {
          counter -= 1;
        });
      }
    });
  }

  void _playSoundAndHaptic() {
    // 音を鳴らす
    _audioPlayer.play(_countdownSound);
    // バイブ
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$counter',
        style: const TextStyle(
          fontSize: 120,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
