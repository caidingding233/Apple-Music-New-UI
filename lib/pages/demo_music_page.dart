import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musicplayer/services/auth_service.dart';
import 'package:musicplayer/services/music_service.dart';
import 'package:musicplayer/services/music_player_service.dart';

class DemoMusicPage extends StatelessWidget {
  const DemoMusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apple Music 演示'),
        actions: [
          Consumer<AuthService>(
            builder: (context, authService, child) {
              return Row(
                children: [
                  if (authService.currentUser != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        '欢迎, ${authService.currentUser!.username}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      authService.logout();
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer3<MusicService, MusicPlayerService, AuthService>(
        builder: (context, musicService, playerService, authService, child) {
          return Column(
            children: [
              // 用户信息卡片
              if (authService.currentUser != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                        child: Text(
                          authService.currentUser!.username[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authService.currentUser!.username,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              authService.currentUser!.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                            if (authService.currentUser!.isPremium)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '高级会员',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // 当前播放信息
              if (playerService.currentSong != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '正在播放',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[200],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        playerService.currentSong!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        playerService.currentSong!.artist,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // 播放控制按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            onPressed: playerService.hasPrevious
                                ? () => playerService.previous()
                                : null,
                          ),
                          IconButton(
                            icon: Icon(
                              playerService.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              size: 48,
                            ),
                            onPressed: () => playerService.togglePlayPause(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            onPressed: playerService.hasNext
                                ? () => playerService.next()
                                : null,
                          ),
                        ],
                      ),
                      
                      // 播放进度
                      Slider(
                        value: playerService.position.inSeconds.toDouble(),
                        max: playerService.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          playerService.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(playerService.position),
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            _formatDuration(playerService.duration),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // 歌曲列表
              Expanded(
                child: ListView.builder(
                  itemCount: musicService.songs.length,
                  itemBuilder: (context, index) {
                    final song = musicService.songs[index];
                    final isCurrentSong = playerService.currentSong?.id == song.id;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCurrentSong ? Colors.blue : Colors.grey[700],
                        child: Icon(
                          isCurrentSong && playerService.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        song.title,
                        style: TextStyle(
                          fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                          color: isCurrentSong ? Colors.blue : Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        '${song.artist} • ${song.album}',
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDuration(song.duration),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              musicService.isFavorite(song.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: musicService.isFavorite(song.id)
                                  ? Colors.red
                                  : Colors.grey[400],
                            ),
                            onPressed: () {
                              if (musicService.isFavorite(song.id)) {
                                musicService.removeFromFavorites(song.id);
                              } else {
                                musicService.addToFavorites(song);
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        playerService.playSong(
                          song,
                          playlist: musicService.songs,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
} 