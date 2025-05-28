import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musicplayer/services/auth_service.dart';
import 'package:musicplayer/services/apple_music_api.dart';

class RealMusicPage extends StatefulWidget {
  const RealMusicPage({super.key});

  @override
  State<RealMusicPage> createState() => _RealMusicPageState();
}

class _RealMusicPageState extends State<RealMusicPage> with TickerProviderStateMixin {
  final AppleMusicAPI _appleMusicAPI = AppleMusicAPI();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  
  List<Song> _searchResults = [];
  List<Song> _topSongs = [];
  List<Playlist> _playlists = [];
  
  Song? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAudioPlayer();
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _totalDuration = duration;
      });
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final topSongs = await _appleMusicAPI.getTopSongs();
      final playlists = await _appleMusicAPI.getPlaylists();
      
      setState(() {
        _topSongs = topSongs;
        _playlists = playlists;
      });
    } catch (e) {
      debugPrint('加载初始数据错误: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchSongs(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _appleMusicAPI.searchSongs(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      debugPrint('搜索错误: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playSong(Song song) async {
    try {
      setState(() {
        _currentSong = song;
        _isLoading = true;
      });

      // 如果有预览URL，播放预览
      if (song.previewUrl != null) {
        await _audioPlayer.play(UrlSource(song.previewUrl!));
      } else {
        // 使用演示音频
        await _audioPlayer.play(UrlSource('https://www.soundjay.com/misc/sounds/bell-ringing-05.wav'));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎵 正在播放: ${song.title} - ${song.artist}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('播放错误: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('播放失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      debugPrint('播放控制错误: $e');
    }
  }

  Future<void> _stopSong() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _currentSong = null;
        _currentPosition = Duration.zero;
        _totalDuration = Duration.zero;
      });
    } catch (e) {
      debugPrint('停止播放错误: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 Apple Music'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthService>().logout();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: '搜索'),
            Tab(icon: Icon(Icons.trending_up), text: '热门'),
            Tab(icon: Icon(Icons.playlist_play), text: '播放列表'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 当前播放控制栏
          if (_currentSong != null) _buildCurrentPlayingBar(),
          
          // 主要内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchTab(),
                _buildTopSongsTab(),
                _buildPlaylistsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlayingBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _currentSong!.artworkUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.music_note),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentSong!.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _currentSong!.artist,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _togglePlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: _stopSong,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: _totalDuration.inMilliseconds > 0
                      ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                      : 0.0,
                  onChanged: (value) {
                    final position = Duration(
                      milliseconds: (value * _totalDuration.inMilliseconds).round(),
                    );
                    _audioPlayer.seek(position);
                  },
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索歌曲、艺术家或专辑...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              _searchSongs(value);
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        '🔍 输入关键词搜索音乐',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final song = _searchResults[index];
                        return _buildSongTile(song);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildTopSongsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _topSongs.length,
            itemBuilder: (context, index) {
              final song = _topSongs[index];
              return _buildSongTile(song, showRank: true, rank: index + 1);
            },
          );
  }

  Widget _buildPlaylistsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _playlists.length,
            itemBuilder: (context, index) {
              final playlist = _playlists[index];
              return _buildPlaylistTile(playlist);
            },
          );
  }

  Widget _buildSongTile(Song song, {bool showRank = false, int? rank}) {
    final isCurrentSong = _currentSong?.id == song.id;
    
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showRank && rank != null)
            Container(
              width: 30,
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? Colors.amber : Colors.grey,
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              song.artworkUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.music_note),
                );
              },
            ),
          ),
        ],
      ),
      title: Text(
        song.title,
        style: TextStyle(
          fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
          color: isCurrentSong ? const Color(0xFF007AFF) : null,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist} • ${song.album}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_formatDuration(song.duration)),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              isCurrentSong && _isPlaying ? Icons.pause : Icons.play_arrow,
              color: const Color(0xFF007AFF),
            ),
            onPressed: () {
              if (isCurrentSong && _isPlaying) {
                _togglePlayPause();
              } else {
                _playSong(song);
              }
            },
          ),
        ],
      ),
      onTap: () => _playSong(song),
    );
  }

  Widget _buildPlaylistTile(Playlist playlist) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          playlist.artworkUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 50,
              height: 50,
              color: Colors.grey.shade300,
              child: const Icon(Icons.playlist_play),
            );
          },
        ),
      ),
      title: Text(
        playlist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.songCount} 首歌曲',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📝 播放列表功能开发中: ${playlist.name}')),
        );
      },
    );
  }
} 