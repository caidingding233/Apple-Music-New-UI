import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// 音乐模型
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String audioUrl;
  final String imageUrl;
  final Duration duration;
  final bool isLocal;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.audioUrl,
    required this.imageUrl,
    required this.duration,
    this.isLocal = false,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      album: json['album'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0),
      isLocal: json['isLocal'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'duration': duration.inSeconds,
      'isLocal': isLocal,
    };
  }
}

/// 播放列表模型
class Playlist {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.songs,
  });
}

/// 音乐服务
class MusicService extends ChangeNotifier {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal() {
    _initializeMusic();
  }

  List<Song> _songs = [];
  List<Playlist> _playlists = [];
  List<Song> _favorites = [];
  bool _isLoading = false;

  List<Song> get songs => _songs;
  List<Playlist> get playlists => _playlists;
  List<Song> get favorites => _favorites;
  bool get isLoading => _isLoading;

  /// 初始化音乐数据（使用本地和免费音频）
  void _initializeMusic() {
    _songs = [
      // 使用免费音乐素材和本地文件
      Song(
        id: '1',
        title: 'River Flows in You',
        artist: 'Yiruma',
        album: 'Piano Collection',
        audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav', // 示例音频
        imageUrl: 'assets/images/piano_cover.jpg',
        duration: const Duration(minutes: 3, seconds: 20),
        isLocal: true,
      ),
      Song(
        id: '2',
        title: 'Canon in D',
        artist: 'Pachelbel',
        album: 'Classical Masterpieces',
        audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-04.wav',
        imageUrl: 'assets/images/classical_cover.jpg',
        duration: const Duration(minutes: 4, seconds: 15),
        isLocal: true,
      ),
      Song(
        id: '3',
        title: 'Clair de Lune',
        artist: 'Claude Debussy',
        album: 'Impressionist Piano',
        audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-03.wav',
        imageUrl: 'assets/images/debussy_cover.jpg',
        duration: const Duration(minutes: 5, seconds: 2),
        isLocal: true,
      ),
      Song(
        id: '4',
        title: 'Spring Waltz',
        artist: 'Chopin',
        album: 'Romantic Piano',
        audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-02.wav',
        imageUrl: 'assets/images/chopin_cover.jpg',
        duration: const Duration(minutes: 3, seconds: 45),
        isLocal: true,
      ),
      Song(
        id: '5',
        title: 'Peaceful Morning',
        artist: 'Nature Sounds',
        album: 'Relaxation',
        audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-01.wav',
        imageUrl: 'assets/images/nature_cover.jpg',
        duration: const Duration(minutes: 2, seconds: 30),
        isLocal: true,
      ),
    ];

    _playlists = [
      Playlist(
        id: '1',
        name: '我的最爱',
        description: '你最喜欢的音乐收藏',
        imageUrl: 'assets/images/favorites_cover.jpg',
        songs: _songs.take(3).toList(),
      ),
      Playlist(
        id: '2',
        name: '古典精选',
        description: '优美的古典音乐合集',
        imageUrl: 'assets/images/classical_playlist.jpg',
        songs: _songs.where((song) => 
          song.artist.contains('Chopin') || 
          song.artist.contains('Debussy') || 
          song.artist.contains('Pachelbel')
        ).toList(),
      ),
      Playlist(
        id: '3',
        name: '放松时光',
        description: '舒缓心情的音乐',
        imageUrl: 'assets/images/relax_playlist.jpg',
        songs: [_songs.first, _songs.last],
      ),
    ];

    notifyListeners();
  }

  /// 获取推荐歌曲
  List<Song> getRecommendedSongs({int limit = 10}) {
    final shuffled = List<Song>.from(_songs);
    shuffled.shuffle(Random());
    return shuffled.take(limit).toList();
  }

  /// 搜索歌曲
  List<Song> searchSongs(String query) {
    if (query.isEmpty) return _songs;
    
    return _songs.where((song) =>
      song.title.toLowerCase().contains(query.toLowerCase()) ||
      song.artist.toLowerCase().contains(query.toLowerCase()) ||
      song.album.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// 添加到收藏
  void addToFavorites(Song song) {
    if (!_favorites.any((s) => s.id == song.id)) {
      _favorites.add(song);
      notifyListeners();
    }
  }

  /// 从收藏中移除
  void removeFromFavorites(String songId) {
    _favorites.removeWhere((song) => song.id == songId);
    notifyListeners();
  }

  /// 检查是否收藏
  bool isFavorite(String songId) {
    return _favorites.any((song) => song.id == songId);
  }

  /// 根据ID获取歌曲
  Song? getSongById(String id) {
    try {
      return _songs.firstWhere((song) => song.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取艺术家的所有歌曲
  List<Song> getSongsByArtist(String artist) {
    return _songs.where((song) => song.artist == artist).toList();
  }

  /// 获取专辑的所有歌曲
  List<Song> getSongsByAlbum(String album) {
    return _songs.where((song) => song.album == album).toList();
  }

  /// 创建新播放列表
  Playlist createPlaylist(String name, String description, List<Song> songs) {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      imageUrl: songs.isNotEmpty ? songs.first.imageUrl : 'assets/images/default_playlist.jpg',
      songs: songs,
    );
    
    _playlists.add(playlist);
    notifyListeners();
    return playlist;
  }

  /// 删除播放列表
  void deletePlaylist(String playlistId) {
    _playlists.removeWhere((playlist) => playlist.id == playlistId);
    notifyListeners();
  }

  /// 获取所有艺术家
  List<String> getAllArtists() {
    return _songs.map((song) => song.artist).toSet().toList();
  }

  /// 获取所有专辑
  List<String> getAllAlbums() {
    return _songs.map((song) => song.album).toSet().toList();
  }

  /// 模拟加载
  Future<void> loadMusic() async {
    _isLoading = true;
    notifyListeners();
    
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    notifyListeners();
  }
} 