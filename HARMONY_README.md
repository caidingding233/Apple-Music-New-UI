# Apple Music 鸿蒙版 🎵

基于原版 Apple Music Flutter 应用的鸿蒙系统移植版本，支持多终端设备适配。

## 🚀 项目特色

### ✅ 已完成功能
- 🎯 **多终端适配**: 支持手机、平板、智慧屏、车机等多种鸿蒙设备
- 🎨 **UI自适应**: 根据设备类型自动调整界面布局和交互方式
- 🔧 **鸿蒙集成**: 集成鸿蒙媒体控制中心，支持系统级播放控制
- 📱 **原生体验**: 保持Apple Music的设计风格，适配鸿蒙系统特性

### 🔄 正在开发
- 🎵 **音频播放**: 集成鸿蒙音频服务和媒体会话管理
- 🎤 **歌词显示**: 带动画效果的滚动歌词功能
- 🌐 **网络适配**: 适配鸿蒙网络权限和API

## 📱 设备支持

| 设备类型 | 支持状态 | 特殊适配 |
|---------|---------|---------|
| 📱 手机 | ✅ 完全支持 | 底部导航，竖屏优化 |
| 📟 平板 | ✅ 完全支持 | 横屏分栏布局，侧边栏 |
| 📺 智慧屏/电视 | ✅ 完全支持 | 大屏界面，遥控器导航 |
| 🚗 车机 | ✅ 完全支持 | 简化界面，大按钮设计 |
| ⌚ 手表 | 🔄 开发中 | 紧凑布局，手势操作 |

## 🛠️ 开发环境要求

### 必需工具
- **DevEco Studio**: 4.0 或更高版本
- **HarmonyOS SDK**: API 10 或更高版本
- **Flutter**: 3.3.0 或更高版本（鸿蒙版本）
- **Node.js**: 16.0 或更高版本

### 环境变量设置
```bash
# 设置鸿蒙SDK路径
export HARMONY_HOME=/path/to/harmony/sdk

# 设置鸿蒙Flutter路径（如果使用独立版本）
export FLUTTER_HARMONY_ROOT=/path/to/flutter-harmony

# 添加到PATH
export PATH=$HARMONY_HOME/toolchains:$FLUTTER_HARMONY_ROOT/bin:$PATH
```

## 🔧 快速开始

### 1. 克隆项目
```bash
git clone <repository-url>
cd Apple-Music-New-UI
```

### 2. 安装依赖
```bash
flutter pub get
```

### 3. 构建鸿蒙应用
```bash
# 使用构建脚本（推荐）
./harmony/build.sh --product-name your_device_name --mode debug

# 或手动构建
cd harmony
hvigor assembleHap --mode debug
```

### 4. 安装到设备
```bash
# 使用DevEco Studio安装
# 或使用命令行
hdc install harmony/entry/build/default/outputs/default/entry-default-signed.hap
```

## 📁 项目结构

```
Apple-Music-New-UI/
├── lib/                          # Flutter应用代码
│   ├── pages/                    # 页面文件
│   ├── services/                 # 服务层
│   │   └── harmony_audio_service.dart  # 鸿蒙音频服务
│   ├── utils/                    # 工具类
│   │   └── harmony_device_adapter.dart # 设备适配器
│   └── main.dart                 # 应用入口
├── harmony/                      # 鸿蒙项目文件
│   ├── build-profile.json5       # 构建配置
│   ├── build.sh                  # 构建脚本
│   └── entry/                    # 主模块
│       └── src/main/
│           ├── ets/              # ArkTS代码
│           └── resources/        # 资源文件
├── harmony_plugins/              # 鸿蒙插件
│   └── flutter_ohos_plugin/      # 鸿蒙平台插件
└── assets/                       # 应用资源
```

## 🎨 界面适配说明

### 手机端 📱
- 保持原版Apple Music的界面布局
- 底部导航栏，支持手势操作
- 适配鸿蒙状态栏和导航栏

### 平板端 📟
- 横屏时显示侧边栏导航
- 分栏布局，左侧导航右侧内容
- 支持多窗口和分屏操作

### 智慧屏/电视 📺
- 仿Apple TV的大屏界面设计
- 遥控器友好的焦点导航
- 大字体和图标，适合远距离观看

### 车机端 🚗
- 简化的大按钮界面
- 考虑驾驶安全的交互设计
- 语音控制集成（规划中）

## 🔌 鸿蒙特性集成

### 媒体控制中心
```dart
// 更新媒体信息到鸿蒙控制中心
await FlutterOhosPlugin.updateMediaInfo(
  title: '歌曲名称',
  artist: '艺术家',
  album: '专辑名称',
  artworkUrl: '封面图片URL',
  duration: 歌曲时长,
  position: 当前位置,
  isPlaying: 是否播放中,
);
```

### 设备适配
```dart
// 获取设备类型和适配信息
final adapter = HarmonyDeviceAdapter.instance;
await adapter.initialize(context);

if (adapter.isTV) {
  // 智慧屏特殊处理
} else if (adapter.isTablet) {
  // 平板特殊处理
}
```

## 🚧 开发路线图

### Phase 1: 基础移植 ✅
- [x] 项目结构搭建
- [x] 鸿蒙构建配置
- [x] 多终端设备适配
- [x] 基础UI适配

### Phase 2: 功能集成 🔄
- [ ] 音频播放服务集成
- [ ] 媒体控制中心对接
- [ ] 网络请求适配
- [ ] 本地存储适配

### Phase 3: 体验优化 📋
- [ ] 歌词显示和动画
- [ ] 性能优化
- [ ] 无障碍支持
- [ ] 多语言支持

### Phase 4: 高级功能 📋
- [ ] 语音控制（车机）
- [ ] 手势操作（手表）
- [ ] 多设备协同
- [ ] 智能推荐

## 🤝 贡献指南

1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目基于原版Apple Music Flutter应用进行鸿蒙适配，请遵循相关开源协议。

## 🙏 致谢

- 原版Apple Music Flutter应用开发者
- 鸿蒙开发社区
- Flutter鸿蒙适配团队

## 📞 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 Issue
- 发起 Discussion
- 邮件联系

---

**让Apple Music在鸿蒙生态中绽放！** 🎵✨ 