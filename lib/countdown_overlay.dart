import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    HapticFeedback.lightImpact();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter == 1) {
        timer.cancel();
        widget.game.overlays.remove('countdown');
        widget.game.resumeEngine(); // ← ゲーム開始！
      } else {
        setState(() {
          counter -= 1;
        });
        HapticFeedback.lightImpact();
      }
    });
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
}
