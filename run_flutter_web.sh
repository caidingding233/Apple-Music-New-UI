#!/bin/bash

echo "🎵 Apple Music 鸿蒙版 - Flutter Web版本"
echo "========================================="

# 检查Flutter Web构建文件是否存在
if [ ! -f "build/web/index.html" ]; then
    echo "❌ Flutter Web构建文件不存在"
    echo "📦 正在构建Web版本..."
    
    # 构建Flutter Web版本
    flutter build web
    
    if [ $? -ne 0 ]; then
        echo "❌ Flutter Web构建失败"
        exit 1
    fi
    
    echo "✅ Flutter Web构建完成"
fi

# 获取本机IP地址
IP=$(ipconfig getifaddr en0 2>/dev/null || echo "localhost")
PORT=8080

echo ""
echo "🌐 启动选项:"
echo "1. 使用Python启动 (推荐)"
echo "2. 使用Node.js启动"
echo "3. 直接在浏览器中打开"

read -p "请选择启动方式 (1-3): " choice

case $choice in
    1)
        echo "🐍 使用Python启动Flutter Web服务器..."
        echo "📱 访问地址: http://$IP:$PORT"
        echo "🖥️  本地访问: http://localhost:$PORT"
        echo ""
        echo "💡 演示账户:"
        echo "   📧 music@example.com / 123456"
        echo "   📱 +86 138 0013 8000 / 123456"
        echo "   🔐 2FA验证码: 123456"
        echo ""
        echo "⚡ 按 Ctrl+C 停止服务器"
        cd build/web && python3 -m http.server $PORT
        ;;
    2)
        if command -v npx &> /dev/null; then
            echo "📦 使用Node.js启动Flutter Web服务器..."
            echo "📱 访问地址: http://$IP:$PORT"
            echo "🖥️  本地访问: http://localhost:$PORT"
            echo ""
            echo "💡 演示账户:"
            echo "   📧 music@example.com / 123456"
            echo "   📱 +86 138 0013 8000 / 123456"
            echo "   🔐 2FA验证码: 123456"
            echo ""
            echo "⚡ 按 Ctrl+C 停止服务器"
            cd build/web && npx http-server -p $PORT
        else
            echo "❌ Node.js未安装，请使用其他启动方式"
        fi
        ;;
    3)
        echo "🌐 在浏览器中打开Flutter Web版本..."
        open build/web/index.html
        echo "✅ 已在默认浏览器中打开Flutter Web版本"
        ;;
    *)
        echo "❌ 无效选择，请重新运行脚本"
        exit 1
        ;;
esac 