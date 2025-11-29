import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:origin_master_2025_flutter/bpm_overlay.dart';
import 'package:origin_master_2025_flutter/bpm_state.dart';
import 'package:origin_master_2025_flutter/heart_bpm.dart';
import 'package:origin_master_2025_flutter/shooting_game.dart';
import 'package:origin_master_2025_flutter/turret.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('SUPABASE_URL or SUPABASE_ANON_KEY is not set');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 40),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shooting Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

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
    game = ShootingGame(
      playerSpec: smallFastTurret,
      enemySpec: bigSlowTurret,
      bpmState: bpmState,
    );
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
          GameWidget(game: game),
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
