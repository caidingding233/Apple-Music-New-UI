#!/bin/bash

# 设置Flutter路径
export PATH="/Applications/flutter/flutter_flutter/bin:$PATH"

# 清理项目
echo "正在清理项目..."
flutter clean

# 获取依赖
echo "正在获取依赖..."
flutter pub get

# 运行应用
echo "正在启动应用..."
flutter run -d macos

echo "应用启动完成！" 