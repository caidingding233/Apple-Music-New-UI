#!/bin/bash

# Apple Music 简化版启动脚本
echo "🎵 启动 Apple Music 简化版..."

# 设置 Flutter 路径
export PATH="/Applications/flutter/flutter_flutter/bin:$PATH"

# 检查 Flutter 是否可用
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误：Flutter 未找到，请检查路径设置"
    exit 1
fi

echo "✅ Flutter 版本："
flutter --version

echo ""
echo "🧹 清理项目缓存..."
flutter clean > /dev/null 2>&1

echo "📦 获取依赖..."
flutter pub get > /dev/null 2>&1

echo ""
echo "🚀 启动应用程序（简化版）..."
echo "📱 使用演示账户登录："
echo "   邮箱: music@example.com"
echo "   密码: 123456"
echo ""
echo "   或者："
echo "   邮箱: test@example.com" 
echo "   密码: test123"
echo ""
echo "⏳ 正在启动应用程序，请稍候..."

# 启动简化版应用程序
flutter run -d macos -t lib/main_simple.dart 