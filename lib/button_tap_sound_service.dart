import 'package:audioplayers/audioplayers.dart';

class ButtonTapSoundService {
  // 1. シングルトンのインスタンス
  static final ButtonTapSoundService _instance = ButtonTapSoundService._internal();

  factory ButtonTapSoundService() {
    return _instance;
  }

  ButtonTapSoundService._internal();

  // 2. AudioPlayer インスタンス
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 3. 効果音ファイルへのパスを定数として定義
  static const String _tapSoundPath = "music/Button_Tap.mp3";

  // 4. 初期化メソッド (効果音のロード)
  // アプリ起動時など、一度だけ呼び出します。
  Future<void> initSounds() async {
    // プレイヤーのモードを「ローカルファイル/アセット」に設定
    _audioPlayer.setReleaseMode(ReleaseMode.release);

    // 効果音をプリロード（キャッシュ）し、再生準備を整える
    await _audioPlayer.setSource(AssetSource(_tapSoundPath));
  }

  // 5. 効果音再生メソッド
  void playTapSound() async {
    // 効果音は短いため、常に最初から再生するためにseek(Duration.zero)を使用し、
    // 最後に再生モード（ReleaseMode.stop）で再生を停止させます。
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.seek(Duration.zero);
    await _audioPlayer.resume();
  }
}