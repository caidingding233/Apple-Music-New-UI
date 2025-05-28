import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:flutter_ohos_plugin/flutter_ohos_plugin.dart';
import 'foreground_audio_service.dart';

/// 鸿蒙音频处理器（支持后台播放）
class HarmonyAudioHandler extends BaseAudioHandler {
  static HarmonyAudioHandler? _instance;
  static HarmonyAudioHandler get instance => _instance ??= HarmonyAudioHandler._internal();
  
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;
  
  HarmonyAudioHandler._internal();
  
  /// 初始化音频服务
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // 设置音频会话
      await _player.setAudioSource(AudioSource.uri(Uri.parse('asset:///assets/silence.mp3')));
      
      // 监听播放状态变化
      _player.playbackEventStream.listen((event) {
        final playing = _player.playing;
        playbackState.add(PlaybackState(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: 0,
        ));
      });
      
      _isInitialized = true;
      print('鸿蒙音频服务初始化完成');
    } catch (e) {
      print('音频服务初始化失败: $e');
    }
  }
  
  @override
  Future<void> play() async {
    // 启动前台服务确保后台播放
    await ForegroundAudioService.startService(
      message: "正在播放音乐",
    );
    
    await _player.play();
  }
  
  @override
  Future<void> pause() async {
    await _player.pause();
    
    // 暂停时可以选择停止前台服务
    // await ForegroundAudioService.stopService();
  }
  
  @override
  Future<void> stop() async {
    await _player.stop();
    await ForegroundAudioService.stopService();
  }
  
  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }
  
  @override
  Future<void> skipToNext() async {
    // 实现下一首逻辑
    print('跳转到下一首');
  }
  
  @override
  Future<void> skipToPrevious() async {
    // 实现上一首逻辑  
    print('跳转到上一首');
  }
  
  /// 播放指定音频文件
  Future<void> playAudio(String url) async {
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await play();
      
      // 更新通知信息
      await ForegroundAudioService.updateNotification(
        title: "Apple Music 鸿蒙版",
        message: "正在播放音乐",
      );
    } catch (e) {
      print('播放音频失败: $e');
    }
  }
  
  /// 获取当前播放位置
  Duration get position => _player.position;
  
  /// 获取音频总时长
  Duration? get duration => _player.duration;
  
  /// 获取播放状态
  bool get isPlaying => _player.playing;
  
  /// 清理资源
  @override
  Future<void> onTaskRemoved() async {
    await _player.dispose();
    await ForegroundAudioService.stopService();
    super.onTaskRemoved();
  }
  
  /// 手动清理资源方法
  Future<void> dispose() async {
    await _player.dispose();
    await ForegroundAudioService.stopService();
  }
} 