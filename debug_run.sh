#!/bin/bash

echo "🚀 开始调试 Apple Music 鸿蒙版应用..."

# 设置Flutter路径
export PATH="/Applications/flutter/flutter_flutter/bin:$PATH"

# 检查Flutter环境
echo "📋 检查Flutter环境..."
flutter --version

# 清理项目
echo "🧹 清理项目..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 分析代码问题
echo "🔍 分析代码问题..."
flutter analyze

# 检查可用设备
echo "📱 检查可用设备..."
flutter devices

# 编译检查
echo "🔨 编译检查..."
flutter build macos --debug

echo "✅ 调试完成！如果上述步骤都成功，可以运行："
echo "flutter run -d macos" 