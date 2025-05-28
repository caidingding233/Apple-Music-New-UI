import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:musicplayer/services/apple_music_service.dart';
import 'package:musicplayer/services/auth_service.dart';

class RealAppleMusicPage extends StatefulWidget {
  const RealAppleMusicPage({super.key});

  @override
  State<RealAppleMusicPage> createState() => _RealAppleMusicPageState();
}

class _RealAppleMusicPageState extends State<RealAppleMusicPage> {
  late final WebViewController _webController;
  late final AppleMusicService _appleMusicService;
  bool _isWebViewVisible = true;
  
  @override
  void initState() {
    super.initState();
    _appleMusicService = AppleMusicService();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // 更新加载进度
          },
          onPageStarted: (String url) {
            debugPrint('🌐 页面开始加载: $url');
          },
          onPageFinished: (String url) {
            debugPrint('🌐 页面加载完成: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('🌐 WebView 错误: ${error.description}');
          },
        ),
      )
      ..loadFlutterAsset('assets/musickit/index.html');
    
    // 初始化 Apple Music 服务
    _appleMusicService.initializeWebController(_webController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: const Text(
          '🎵 Apple Music',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // 切换 WebView 显示/隐藏
          IconButton(
            icon: Icon(
              _isWebViewVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isWebViewVisible = !_isWebViewVisible;
              });
            },
            tooltip: _isWebViewVisible ? '隐藏WebView' : '显示WebView',
          ),
          // 退出到登录页
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              context.read<AuthService>().logout();
            },
            tooltip: '退出登录',
          ),
        ],
      ),
      body: Column(
        children: [
          // Apple Music 状态面板
          _buildStatusPanel(),
          
          // 主要内容区域
          Expanded(
            child: _isWebViewVisible 
              ? _buildWebViewSection()
              : _buildNativePlayerSection(),
          ),
        ],
      ),
      // 底部播放控制栏
      bottomNavigationBar: _buildPlaybackControls(),
    );
  }

  /// 构建状态面板
  Widget _buildStatusPanel() {
    return Consumer<AppleMusicService>(
      builder: (context, service, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: service.isError 
                ? [Colors.red.shade800, Colors.red.shade600]
                : service.isAuthorized
                  ? [Colors.green.shade800, Colors.green.shade600]
                  : [Colors.blue.shade800, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    service.isAuthorized ? Icons.check_circle : Icons.info,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service.statusMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (service.isAuthorized) ...[
                const SizedBox(height: 8),
                Text(
                  '✅ 已连接到 Apple Music',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 构建 WebView 部分
  Widget _buildWebViewSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: WebViewWidget(controller: _webController),
    );
  }

  /// 构建原生播放器界面
  Widget _buildNativePlayerSection() {
    return Consumer<AppleMusicService>(
      builder: (context, service, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 当前播放曲目信息
              _buildCurrentTrackInfo(service),
              
              const SizedBox(height: 30),
              
              // 快捷播放按钮
              _buildQuickPlayButtons(service),
              
              const SizedBox(height: 30),
              
              // 播放控制按钮
              _buildPlayControlButtons(service),
              
              const Spacer(),
              
              // 操作提示
              _buildOperationHints(),
            ],
          ),
        );
      },
    );
  }

  /// 构建当前曲目信息
  Widget _buildCurrentTrackInfo(AppleMusicService service) {
    final track = service.currentTrack;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade800.withOpacity(0.3),
            Colors.blue.shade800.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 专辑封面占位符
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade700, Colors.grey.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.music_note,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 歌曲信息
          Text(
            track?.title ?? '未选择歌曲',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          Text(
            track?.artist ?? '-',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // 播放状态指示器
          _buildPlaybackStateIndicator(service.playbackState),
        ],
      ),
    );
  }

  /// 构建播放状态指示器
  Widget _buildPlaybackStateIndicator(AppleMusicPlaybackState state) {
    IconData icon;
    String text;
    Color color;
    
    switch (state) {
      case AppleMusicPlaybackState.playing:
        icon = Icons.play_arrow;
        text = '正在播放';
        color = Colors.green;
        break;
      case AppleMusicPlaybackState.paused:
        icon = Icons.pause;
        text = '已暂停';
        color = Colors.orange;
        break;
      case AppleMusicPlaybackState.loading:
        icon = Icons.hourglass_empty;
        text = '加载中';
        color = Colors.blue;
        break;
      case AppleMusicPlaybackState.stopped:
        icon = Icons.stop;
        text = '已停止';
        color = Colors.red;
        break;
      default:
        icon = Icons.music_off;
        text = '未播放';
        color = Colors.grey;
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 构建快捷播放按钮
  Widget _buildQuickPlayButtons(AppleMusicService service) {
    return Column(
      children: [
        Text(
          '🎵 快捷播放',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickPlayButton(
                '🔥 热门歌曲',
                'Blinding Lights',
                '1490910932',
                service,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickPlayButton(
                '🍉 推荐歌曲',
                'Watermelon Sugar',
                '1463965103',
                service,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建快捷播放按钮
  Widget _buildQuickPlayButton(
    String label,
    String songTitle,
    String songId,
    AppleMusicService service,
  ) {
    return ElevatedButton(
      onPressed: service.isAuthorized 
        ? () => service.playSong(songId, songTitle)
        : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            songTitle,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建播放控制按钮
  Widget _buildPlayControlButtons(AppleMusicService service) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          Icons.play_arrow,
          '播放',
          service.isAuthorized ? service.resume : null,
        ),
        _buildControlButton(
          Icons.pause,
          '暂停',
          service.isAuthorized ? service.pause : null,
        ),
      ],
    );
  }

  /// 构建控制按钮
  Widget _buildControlButton(
    IconData icon,
    String label,
    VoidCallback? onPressed,
  ) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: onPressed != null 
              ? Colors.blue.shade700
              : Colors.grey.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// 构建操作提示
  Widget _buildOperationHints() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '💡 使用提示',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• 点击右上角眼睛图标可切换WebView和原生界面\n'
            '• 在WebView中完成Apple Music登录\n'
            '• 登录后可在原生界面中快捷控制播放',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部播放控制栏
  Widget _buildPlaybackControls() {
    return Consumer<AppleMusicService>(
      builder: (context, service, child) {
        if (!service.isAuthorized) {
          return const SizedBox.shrink();
        }
        
        return Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.8), Colors.grey.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // 当前歌曲信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        service.currentTrack?.title ?? '未选择歌曲',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        service.currentTrack?.artist ?? '-',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // 播放控制按钮
                IconButton(
                  onPressed: service.pause,
                  icon: const Icon(Icons.pause, color: Colors.white),
                ),
                IconButton(
                  onPressed: service.resume,
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
} 