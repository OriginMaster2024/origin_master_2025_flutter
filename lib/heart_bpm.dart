import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:heart_bpm/heart_bpm.dart';

/// BPM値の安定性を判定するクラス
class BpmStabilityDetector {
  BpmStabilityDetector({required this.windowSize, required this.threshold});

  final int windowSize;
  final double threshold;
  final List<int> _bpmBuffer = [];

  /// BPM値を追加し、安定性を判定する
  /// 戻り値: (isStable, stdDev)
  (bool, double) addBpm(int bpm) {
    _bpmBuffer.add(bpm);
    if (_bpmBuffer.length > windowSize) {
      _bpmBuffer.removeAt(0);
    }

    if (_bpmBuffer.length < windowSize) {
      return (false, 0.0);
    }

    final stdDev = _calculateStdDev(_bpmBuffer);
    final isStable = stdDev <= threshold;
    return (isStable, stdDev);
  }

  /// 標準偏差を計算する
  double _calculateStdDev(List<int> values) {
    if (values.isEmpty) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
        values.length;
    return sqrt(variance);
  }

  /// バッファをクリアする
  void clear() {
    _bpmBuffer.clear();
  }
}

class HeartBPM extends HookWidget {
  const HeartBPM({
    super.key,
    required this.onBPM,
    this.onRawData,
    this.onStabilized,
    this.stabilityWindow = 10,
    this.stabilityThreshold = 10.0,
    this.cameraWidgetWidth,
    this.cameraWidgetHeight,
    this.alpha = 0.2,
  });

  final void Function(int bpm) onBPM;
  final void Function(List<SensorValue> rawData)? onRawData;
  final void Function(bool isStable, double stdDev)? onStabilized;
  final int stabilityWindow;
  final double stabilityThreshold;
  final double? cameraWidgetWidth;
  final double? cameraWidgetHeight;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    final rawData = useState<List<SensorValue>>([]);
    final stabilityDetector = useMemoized(
      () => BpmStabilityDetector(
        windowSize: stabilityWindow,
        threshold: stabilityThreshold,
      ),
      [stabilityWindow, stabilityThreshold],
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = cameraWidgetWidth ?? screenWidth * 0.6;
    final effectiveHeight = cameraWidgetHeight ?? screenWidth * 0.6;

    return HeartBPMDialog(
      context: context,
      alpha: alpha,
      cameraWidgetWidth: effectiveWidth,
      cameraWidgetHeight: effectiveHeight,
      onBPM: (bpm) {
        onBPM(bpm);
        // 安定性を判定
        final (isStable, stdDev) = stabilityDetector.addBpm(bpm);
        onStabilized?.call(isStable, stdDev);
      },
      onRawData: (v) {
        rawData.value = [...rawData.value, v];
        if (rawData.value.length > 100) {
          rawData.value = rawData.value.sublist(1);
        }
        // rawDataを親に通知
        onRawData?.call(rawData.value);
      },
    );
  }
}

/// rawDataをリアルタイムで表示するLine Chartウィジェット
class RawDataLineChart extends StatelessWidget {
  const RawDataLineChart({
    super.key,
    required this.rawData,
    this.height = 200,
    this.lineColor,
    this.backgroundColor,
  });

  final List<SensorValue> rawData;
  final double height;
  final Color? lineColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLineColor = lineColor ?? theme.colorScheme.primary;
    final effectiveBgColor =
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    if (rawData.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: effectiveBgColor,
        ),
        child: const Center(child: Text('データ取得中...')),
      );
    }

    // データポイントを生成
    final spots = <FlSpot>[];
    for (var i = 0; i < rawData.length; i++) {
      spots.add(FlSpot(i.toDouble(), rawData[i].value.toDouble()));
    }

    // Y軸の範囲を計算
    final values = rawData.map((e) => e.value.toDouble()).toList();
    final minY = values.reduce(min);
    final maxY = values.reduce(max);
    final padding = (maxY - minY) * 0.1;

    if (maxY - minY == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: effectiveBgColor,
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: false,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: const FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 40),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (rawData.length - 1).toDouble(),
          minY: minY - padding,
          maxY: maxY + padding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.2,
              color: effectiveLineColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: effectiveLineColor.withValues(alpha: 0.15),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    spot.y.toStringAsFixed(1),
                    TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 0), // アニメーションを無効化してリアルタイム更新
      ),
    );
  }
}
