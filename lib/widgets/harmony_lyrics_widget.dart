import 'package:flutter/material.dart';
import 'dart:ui';

/// 歌词行数据模型
class LyricLine {
  final Duration timestamp;
  final String text;
  final Duration? endTime;

  LyricLine({
    required this.timestamp,
    required this.text,
    this.endTime,
  });
}

/// 鸿蒙适配的歌词显示组件（简化版）
class HarmonyLyricsWidget extends StatefulWidget {
  final List<LyricLine> lyrics;
  final Duration currentPosition;
  final bool isPlaying;
  final Color? textColor;
  final Color? highlightColor;
  final String? backgroundImageUrl;

  const HarmonyLyricsWidget({
    super.key,
    required this.lyrics,
    required this.currentPosition,
    this.isPlaying = false,
    this.textColor,
    this.highlightColor,
    this.backgroundImageUrl,
  });

  @override
  State<HarmonyLyricsWidget> createState() => _HarmonyLyricsWidgetState();
}

class _HarmonyLyricsWidgetState extends State<HarmonyLyricsWidget>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  int _currentLineIndex = -1;
  double _itemHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // 淡入淡出动画控制器
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 缩放动画控制器
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HarmonyLyricsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.currentPosition != oldWidget.currentPosition) {
      _updateCurrentLine();
    }
    
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _scaleController.forward();
      } else {
        _scaleController.reverse();
      }
    }
  }

  /// 更新当前歌词行
  void _updateCurrentLine() {
    final newIndex = _findCurrentLineIndex();
    if (newIndex != _currentLineIndex) {
      setState(() {
        _currentLineIndex = newIndex;
      });
      _scrollToCurrentLine();
    }
  }

  /// 查找当前播放位置对应的歌词行
  int _findCurrentLineIndex() {
    for (int i = 0; i < widget.lyrics.length; i++) {
      final line = widget.lyrics[i];
      final nextLine = i + 1 < widget.lyrics.length ? widget.lyrics[i + 1] : null;
      
      if (widget.currentPosition >= line.timestamp &&
          (nextLine == null || widget.currentPosition < nextLine.timestamp)) {
        return i;
      }
    }
    return -1;
  }

  /// 滚动到当前歌词行
  void _scrollToCurrentLine() {
    if (_currentLineIndex >= 0 && _scrollController.hasClients) {
      final targetOffset = _currentLineIndex * _itemHeight - 
          (_scrollController.position.viewportDimension / 2) + 
          (_itemHeight / 2);
      
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500), // 简化版：使用固定时长
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 简化版：使用固定边距和字体大小
    const padding = EdgeInsets.all(16.0);
    _itemHeight = 60.0;

    return Container(
      decoration: _buildBackgroundDecoration(),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: padding,
          child: widget.lyrics.isEmpty
              ? _buildEmptyState()
              : _buildLyricsList(),
        ),
      ),
    );
  }

  /// 构建背景装饰
  BoxDecoration _buildBackgroundDecoration() {
    if (widget.backgroundImageUrl != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.backgroundImageUrl!),
          fit: BoxFit.cover,
        ),
      );
    }
    
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withOpacity(0.3),
          Colors.black.withOpacity(0.7),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.music_note,
            size: 48.0,
            color: Colors.white54,
          ),
          SizedBox(height: 16),
          Text(
            '暂无歌词',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建歌词列表
  Widget _buildLyricsList() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.lyrics.length,
            itemBuilder: (context, index) {
              return _buildLyricItem(index);
            },
          ),
        ),
      ),
    );
  }

  /// 构建单个歌词项
  Widget _buildLyricItem(int index) {
    final line = widget.lyrics[index];
    final isCurrentLine = index == _currentLineIndex;
    
    // 简化版：使用固定字体大小
    const baseFontSize = 16.0;
    final fontSize = isCurrentLine ? baseFontSize * 1.2 : baseFontSize;
    
    // 颜色配置
    final textColor = isCurrentLine 
        ? (widget.highlightColor ?? Colors.white)
        : (widget.textColor ?? Colors.white70);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _itemHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 8.0,
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isCurrentLine && widget.isPlaying ? _scaleAnimation.value : 1.0,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                  fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.normal,
                  shadows: isCurrentLine ? [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ] : null,
                ),
                child: Text(
                  line.text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 歌词解析工具类
class LyricsParser {
  /// 解析LRC格式歌词
  static List<LyricLine> parseLrc(String lrcContent) {
    final lines = lrcContent.split('\n');
    final lyrics = <LyricLine>[];
    
    for (final line in lines) {
      final match = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2})\](.*)').firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final centiseconds = int.parse(match.group(3)!);
        final text = match.group(4)!.trim();
        
        if (text.isNotEmpty) {
          final timestamp = Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: centiseconds * 10,
          );
          
          lyrics.add(LyricLine(
            timestamp: timestamp,
            text: text,
          ));
        }
      }
    }
    
    // 按时间戳排序
    lyrics.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return lyrics;
  }

  /// 解析简单文本歌词（无时间戳）
  static List<LyricLine> parseSimpleText(String textContent) {
    final lines = textContent.split('\n');
    final lyrics = <LyricLine>[];
    
    for (int i = 0; i < lines.length; i++) {
      final text = lines[i].trim();
      if (text.isNotEmpty) {
        lyrics.add(LyricLine(
          timestamp: Duration(seconds: i * 3), // 假设每行3秒
          text: text,
        ));
      }
    }
    
    return lyrics;
  }
} 