import 'package:flutter/material.dart';

class ResultOverlay extends StatelessWidget {
  final ResultType type;

  const ResultOverlay({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

enum ResultType {
  win,
  lose;
}