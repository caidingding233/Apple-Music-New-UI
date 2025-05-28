import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Apple Music API 服务
/// 用于获取真实的 Apple Music 数据
class AppleMusicAPI {
  static const String _baseUrl = 'https://api.music.apple.com/v1';
  
  // 开发者令牌 - 需要从 Apple Developer 获取
  // 这里使用演示令牌，实际使用时需要替换为真实令牌
  static const String _developerToken = 'DEMO_TOKEN_REPLACE_WITH_REAL';
  
  // 用户令牌 - 通过 MusicKit JS 获取
  String? _userToken;
  
  static final AppleMusicAPI _instance = AppleMusicAPI._internal();
  factory AppleMusicAPI() => _instance;
  AppleMusicAPI._internal();

  /// 设置用户令牌
  void setUserToken(String token) {
    _userToken = token;
  }

  /// 获取请求头
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_developerToken',
    'Music-User-Token': _userToken ?? '',
    'Content-Type': 'application/json',
  };

  /// 搜索音乐
  Future<List<Song>> searchSongs(String query, {int limit = 25}) async {
    try {
      final url = Uri.parse('$_baseUrl/catalog/cn/search')
          .replace(queryParameters: {
        'term': query,
        'types': 'songs',
        'limit': limit.toString(),
      });

      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final songs = <Song>[];
        
        if (data['results']?['songs']?['data'] != null) {
          for (var songData in data['results']['songs']['data']) {
            songs.add(Song.fromAppleMusicAPI(songData));
          }
        }
        
        return songs;
      } else {
        debugPrint('搜索失败: ${response.statusCode} - ${response.body}');
        return _getFallbackSongs(query);
      }
    } catch (e) {
      debugPrint('搜索错误: $e');
      return _getFallbackSongs(query);
    }
  }

  /// 获取热门歌曲
  Future<List<Song>> getTopSongs({String country = 'cn', int limit = 50}) async {
    try {
      final url = Uri.parse('$_baseUrl/catalog/$country/charts')
          .replace(queryParameters: {
        'types': 'songs',
        'limit': limit.toString(),
      });

      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final songs = <Song>[];
        
        if (data['results']?['songs']?[0]?['data'] != null) {
          for (var songData in data['results']['songs'][0]['data']) {
            songs.add(Song.fromAppleMusicAPI(songData));
          }
        }
        
        return songs;
      } else {
        debugPrint('获取热门歌曲失败: ${response.statusCode}');
        return _getDefaultTopSongs();
      }
    } catch (e) {
      debugPrint('获取热门歌曲错误: $e');
      return _getDefaultTopSongs();
    }
  }

  /// 获取专辑信息
  Future<Album?> getAlbum(String albumId) async {
    try {
      final url = Uri.parse('$_baseUrl/catalog/cn/albums/$albumId');
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data']?.isNotEmpty == true) {
          return Album.fromAppleMusicAPI(data['data'][0]);
        }
      }
    } catch (e) {
      debugPrint('获取专辑错误: $e');
    }
    return null;
  }

  /// 获取艺术家信息
  Future<Artist?> getArtist(String artistId) async {
    try {
      final url = Uri.parse('$_baseUrl/catalog/cn/artists/$artistId');
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data']?.isNotEmpty == true) {
          return Artist.fromAppleMusicAPI(data['data'][0]);
        }
      }
    } catch (e) {
      debugPrint('获取艺术家错误: $e');
    }
    return null;
  }

  /// 获取播放列表
  Future<List<Playlist>> getPlaylists({int limit = 25}) async {
    try {
      final url = Uri.parse('$_baseUrl/catalog/cn/playlists')
          .replace(queryParameters: {
        'limit': limit.toString(),
      });

      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final playlists = <Playlist>[];
        
        if (data['data'] != null) {
          for (var playlistData in data['data']) {
            playlists.add(Playlist.fromAppleMusicAPI(playlistData));
          }
        }
        
        return playlists;
      }
    } catch (e) {
      debugPrint('获取播放列表错误: $e');
    }
    return _getDefaultPlaylists();
  }

  /// 备用歌曲数据（当 API 不可用时）
  List<Song> _getFallbackSongs(String query) {
    return [
      Song(
        id: 'demo_1',
        title: '搜索结果: $query',
        artist: '演示艺术家',
        album: '演示专辑',
        duration: const Duration(minutes: 3, seconds: 30),
        artworkUrl: 'https://via.placeholder.com/300x300/007AFF/FFFFFF?text=🎵',
        previewUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      ),
    ];
  }

  /// 默认热门歌曲
  List<Song> _getDefaultTopSongs() {
    return [
      Song(
        id: 'top_1',
        title: '热门歌曲 1',
        artist: '流行歌手',
        album: '热门专辑',
        duration: const Duration(minutes: 3, seconds: 45),
        artworkUrl: 'https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=🔥',
        previewUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      ),
      Song(
        id: 'top_2',
        title: '热门歌曲 2',
        artist: '知名艺术家',
        album: '经典专辑',
        duration: const Duration(minutes: 4, seconds: 12),
        artworkUrl: 'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=⭐',
        previewUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      ),
    ];
  }

  /// 默认播放列表
  List<Playlist> _getDefaultPlaylists() {
    return [
      Playlist(
        id: 'playlist_1',
        name: '今日热门',
        description: '最新最热的音乐',
        artworkUrl: 'https://via.placeholder.com/300x300/007AFF/FFFFFF?text=🎵',
        songCount: 50,
      ),
    ];
  }
}

/// 歌曲数据模型
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String artworkUrl;
  final String? previewUrl;
  final String? appleMusicUrl;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.artworkUrl,
    this.previewUrl,
    this.appleMusicUrl,
  });

  factory Song.fromAppleMusicAPI(Map<String, dynamic> data) {
    final attributes = data['attributes'] ?? {};
    final artwork = attributes['artwork'] ?? {};
    
    return Song(
      id: data['id'] ?? '',
      title: attributes['name'] ?? '未知歌曲',
      artist: attributes['artistName'] ?? '未知艺术家',
      album: attributes['albumName'] ?? '未知专辑',
      duration: Duration(milliseconds: attributes['durationInMillis'] ?? 0),
      artworkUrl: _buildArtworkUrl(artwork),
      previewUrl: attributes['previews']?.isNotEmpty == true 
          ? attributes['previews'][0]['url'] 
          : null,
      appleMusicUrl: attributes['url'],
    );
  }

  static String _buildArtworkUrl(Map<String, dynamic> artwork) {
    if (artwork['url'] != null) {
      return artwork['url']
          .toString()
          .replaceAll('{w}', '300')
          .replaceAll('{h}', '300');
    }
    return 'https://via.placeholder.com/300x300/007AFF/FFFFFF?text=🎵';
  }
}

/// 专辑数据模型
class Album {
  final String id;
  final String name;
  final String artistName;
  final String artworkUrl;
  final int trackCount;

  Album({
    required this.id,
    required this.name,
    required this.artistName,
    required this.artworkUrl,
    required this.trackCount,
  });

  factory Album.fromAppleMusicAPI(Map<String, dynamic> data) {
    final attributes = data['attributes'] ?? {};
    final artwork = attributes['artwork'] ?? {};
    
    return Album(
      id: data['id'] ?? '',
      name: attributes['name'] ?? '未知专辑',
      artistName: attributes['artistName'] ?? '未知艺术家',
      artworkUrl: Song._buildArtworkUrl(artwork),
      trackCount: attributes['trackCount'] ?? 0,
    );
  }
}

/// 艺术家数据模型
class Artist {
  final String id;
  final String name;
  final String? biography;

  Artist({
    required this.id,
    required this.name,
    this.biography,
  });

  factory Artist.fromAppleMusicAPI(Map<String, dynamic> data) {
    final attributes = data['attributes'] ?? {};
    
    return Artist(
      id: data['id'] ?? '',
      name: attributes['name'] ?? '未知艺术家',
      biography: attributes['editorialNotes']?['standard'],
    );
  }
}

/// 播放列表数据模型
class Playlist {
  final String id;
  final String name;
  final String description;
  final String artworkUrl;
  final int songCount;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.artworkUrl,
    required this.songCount,
  });

  factory Playlist.fromAppleMusicAPI(Map<String, dynamic> data) {
    final attributes = data['attributes'] ?? {};
    final artwork = attributes['artwork'] ?? {};
    
    return Playlist(
      id: data['id'] ?? '',
      name: attributes['name'] ?? '未知播放列表',
      description: attributes['description']?['standard'] ?? '',
      artworkUrl: Song._buildArtworkUrl(artwork),
      songCount: attributes['trackCount'] ?? 0,
    );
  }
} 