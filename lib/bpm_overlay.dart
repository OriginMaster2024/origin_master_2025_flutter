import 'package:flutter/material.dart';
import 'package:origin_master_2025_flutter/bpm_state.dart';
import 'package:origin_master_2025_flutter/heart_bpm.dart';

/// ゲーム画面上にBPM情報を表示するオーバーレイウィジェット
class BpmOverlay extends StatelessWidget {
  const BpmOverlay({super.key, required this.bpmState, this.heartBPMWidget});

  final BpmState bpmState;
  final Widget? heartBPMWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: bpmState,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // HeartBPM
            if (heartBPMWidget != null) ...[
              heartBPMWidget!,
              const SizedBox(width: 0),
            ],

            // BPM情報
            SizedBox(
              width: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BPM値
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${bpmState.bpm}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'BPM',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  // 安定性
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 0,
                        height: 0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bpmState.isStable
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        bpmState.isStable ? '安定' : '不安定',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // RawDataLineChart
            // const SizedBox(width: 12),
            Expanded(
              child: RawDataLineChart(
                rawData: bpmState.rawData,
                height: 64,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        );
      },
    );
  }
}
