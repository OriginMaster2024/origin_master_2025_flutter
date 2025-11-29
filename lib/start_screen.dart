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
          Container(color: Colors.black87),
          // 中央にタイトルとボタン
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Shooting Game',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // GameWidget に遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(gameID: 'cpu'),
                      ),
                    );
                  },
                  child: const Text('Start Game'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LobbyScreen(userID: Uuid().v4()),
                      ),
                    );
                  },
                  child: const Text('Enter Lobby'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
