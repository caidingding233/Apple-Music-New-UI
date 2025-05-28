import 'dart:async';
import 'package:flutter/services.dart';

/// 前台音频服务管理器
/// 解决锁屏时音频停止的问题
class ForegroundAudioService {
  static const MethodChannel _channel = MethodChannel('foreground_audio_service');
  
  static bool _isServiceRunning = false;
  
  /// 启动前台服务
  static Future<void> startService({
    String message = "音乐播放中...",
  }) async {
    if (_isServiceRunning) return;
    
    try {
      await _channel.invokeMethod('startService', {
        'message': message,
        'title': 'Apple Music 鸿蒙版',
        'channelId': 'music_player_channel',
        'notificationId': 1001,
      });
      _isServiceRunning = true;
    } catch (e) {
      print('启动前台服务失败: $e');
    }
  }
  
  /// 停止前台服务
  static Future<void> stopService() async {
    if (!_isServiceRunning) return;
    
    try {
      await _channel.invokeMethod('stopService');
      _isServiceRunning = false;
    } catch (e) {
      print('停止前台服务失败: $e');
    }
  }
  
  /// 更新服务通知
  static Future<void> updateNotification({
    required String title,
    required String message,
  }) async {
    if (!_isServiceRunning) return;
    
    try {
      await _channel.invokeMethod('updateNotification', {
        'title': title,
        'message': message,
      });
    } catch (e) {
      print('更新通知失败: $e');
    }
  }
  
  /// 检查服务状态
  static bool get isRunning => _isServiceRunning;
} 