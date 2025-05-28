import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicplayer/services/music_service.dart';
import 'package:musicplayer/services/harmony_audio_service.dart';
import 'package:musicplayer/services/foreground_audio_service.dart';

/// 播放模式
enum PlayMode {
  sequence,  // 顺序播放
  repeat,    // 单曲循环
  shuffle,   // 随机播放
}

/// 音乐播放控制器
class MusicPlayerService extends ChangeNotifier {
  static final MusicPlayerService _instance = MusicPlayerService._internal();
  factory MusicPlayerService() => _instance;
  MusicPlayerService._internal() {
    _initializePlayer();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  final MusicService _musicService = MusicService();
  
  List<Song> _playlist = [];
  int _currentIndex = 0;
  PlayMode _playMode = PlayMode.sequence;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  
  // Getters
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _playlist.isNotEmpty ? _playlist[_currentIndex] : null;
  PlayMode get playMode => _playMode;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get hasNext => _currentIndex < _playlist.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  /// 初始化播放器
  void _initializePlayer() {
    // 监听播放状态变化
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading ||
                   state.processingState == ProcessingState.buffering;
      notifyListeners();
      
      // 更新前台服务
      if (_isPlaying && currentSong != null) {
        ForegroundAudioService.startService(
          message: '正在播放: ${currentSong!.title} - ${currentSong!.artist}',
        );
        ForegroundAudioService.updateNotification(
          title: currentSong!.title,
          message: currentSong!.artist,
        );
      } else {
        ForegroundAudioService.stopService();
      }
    });

    // 监听播放位置变化
    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    // 监听播放时长变化
    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    // 监听播放完成
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onSongCompleted();
      }
    });
  }

  /// 播放歌曲
  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 设置播放列表
      if (playlist != null) {
        _playlist = playlist;
        _currentIndex = _playlist.indexWhere((s) => s.id == song.id);
        if (_currentIndex == -1) {
          _playlist.insert(0, song);
          _currentIndex = 0;
        }
      } else {
        _playlist = [song];
        _currentIndex = 0;
      }

      // 播放音频
      await _audioPlayer.setUrl(song.audioUrl);
      await _audioPlayer.play();

      notifyListeners();
    } catch (e) {
      debugPrint('播放歌曲失败: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 播放/暂停
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// 播放
  Future<void> play() async {
    await _audioPlayer.play();
  }

  /// 暂停
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// 停止
  Future<void> stop() async {
    await _audioPlayer.stop();
    ForegroundAudioService.stopService();
  }

  /// 下一首
  Future<void> next() async {
    if (_playlist.isEmpty) return;

    switch (_playMode) {
      case PlayMode.sequence:
        if (hasNext) {
          _currentIndex++;
        } else {
          _currentIndex = 0; // 循环到第一首
        }
        break;
      case PlayMode.repeat:
        // 单曲循环，不改变索引
        break;
      case PlayMode.shuffle:
        _currentIndex = _getRandomIndex();
        break;
    }

    await _playCurrentSong();
  }

  /// 上一首
  Future<void> previous() async {
    if (_playlist.isEmpty) return;

    switch (_playMode) {
      case PlayMode.sequence:
        if (hasPrevious) {
          _currentIndex--;
        } else {
          _currentIndex = _playlist.length - 1; // 循环到最后一首
        }
        break;
      case PlayMode.repeat:
        // 单曲循环，不改变索引
        break;
      case PlayMode.shuffle:
        _currentIndex = _getRandomIndex();
        break;
    }

    await _playCurrentSong();
  }

  /// 跳转到指定位置
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// 跳转到指定歌曲
  Future<void> skipToSong(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await _playCurrentSong();
    }
  }

  /// 设置播放模式
  void setPlayMode(PlayMode mode) {
    _playMode = mode;
    notifyListeners();
  }

  /// 添加歌曲到播放列表
  void addToPlaylist(Song song) {
    if (!_playlist.any((s) => s.id == song.id)) {
      _playlist.add(song);
      notifyListeners();
    }
  }

  /// 从播放列表移除歌曲
  void removeFromPlaylist(int index) {
    if (index >= 0 && index < _playlist.length) {
      _playlist.removeAt(index);
      
      // 调整当前索引
      if (index < _currentIndex) {
        _currentIndex--;
      } else if (index == _currentIndex) {
        if (_currentIndex >= _playlist.length) {
          _currentIndex = _playlist.length - 1;
        }
        if (_playlist.isNotEmpty) {
          _playCurrentSong();
        } else {
          stop();
        }
      }
      
      notifyListeners();
    }
  }

  /// 清空播放列表
  void clearPlaylist() {
    _playlist.clear();
    _currentIndex = 0;
    stop();
    notifyListeners();
  }

  /// 播放当前歌曲
  Future<void> _playCurrentSong() async {
    if (_playlist.isNotEmpty && _currentIndex < _playlist.length) {
      final song = _playlist[_currentIndex];
      try {
        _isLoading = true;
        notifyListeners();
        
        await _audioPlayer.setUrl(song.audioUrl);
        await _audioPlayer.play();
      } catch (e) {
        debugPrint('播放当前歌曲失败: $e');
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// 歌曲播放完成处理
  void _onSongCompleted() {
    switch (_playMode) {
      case PlayMode.sequence:
        if (hasNext) {
          next();
        } else {
          // 播放列表结束
          stop();
        }
        break;
      case PlayMode.repeat:
        // 单曲循环，重新播放
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
        break;
      case PlayMode.shuffle:
        next(); // 随机下一首
        break;
    }
  }

  /// 获取随机索引
  int _getRandomIndex() {
    if (_playlist.length <= 1) return 0;
    int newIndex;
    do {
      newIndex = (DateTime.now().millisecondsSinceEpoch % _playlist.length);
    } while (newIndex == _currentIndex);
    return newIndex;
  }

  /// 释放资源
  @override
  void dispose() {
    _audioPlayer.dispose();
    ForegroundAudioService.stopService();
    super.dispose();
  }
} 