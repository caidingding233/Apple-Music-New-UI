import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Apple Music 播放状态
enum AppleMusicPlaybackState {
  none,
  loading,
  playing,
  paused,
  stopped,
  completed,
  seeking,
  waiting
}

/// Apple Music 曲目信息
class AppleMusicTrack {
  final String? title;
  final String? artist;
  final String? artwork;
  final String? songId;

  AppleMusicTrack({
    this.title,
    this.artist,
    this.artwork,
    this.songId,
  });

  factory AppleMusicTrack.fromJson(Map<String, dynamic> json) {
    return AppleMusicTrack(
      title: json['title'],
      artist: json['artist'],
      artwork: json['artwork'],
      songId: json['songId'],
    );
  }
}

/// Apple Music 服务
class AppleMusicService extends ChangeNotifier {
  static final AppleMusicService _instance = AppleMusicService._internal();
  factory AppleMusicService() => _instance;
  AppleMusicService._internal();

  // WebView 控制器
  WebViewController? _webController;
  
  // 状态管理
  bool _isInitialized = false;
  bool _isAuthorized = false;
  String? _userToken;
  String _statusMessage = '准备初始化...';
  bool _isError = false;
  
  // 播放状态
  AppleMusicPlaybackState _playbackState = AppleMusicPlaybackState.none;
  AppleMusicTrack? _currentTrack;
  
  // 流控制器
  final StreamController<String> _statusController = StreamController<String>.broadcast();
  final StreamController<AppleMusicPlaybackState> _playbackController = StreamController<AppleMusicPlaybackState>.broadcast();
  final StreamController<AppleMusicTrack?> _trackController = StreamController<AppleMusicTrack?>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAuthorized => _isAuthorized;
  String? get userToken => _userToken;
  String get statusMessage => _statusMessage;
  bool get isError => _isError;
  AppleMusicPlaybackState get playbackState => _playbackState;
  AppleMusicTrack? get currentTrack => _currentTrack;
  
  // Streams
  Stream<String> get statusStream => _statusController.stream;
  Stream<AppleMusicPlaybackState> get playbackStream => _playbackController.stream;
  Stream<AppleMusicTrack?> get trackStream => _trackController.stream;

  /// 初始化 WebView 控制器
  void initializeWebController(WebViewController controller) {
    _webController = controller;
    _setupJavaScriptChannels();
    _isInitialized = true;
    _updateStatus('WebView 控制器已初始化');
    notifyListeners();
  }

  /// 设置 JavaScript 通道
  void _setupJavaScriptChannels() {
    if (_webController == null) return;

    // 认证状态通道
    _webController!.addJavaScriptChannel(
      'onAuth',
      onMessageReceived: (JavaScriptMessage message) {
        _handleAuthResult(message.message);
      },
    );

    // 状态更新通道
    _webController!.addJavaScriptChannel(
      'onStatusUpdate',
      onMessageReceived: (JavaScriptMessage message) {
        _handleStatusUpdate(message.message);
      },
    );

    // 播放状态通道
    _webController!.addJavaScriptChannel(
      'onPlaybackStateChange',
      onMessageReceived: (JavaScriptMessage message) {
        _handlePlaybackStateChange(message.message);
      },
    );

    // 曲目变化通道
    _webController!.addJavaScriptChannel(
      'onTrackChange',
      onMessageReceived: (JavaScriptMessage message) {
        _handleTrackChange(message.message);
      },
    );

    // 播放开始通道
    _webController!.addJavaScriptChannel(
      'onPlaybackStart',
      onMessageReceived: (JavaScriptMessage message) {
        _handlePlaybackStart(message.message);
      },
    );

    // 退出登录通道
    _webController!.addJavaScriptChannel(
      'onLogout',
      onMessageReceived: (JavaScriptMessage message) {
        _handleLogout();
      },
    );
  }

  /// 处理认证结果
  void _handleAuthResult(String message) {
    try {
      final data = jsonDecode(message);
      
      if (data['isAuthorized'] == true) {
        _userToken = data['userToken'];
        _isAuthorized = true;
        _updateStatus('✅ Apple Music 登录成功！');
        
        if (kDebugMode) {
          print('🎵 Apple Music 认证成功，User Token: ${_userToken?.substring(0, 20)}...');
        }
      } else {
        _isAuthorized = false;
        _userToken = null;
        _updateStatus('❌ Apple Music 登录失败: ${data['error'] ?? '未知错误'}', true);
      }
      
      notifyListeners();
    } catch (e) {
      _updateStatus('❌ 处理认证结果失败: $e', true);
    }
  }

  /// 处理状态更新
  void _handleStatusUpdate(String message) {
    try {
      final data = jsonDecode(message);
      _updateStatus(data['message'], data['isError'] ?? false);
    } catch (e) {
      _updateStatus(message);
    }
  }

  /// 处理播放状态变化
  void _handlePlaybackStateChange(String message) {
    try {
      final data = jsonDecode(message);
      final stateValue = data['state'];
      
      // MusicKit JS 播放状态映射
      switch (stateValue) {
        case 0: // none
          _playbackState = AppleMusicPlaybackState.none;
          break;
        case 1: // loading
          _playbackState = AppleMusicPlaybackState.loading;
          break;
        case 2: // playing
          _playbackState = AppleMusicPlaybackState.playing;
          break;
        case 3: // paused
          _playbackState = AppleMusicPlaybackState.paused;
          break;
        case 4: // stopped
          _playbackState = AppleMusicPlaybackState.stopped;
          break;
        case 5: // ended
          _playbackState = AppleMusicPlaybackState.completed;
          break;
        case 6: // seeking
          _playbackState = AppleMusicPlaybackState.seeking;
          break;
        case 7: // waiting
          _playbackState = AppleMusicPlaybackState.waiting;
          break;
        default:
          _playbackState = AppleMusicPlaybackState.none;
      }
      
      _playbackController.add(_playbackState);
      notifyListeners();
      
      if (kDebugMode) {
        print('🎵 播放状态变化: $_playbackState');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ 处理播放状态变化失败: $e');
      }
    }
  }

  /// 处理曲目变化
  void _handleTrackChange(String message) {
    try {
      final data = jsonDecode(message);
      _currentTrack = AppleMusicTrack.fromJson(data);
      _trackController.add(_currentTrack);
      notifyListeners();
      
      if (kDebugMode) {
        print('🎵 当前播放: ${_currentTrack?.title} - ${_currentTrack?.artist}');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ 处理曲目变化失败: $e');
      }
    }
  }

  /// 处理播放开始
  void _handlePlaybackStart(String message) {
    try {
      final data = jsonDecode(message);
      final songId = data['songId'];
      final songTitle = data['songTitle'];
      
      if (kDebugMode) {
        print('🎵 开始播放: $songTitle ($songId)');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ 处理播放开始失败: $e');
      }
    }
  }

  /// 处理退出登录
  void _handleLogout() {
    _isAuthorized = false;
    _userToken = null;
    _currentTrack = null;
    _playbackState = AppleMusicPlaybackState.none;
    _updateStatus('👋 已退出 Apple Music');
    notifyListeners();
  }

  /// 更新状态
  void _updateStatus(String message, [bool isError = false]) {
    _statusMessage = message;
    _isError = isError;
    _statusController.add(message);
    notifyListeners();
    
    if (kDebugMode) {
      print('🎵 状态: $message');
    }
  }

  /// 播放指定歌曲
  Future<void> playSong(String songId, [String? songTitle]) async {
    if (_webController == null) {
      _updateStatus('❌ WebView 未初始化', true);
      return;
    }

    if (!_isAuthorized) {
      _updateStatus('❌ 请先登录 Apple Music', true);
      return;
    }

    try {
      final title = songTitle ?? songId;
      await _webController!.runJavaScript(
        "playAppleMusicSong('$songId', '$title')"
      );
      
      if (kDebugMode) {
        print('🎵 请求播放: $title ($songId)');
      }
    } catch (e) {
      _updateStatus('❌ 播放请求失败: $e', true);
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    if (_webController == null) return;

    try {
      await _webController!.runJavaScript("pauseAppleMusic()");
    } catch (e) {
      _updateStatus('❌ 暂停失败: $e', true);
    }
  }

  /// 恢复播放
  Future<void> resume() async {
    if (_webController == null) return;

    try {
      await _webController!.runJavaScript("resumeAppleMusic()");
    } catch (e) {
      _updateStatus('❌ 恢复播放失败: $e', true);
    }
  }

  /// 获取播放状态
  Future<String?> getPlaybackState() async {
    if (_webController == null) return null;

    try {
      final result = await _webController!.runJavaScriptReturningResult("getPlaybackState()");
      return result.toString();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 获取播放状态失败: $e');
      }
      return null;
    }
  }

  /// 释放资源
  @override
  void dispose() {
    _statusController.close();
    _playbackController.close();
    _trackController.close();
    super.dispose();
  }
} 