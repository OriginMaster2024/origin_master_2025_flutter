import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:origin_master_2025_flutter/shooting_game.dart';
import 'package:origin_master_2025_flutter/turret.dart';

void main() {
  runApp(
    GameWidget(
      game: ShootingGame(playerSpec: smallFastTurret, enemySpec: bigSlowTurret),
    ),
  );
}
