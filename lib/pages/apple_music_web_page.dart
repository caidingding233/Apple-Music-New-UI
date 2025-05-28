 import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';

/// Apple Music 网页版嵌入页面
/// 通过 WebView 嵌入官方 music.apple.com，实现完整版歌曲播放
class AppleMusicWebPage extends StatefulWidget {
  const AppleMusicWebPage({super.key});

  @override
  State<AppleMusicWebPage> createState() => _AppleMusicWebPageState();
}

class _AppleMusicWebPageState extends State<AppleMusicWebPage> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  String currentTitle = "Apple Music";
  bool canGoBack = false;
  bool canGoForward = false;
  
  // 播放状态控制
  bool isPlaying = false;
  String currentTrack = "未播放";
  String currentArtist = "";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => webViewController?.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _navigateToHome(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 加载进度条
          if (isLoading)
            const LinearProgressIndicator(
              color: Color(0xFFFA233B), // Apple Music 红色
              backgroundColor: Colors.grey,
            ),
          
          // WebView 主体
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://music.apple.com"),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                sharedCookiesEnabled: true,
                clearCache: false,
                cacheEnabled: true,
                supportZoom: true,
                useOnDownloadStart: true,
                useShouldInterceptRequest: true,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
                _setupWebViewBridge();
              },
              onLoadStart: (controller, url) {
                setState(() {
                  isLoading = true;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  isLoading = false;
                });
                await _updateNavigationState();
                await _injectMusicControlScript();
              },
              onTitleChanged: (controller, title) {
                setState(() {
                  currentTitle = title ?? "Apple Music";
                });
              },
              shouldInterceptRequest: (controller, request) async {
                // 可以在这里拦截音频流 URL
                final url = request.url.toString();
                if (url.contains('.m3u8') || url.contains('.mp3') || url.contains('.aac')) {
                  print('音频流 URL: $url');
                  // 这里可以保存 URL 用于原生播放器
                }
                return null;
              },
              onConsoleMessage: (controller, consoleMessage) {
                // 监听网页端的控制台消息，获取播放状态
                final message = consoleMessage.message;
                if (message.startsWith('MUSIC_PLAYER_STATE:')) {
                  _handleMusicStateChange(message);
                }
              },
            ),
          ),
          
          // 底部播放控制栏
          _buildMusicControlBar(),
        ],
      ),
      // 悬浮操作按钮
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePlayPause,
        backgroundColor: const Color(0xFFFA233B),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }
  
  /// 设置 WebView 与 Flutter 的桥接
  void _setupWebViewBridge() {
    // 注册 JavaScript 处理器
    webViewController?.addJavaScriptHandler(
      handlerName: 'FlutterMusicControl',
      callback: (args) {
        // 处理来自网页的播放控制消息
        if (args.isNotEmpty) {
          final action = args[0] as String;
          _handleWebMusicAction(action);
        }
      },
    );
  }
  
  /// 注入音乐控制脚本
  Future<void> _injectMusicControlScript() async {
    const script = '''
      // 监听 MusicKit 播放状态变化
      if (typeof MusicKit !== 'undefined') {
        const musicKit = MusicKit.getInstance();
        
        // 监听播放状态
        musicKit.addEventListener('playbackStateDidChange', function(event) {
          const state = {
            isPlaying: musicKit.isPlaying,
            currentSong: musicKit.nowPlayingItem ? {
              title: musicKit.nowPlayingItem.title,
              artist: musicKit.nowPlayingItem.artistName,
              artwork: musicKit.nowPlayingItem.artwork ? musicKit.nowPlayingItem.artwork.url : null
            } : null
          };
          console.log('MUSIC_PLAYER_STATE:' + JSON.stringify(state));
        });
        
        // 创建播放控制函数
        window.flutterMusicControl = {
          play: function() {
            musicKit.play();
          },
          pause: function() {
            musicKit.pause();
          },
          next: function() {
            musicKit.skipToNextItem();
          },
          previous: function() {
            musicKit.skipToPreviousItem();
          },
          getState: function() {
            return {
              isPlaying: musicKit.isPlaying,
              currentSong: musicKit.nowPlayingItem
            };
          }
        };
      }
      
      // 定期检查播放状态
      setInterval(function() {
        if (typeof MusicKit !== 'undefined' && MusicKit.getInstance()) {
          const musicKit = MusicKit.getInstance();
          const state = {
            isPlaying: musicKit.isPlaying,
            currentSong: musicKit.nowPlayingItem ? {
              title: musicKit.nowPlayingItem.title,
              artist: musicKit.nowPlayingItem.artistName
            } : null
          };
          console.log('MUSIC_PLAYER_STATE:' + JSON.stringify(state));
        }
      }, 2000);
    ''';
    
    await webViewController?.evaluateJavascript(source: script);
  }
  
  /// 处理音乐状态变化
  void _handleMusicStateChange(String message) {
    try {
      final json = message.replaceFirst('MUSIC_PLAYER_STATE:', '');
      // 这里可以解析 JSON 并更新 UI 状态
      print('音乐状态更新: $json');
      // TODO: 解析并更新播放状态
    } catch (e) {
      print('解析音乐状态失败: $e');
    }
  }
  
  /// 处理来自网页的音乐操作
  void _handleWebMusicAction(String action) {
    switch (action) {
      case 'play':
        setState(() => isPlaying = true);
        break;
      case 'pause':
        setState(() => isPlaying = false);
        break;
      case 'next':
        _nextTrack();
        break;
      case 'previous':
        _previousTrack();
        break;
    }
  }
  
  /// 更新导航状态
  Future<void> _updateNavigationState() async {
    final back = await webViewController?.canGoBack() ?? false;
    final forward = await webViewController?.canGoForward() ?? false;
    setState(() {
      canGoBack = back;
      canGoForward = forward;
    });
  }
  
  /// 导航到主页
  void _navigateToHome() {
    webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri("https://music.apple.com")),
    );
  }
  
  /// 切换播放/暂停
  void _togglePlayPause() {
    if (isPlaying) {
      _pauseMusic();
    } else {
      _playMusic();
    }
  }
  
  /// 播放音乐
  void _playMusic() {
    webViewController?.evaluateJavascript(source: '''
      if (window.flutterMusicControl) {
        window.flutterMusicControl.play();
      }
    ''');
    setState(() => isPlaying = true);
  }
  
  /// 暂停音乐
  void _pauseMusic() {
    webViewController?.evaluateJavascript(source: '''
      if (window.flutterMusicControl) {
        window.flutterMusicControl.pause();
      }
    ''');
    setState(() => isPlaying = false);
  }
  
  /// 下一首
  void _nextTrack() {
    webViewController?.evaluateJavascript(source: '''
      if (window.flutterMusicControl) {
        window.flutterMusicControl.next();
      }
    ''');
  }
  
  /// 上一首
  void _previousTrack() {
    webViewController?.evaluateJavascript(source: '''
      if (window.flutterMusicControl) {
        window.flutterMusicControl.previous();
      }
    ''');
  }
  
  /// 构建音乐控制栏
  Widget _buildMusicControlBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black87,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // 专辑封面占位
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.music_note,
                color: Colors.white54,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            
            // 歌曲信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentTrack,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentArtist.isEmpty ? "Apple Music" : currentArtist,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // 播放控制按钮
            Row(
              children: [
                IconButton(
                  onPressed: _previousTrack,
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                ),
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                IconButton(
                  onPressed: _nextTrack,
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}