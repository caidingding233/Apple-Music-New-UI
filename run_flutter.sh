#!/bin/bash

# 设置Flutter环境
FLUTTER_PATH="/Applications/flutter/flutter_flutter/bin/flutter"

echo "🎵 Apple Music 鸿蒙版 - 启动脚本"
echo "================================="

# 检查Flutter是否存在
if [ ! -f "$FLUTTER_PATH" ]; then
    echo "❌ Flutter路径不存在: $FLUTTER_PATH"
    echo "请安装Flutter或更新路径"
    exit 1
fi

echo "✅ Flutter路径: $FLUTTER_PATH"

# 获取依赖
echo "📦 获取依赖..."
$FLUTTER_PATH pub get

# 运行应用
echo "🚀 启动应用..."
$FLUTTER_PATH run -d macos 