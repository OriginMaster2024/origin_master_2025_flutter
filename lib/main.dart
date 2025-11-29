import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:origin_master_2025_flutter/shooting_game.dart';
import 'package:origin_master_2025_flutter/turret_specs.dart';

void main() {
  runApp(
    GameWidget(
      game: ShootingGame(turretSpecs: smallFastTurret),
    ),
  );
}
