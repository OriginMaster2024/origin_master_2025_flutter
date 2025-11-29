import 'package:flutter/foundation.dart';
import 'package:heart_bpm/heart_bpm.dart';

/// BPM関連の状態を管理するクラス
/// ShootingGameとFlutter Widget間で共有される
class BpmState extends ChangeNotifier {
  int _bpm = 0;
  bool _isStable = false;
  double _stdDev = 0.0;
  List<SensorValue> _rawData = [];

  /// 現在のBPM値
  int get bpm => _bpm;

  /// BPMが安定しているかどうか
  bool get isStable => _isStable;

  /// 標準偏差
  double get stdDev => _stdDev;

  /// 生データ
  List<SensorValue> get rawData => List.unmodifiable(_rawData);

  /// BPM値を更新
  void updateBpm(int bpm) {
    if (_bpm != bpm) {
      _bpm = bpm;
      notifyListeners();
    }
  }

  /// 安定性を更新
  void updateStability(bool isStable, double stdDev) {
    if (_isStable != isStable || _stdDev != stdDev) {
      _isStable = isStable;
      _stdDev = stdDev;
      notifyListeners();
    }
  }

  /// 生データを更新
  void updateRawData(List<SensorValue> rawData) {
    _rawData = rawData;
    notifyListeners();
  }

  /// すべての状態を一度に更新（通知は1回のみ）
  void updateAll({
    int? bpm,
    bool? isStable,
    double? stdDev,
    List<SensorValue>? rawData,
  }) {
    bool changed = false;

    if (bpm != null && _bpm != bpm) {
      _bpm = bpm;
      changed = true;
    }

    if (isStable != null && _isStable != isStable) {
      _isStable = isStable;
      changed = true;
    }

    if (stdDev != null && _stdDev != stdDev) {
      _stdDev = stdDev;
      changed = true;
    }

    if (rawData != null) {
      _rawData = rawData;
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }
}

