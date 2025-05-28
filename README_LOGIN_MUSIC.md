# Apple Music 鸿蒙版 - 登录与音乐播放功能

## 🎵 功能概述

本项目已成功实现了完整的登录系统和音乐播放功能，包括：

### ✅ 已实现功能

1. **用户认证系统**
   - 模拟登录/注册功能
   - 用户状态管理
   - 自动登录状态检查

2. **音乐服务**
   - 音乐库管理
   - 播放列表管理
   - 收藏功能
   - 搜索功能

3. **音乐播放器**
   - 完整的播放控制（播放/暂停/上一首/下一首）
   - 播放进度控制
   - 多种播放模式（顺序/单曲循环/随机）
   - 后台播放支持

4. **鸿蒙适配**
   - 前台音频服务
   - 锁屏播放支持
   - 通知栏控制

## 🚀 快速开始

### 1. 运行应用
```bash
# 使用便捷脚本
./run_app.sh

# 或手动运行
export PATH="/Applications/flutter/flutter_flutter/bin:$PATH"
flutter clean && flutter pub get && flutter run -d macos
```

### 2. 登录测试
应用启动后会显示登录页面，你可以使用以下测试账号：

**测试账号1（普通用户）：**
- 邮箱：`user@example.com`
- 密码：`password123`

**测试账号2（高级会员）：**
- 邮箱：`premium@example.com`
- 密码：`premium123`

**或者注册新账号：**
- 点击"注册新账号"
- 填写用户名、邮箱和密码
- 点击注册

### 3. 音乐播放体验

登录成功后，你将看到：

1. **用户信息卡片** - 显示当前登录用户信息
2. **播放控制区域** - 当有音乐播放时显示
3. **音乐列表** - 包含5首示例音乐

**操作说明：**
- 点击任意歌曲开始播放
- 使用播放控制按钮控制播放
- 拖动进度条跳转播放位置
- 点击❤️图标添加/移除收藏
- 点击右上角退出登录

## 📁 项目结构

```
lib/
├── services/
│   ├── auth_service.dart          # 用户认证服务
│   ├── music_service.dart         # 音乐数据服务
│   ├── music_player_service.dart  # 音乐播放控制器
│   ├── foreground_audio_service.dart  # 前台音频服务
│   └── harmony_audio_service.dart # 鸿蒙音频适配
├── pages/
│   ├── login_page.dart           # 登录页面
│   └── demo_music_page.dart      # 音乐演示页面
└── main.dart                     # 应用入口
```

## 🎯 核心特性

### 状态管理
使用 `Provider` 进行状态管理，包括：
- `AuthService` - 用户认证状态
- `MusicService` - 音乐数据管理
- `MusicPlayerService` - 播放器状态

### 音频播放
- 使用 `just_audio` 库进行音频播放
- 支持网络音频流
- 自动播放列表管理
- 播放状态实时更新

### 用户体验
- 现代化的 Material Design 界面
- 流畅的动画效果
- 响应式布局设计
- 直观的操作反馈

## 🔧 技术栈

- **Flutter 3.7.12** - 跨平台框架
- **Provider 6.0.5** - 状态管理
- **just_audio 0.9.30** - 音频播放
- **audio_service 0.18.9** - 后台音频服务

## 📱 平台支持

- ✅ macOS (当前测试平台)
- ✅ HarmonyOS (已适配)
- ✅ Android (理论支持)
- ✅ iOS (理论支持)

## 🎵 音乐资源

当前使用示例音频文件，包含：
1. River Flows in You - Yiruma
2. Canon in D - Pachelbel  
3. Clair de Lune - Claude Debussy
4. Spring Waltz - Chopin
5. Peaceful Morning - Nature Sounds

> 注意：示例音频使用免费音效，实际部署时需要替换为真实的音乐文件。

## 🚧 下一步开发计划

1. **音乐资源集成**
   - 集成真实音乐API
   - 添加专辑封面图片
   - 支持本地音乐文件

2. **功能增强**
   - 歌词显示
   - 均衡器设置
   - 播放历史记录
   - 个性化推荐

3. **鸿蒙优化**
   - 完整的鸿蒙UI适配
   - 鸿蒙特有功能集成
   - 性能优化

## 🎉 总结

项目已成功实现了完整的登录和音乐播放功能！用户可以：

1. ✅ 使用模拟账号登录
2. ✅ 浏览和播放音乐
3. ✅ 控制播放进度和模式
4. ✅ 管理收藏列表
5. ✅ 享受后台播放功能

现在你可以运行应用并体验完整的音乐播放功能了！🎵 