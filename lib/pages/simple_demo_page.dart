import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musicplayer/services/auth_service.dart';

class SimpleDemoPage extends StatelessWidget {
  const SimpleDemoPage({super.key});

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
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息卡片
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFF007AFF),
                              child: Text(
                                user?.username.substring(0, 1) ?? '?',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '欢迎回来！',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (user?.isPremium == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        '⭐ 高级会员',
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
                        const SizedBox(height: 16),
                        _buildInfoRow('👤 用户名', user?.username ?? "未知"),
                        _buildInfoRow('📧 邮箱', user?.email ?? "未知"),
                        if (user?.phoneNumber != null)
                          _buildInfoRow('📱 手机号', user!.phoneNumber!),
                        _buildInfoRow('💎 会员状态', user?.isPremium == true ? "高级会员" : "普通用户"),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 功能按钮
                Text(
                  '🎵 音乐功能',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: Column(
                    children: [
                      _buildFeatureButton(
                        context,
                        icon: Icons.music_note,
                        title: '我的音乐',
                        subtitle: '浏览你的音乐收藏',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🎵 音乐功能开发中...')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildFeatureButton(
                        context,
                        icon: Icons.playlist_play,
                        title: '播放列表',
                        subtitle: '管理你的播放列表',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('📝 播放列表功能开发中...')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildFeatureButton(
                        context,
                        icon: Icons.favorite,
                        title: '我的收藏',
                        subtitle: '查看收藏的歌曲',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('❤️ 收藏功能开发中...')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildFeatureButton(
                        context,
                        icon: Icons.security,
                        title: 'Apple ID 安全',
                        subtitle: '双重认证已启用',
                        onTap: () {
                          _showSecurityInfo(context);
                        },
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // 底部信息
                Center(
                  child: Column(
                    children: [
                      Text(
                        '🍎 Apple Music',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF007AFF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '登录成功！✨',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF007AFF),
        size: 28,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showSecurityInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.security, color: Color(0xFF007AFF)),
            SizedBox(width: 8),
            Text('Apple ID 安全'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('🔐 双重认证已启用'),
            SizedBox(height: 8),
            Text('✅ 您的Apple ID受到双重认证保护'),
            SizedBox(height: 8),
            Text('📱 验证码将发送到您的受信任设备'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 