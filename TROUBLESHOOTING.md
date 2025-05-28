# Apple Music 应用故障排除指南

## 🚨 应用启动问题解决方案

### 问题描述
应用程序无法正常启动，可能遇到编译错误或构建失败。

### 解决步骤

#### 1. 清理项目缓存
```bash
export PATH="/Applications/flutter/flutter_flutter/bin:$PATH"
flutter clean
rm -rf build/
flutter pub get
```

#### 2. 使用简化版本启动
如果完整版本无法启动，请使用简化版本：
```bash
flutter run -d macos -t lib/main_simple.dart
```

#### 3. 检查 Flutter 版本兼容性
当前项目使用的是 Flutter 3.7.12-ohos-1.1.1 版本，某些新特性可能不兼容：

**已知兼容性问题：**
- `ListenableBuilder` 在 Flutter 3.7.x 中不存在，已替换为 `AnimatedBuilder`
- `provider` 包需要正确配置

#### 4. 验证依赖
确保以下依赖已正确安装：
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  audio_service: ^0.18.16
  just_audio: ^0.9.37
  audioplayers: ^3.0.1
```

### 🎯 测试登录功能

#### 演示账户
应用程序提供了两个测试账户：

1. **音乐爱好者账户**
   - 邮箱：`music@example.com`
   - 密码：`123456`
   - 类型：高级会员

2. **普通用户账户**
   - 邮箱：`test@example.com`
   - 密码：`test123`
   - 类型：普通用户

#### 登录流程
1. 启动应用程序
2. 在登录页面输入上述任一账户信息
3. 点击"登录"按钮
4. 成功登录后将显示用户信息和音乐功能

### 🔧 常见错误及解决方案

#### 错误：`ListenableBuilder` 未定义
**解决方案：** 已修复，使用 `AnimatedBuilder` 替代

#### 错误：`provider` 包未找到
**解决方案：** 运行 `flutter pub get` 重新获取依赖

#### 错误：构建数据库被锁定
**解决方案：** 
```bash
# 停止所有 Flutter 进程
pkill -f flutter
# 清理构建缓存
flutter clean
rm -rf build/
# 重新构建
flutter run -d macos
```

#### 错误：音频服务初始化失败
**解决方案：** 使用简化版本 `lib/main_simple.dart`，该版本不包含复杂的音频服务

### 📱 功能验证

#### 简化版本功能
- ✅ 用户登录/注册
- ✅ 用户信息显示
- ✅ 基本界面导航
- ✅ 登出功能

#### 完整版本功能（开发中）
- 🔄 音乐播放
- 🔄 播放列表管理
- 🔄 收藏功能
- 🔄 HarmonyOS 适配

### 🚀 下一步开发计划

1. **修复音频播放功能**
   - 简化音频服务实现
   - 移除 HarmonyOS 特定代码（在 macOS 测试时）
   - 使用标准的 Flutter 音频插件

2. **完善用户界面**
   - 优化登录页面动画
   - 添加音乐播放控件
   - 实现播放列表界面

3. **数据持久化**
   - 实现用户偏好设置存储
   - 添加播放历史记录
   - 缓存音乐数据

### 💡 开发建议

1. **逐步测试**：先确保基本功能正常，再添加复杂特性
2. **版本兼容**：注意 Flutter 版本与插件的兼容性
3. **平台适配**：在不同平台上分别测试功能

### 📞 获取帮助

如果遇到其他问题，请检查：
1. Flutter 版本：`flutter --version`
2. 依赖状态：`flutter doctor`
3. 项目配置：`flutter pub deps`

---

**最后更新：** 2024年1月
**适用版本：** Flutter 3.7.12-ohos-1.1.1 