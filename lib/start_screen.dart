import 'package:flutter/material.dart';
import 'package:origin_master_2025_flutter/game_screen.dart';
import 'package:uuid/uuid.dart';

import 'lobby_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

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
                        // GameWidget に遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(gameID: Uuid().v4()),
                          ),
                        );
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
                        // ロビーに遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                              LobbyScreen(myUserID: Uuid().v4()),
                          ),
                        );
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
