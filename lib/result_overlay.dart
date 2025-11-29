import 'package:flutter/material.dart';

class ResultOverlay extends StatelessWidget {
  final ResultType type;
  final VoidCallback onPressedBackButton;

  const ResultOverlay({super.key, required this.type, required this.onPressedBackButton});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'あなたの',
                style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontFamily: 'Melonano'
                ),
              ),
              Text(
                type.title,
                style: TextStyle(
                    fontSize: 80,
                    color: Colors.white,
                    fontFamily: 'Melonano'
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: onPressedBackButton,
            child: Image.asset(
              'assets/button_back.png',
              fit: BoxFit.fitWidth,
              width: 142,
            ),
          ),
        ],
      ),
    );
  }
}

enum ResultType {
  win,
  lose;

  String get title {
    switch (this) {
      case ResultType.win:
        return 'かち！';
      case ResultType.lose:
        return 'まけ！';
    }
  }
}