#!/bin/bash

echo "🍎 Apple Music Flutter - Mac调试启动脚本"
echo "========================================"

# 检查Flutter是否在PATH中
if command -v flutter &> /dev/null; then
    echo "✅ Flutter 已找到"
    flutter --version
else
    echo "⚠️  正在设置Flutter环境..."
    export PATH="/Applications/flutter/flutter_flutter/bin:$PATH"
    
    if command -v flutter &> /dev/null; then
        echo "✅ Flutter 环境设置成功"
        flutter --version
    else
        echo "❌ Flutter 未找到，请检查安装路径"
        echo "请修改脚本中的Flutter路径或确保Flutter已正确安装"
        exit 1
    fi
fi

echo ""
echo "📦 正在获取依赖包..."
flutter pub get

echo ""
echo "🔧 检查可用设备..."
flutter devices

echo ""
echo "🚀 正在启动Apple Music应用..."
echo "选择运行方式："
echo "1. Mac桌面应用 (推荐)"
echo "2. Chrome浏览器"
echo "3. 自动选择"

read -p "请输入选择 (1-3，默认为1): " choice
choice=${choice:-1}

case $choice in
    1)
        echo "🖥️  在Mac桌面启动..."
        flutter run -d macos --release
        ;;
    2)
        echo "🌐 在Chrome浏览器启动..."
        flutter run -d chrome
        ;;
    3)
        echo "🤖 自动选择设备..."
        flutter run
        ;;
    *)
        echo "🖥️  默认在Mac桌面启动..."
        flutter run -d macos
        ;;
esac 