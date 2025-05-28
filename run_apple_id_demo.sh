#!/bin/bash

# Apple Music Apple ID 登录演示启动脚本
echo "🍎 启动 Apple Music Apple ID 登录演示..."

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
echo "🚀 启动 Apple ID 登录演示..."
echo ""
echo "🍎 演示 Apple ID 账户："
echo "   方式1: music@example.com / 123456"
echo "   方式2: +86 138 0013 8000 / 123456"
echo ""
echo "🔐 双重认证验证码: 123456"
echo ""
echo "✨ 新功能："
echo "   • 支持手机号 Apple ID 登录"
echo "   • 真实的 2FA 双重认证流程"
echo "   • Apple 风格的登录界面"
echo "   • 用户信息详细展示"
echo ""
echo "⏳ 正在启动应用程序，请稍候..."

# 启动简化版应用程序
flutter run -d macos -t lib/main_simple.dart 