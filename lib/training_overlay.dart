import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'button_tap_sound_service.dart';

class TrainingOvelay extends StatelessWidget {
  const TrainingOvelay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Center(
          child: Text(
            'BPMをあんていさせて\nパワーアップ！',
            style: TextStyle(fontSize: 16, fontFamily: 'Melonano'),
            textAlign: TextAlign.center,
          ),
        ),

        Positioned(
          left: 16,
          top: 80,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ButtonTapSoundService().playTapSound();

              Navigator.pop(context);
            },
            child: Image.asset(
              'assets/button_back.png',
              fit: BoxFit.fitWidth,
              width: 96,
            ),
          ),
        ),
      ],
    );
  }
}
