import 'dart:async';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// 鸿蒙平台特性插件
class FlutterOhosPlugin extends PlatformInterface {
  FlutterOhosPlugin() : super(token: _token);

  static final Object _token = Object();

  static FlutterOhosPlugin _instance = FlutterOhosPlugin();
  static FlutterOhosPlugin get instance => _instance;

  static const MethodChannel _channel = MethodChannel('flutter_ohos_plugin');

  /// 检查是否运行在鸿蒙系统上
  static Future<bool> get isRunningOnHarmonyOS async {
    final bool result = await _channel.invokeMethod('isRunningOnHarmonyOS');
    return result;
  }

  /// 获取设备类型
  static Future<String> get deviceType async {
    final String result = await _channel.invokeMethod('getDeviceType');
    return result;
  }

  /// 初始化媒体控制中心
  static Future<void> initMediaController() async {
    await _channel.invokeMethod('initMediaController');
  }

  /// 更新媒体信息
  static Future<void> updateMediaInfo({
    required String title,
    required String artist,
    required String album,
    String? artworkUrl,
    required int duration,
    required int position,
    required bool isPlaying,
  }) async {
    await _channel.invokeMethod('updateMediaInfo', {
      'title': title,
      'artist': artist,
      'album': album,
      'artworkUrl': artworkUrl,
      'duration': duration,
      'position': position,
      'isPlaying': isPlaying,
    });
  }

  /// 注册媒体控制事件监听
  static Stream<String> get mediaControlEvents {
    return _channel.invokeMethod('registerMediaControlEvents').asStream().cast<String>();
  }

  /// 设置播放状态
  static Future<void> setPlaybackState({
    required bool isPlaying,
    required int position,
    required double speed,
  }) async {
    await _channel.invokeMethod('setPlaybackState', {
      'isPlaying': isPlaying,
      'position': position,
      'speed': speed,
    });
  }

  /// 适配鸿蒙状态栏
  static Future<void> adaptStatusBar() async {
    await _channel.invokeMethod('adaptStatusBar');
  }

  /// 获取屏幕方向和尺寸信息用于多终端适配
  static Future<Map<String, dynamic>> getScreenInfo() async {
    final Map<String, dynamic> result = await _channel.invokeMethod('getScreenInfo');
    return result;
  }
} 