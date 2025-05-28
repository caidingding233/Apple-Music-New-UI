#!/bin/bash

# Apple Music 鸿蒙版构建脚本
# 使用方法: ./build.sh --product-name [设备名称]

set -e

echo "🎵 开始构建 Apple Music 鸿蒙版..."

# 默认产品名称
PRODUCT_NAME="default"
BUILD_MODE="debug"
FLUTTER_ROOT=""

# 解析命令行参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --product-name)
      PRODUCT_NAME="$2"
      shift 2
      ;;
    --mode)
      BUILD_MODE="$2"
      shift 2
      ;;
    --flutter-root)
      FLUTTER_ROOT="$2"
      shift 2
      ;;
    *)
      echo "未知参数: $1"
      exit 1
      ;;
  esac
done

# 检查鸿蒙开发环境
echo "📱 检查鸿蒙开发环境..."

if [ -z "$HARMONY_HOME" ]; then
  echo "❌ 错误: 未设置 HARMONY_HOME 环境变量"
  echo "请设置鸿蒙SDK路径: export HARMONY_HOME=/path/to/harmony/sdk"
  exit 1
fi

if [ ! -d "$HARMONY_HOME" ]; then
  echo "❌ 错误: 鸿蒙SDK路径不存在: $HARMONY_HOME"
  exit 1
fi

# 检查鸿蒙Flutter环境
if [ -n "$FLUTTER_ROOT" ]; then
  export PATH="$FLUTTER_ROOT/bin:$PATH"
elif [ -z "$(which flutter)" ]; then
  echo "❌ 错误: 未找到Flutter命令"
  echo "请确保Flutter已正确安装或使用 --flutter-root 指定路径"
  exit 1
fi

echo "✅ 鸿蒙开发环境检查完成"

# 清理之前的构建
echo "🧹 清理之前的构建..."
rm -rf build/
rm -rf .dart_tool/

# 安装依赖
echo "📦 安装Flutter依赖..."
flutter pub get

# 检查代码
echo "🔍 检查代码..."
flutter analyze

# 构建Flutter应用
echo "🔨 构建Flutter应用..."
flutter build apk --$BUILD_MODE

# 准备鸿蒙资源
echo "📱 准备鸿蒙应用资源..."

# 创建entry模块结构
mkdir -p harmony/entry/src/main/{ets,resources}
mkdir -p harmony/entry/src/main/resources/{base,rawfile}
mkdir -p harmony/entry/src/main/resources/base/{element,media,profile}

# 复制Flutter构建产物
echo "📁 复制Flutter构建产物..."
cp -r build/app/outputs/flutter-apk/* harmony/entry/src/main/resources/rawfile/

# 生成鸿蒙配置文件
echo "⚙️ 生成鸿蒙配置文件..."

# 创建module.json5
cat > harmony/entry/src/main/module.json5 << EOF
{
  "module": {
    "name": "entry",
    "type": "entry",
    "description": "Apple Music 鸿蒙版主模块",
    "mainElement": "EntryAbility",
    "deviceTypes": [
      "phone",
      "tablet",
      "2in1",
      "tv",
      "car",
      "default"
    ],
    "deliveryWithInstall": true,
    "installationFree": false,
    "pages": "src/main/ets/pages/Index",
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ts",
        "description": "Apple Music 鸿蒙版",
        "icon": "src/main/resources/base/media/icon.png",
        "label": "Apple Music",
        "startWindowIcon": "src/main/resources/base/media/icon.png",
        "startWindowBackground": "src/main/resources/base/element/color.json",
        "exported": true,
        "skills": [
          {
            "entities": [
              "entity.system.home"
            ],
            "actions": [
              "action.system.home"
            ]
          }
        ]
      }
    ],
    "extensionAbilities": [
      {
        "name": "MediaSessionExtAbility",
        "srcEntry": "./ets/extensionability/MediaSessionExtAbility.ts",
        "type": "mediaSession",
        "exported": true
      }
    ],
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET",
        "reason": "网络访问权限，用于加载音乐资源"
      },
      {
        "name": "ohos.permission.WRITE_AUDIO",
        "reason": "音频写入权限，用于音频播放"
      },
      {
        "name": "ohos.permission.READ_AUDIO",
        "reason": "音频读取权限，用于音频播放"
      }
    ]
  }
}
EOF

# 创建EntryAbility.ts
cat > harmony/entry/src/main/ets/entryability/EntryAbility.ts << EOF
import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
EOF

# 创建Index.ets主页面
cat > harmony/entry/src/main/ets/pages/Index.ets << EOF
import webview from '@ohos.web.webview';

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Web({ src: "resource://rawfile/flutter_assets/index.html", controller: this.controller })
        .width('100%')
        .height('100%')
        .onPageEnd(() => {
          console.info('Flutter应用加载完成');
        })
        .onErrorReceive((event) => {
          console.error('Flutter应用加载失败:', event.error);
        })
    }
    .width('100%')
    .height('100%')
  }
}
EOF

# 使用鸿蒙构建工具编译
echo "🔨 使用鸿蒙构建工具编译应用..."

cd harmony

# 检查是否有hvigor构建工具
if [ -f "hvigorw" ]; then
  echo "使用项目内置hvigor构建..."
  ./hvigorw assembleHap --mode $BUILD_MODE
elif command -v hvigor &> /dev/null; then
  echo "使用全局hvigor构建..."
  hvigor assembleHap --mode $BUILD_MODE
else
  echo "⚠️ 警告: 未找到hvigor构建工具"
  echo "请确保已正确安装鸿蒙开发环境"
  echo "或手动使用DevEco Studio打开harmony目录进行构建"
fi

cd ..

echo "✅ Apple Music 鸿蒙版构建完成!"
echo "📱 产品名称: $PRODUCT_NAME"
echo "🔧 构建模式: $BUILD_MODE"
echo "📦 输出目录: harmony/entry/build/default/outputs/default/"

# 显示构建结果
if [ -d "harmony/entry/build/default/outputs/default/" ]; then
  echo "🎉 构建产物:"
  ls -la harmony/entry/build/default/outputs/default/
else
  echo "⚠️ 构建产物目录未找到，可能构建失败"
fi

echo ""
echo "🚀 接下来的步骤:"
echo "1. 使用DevEco Studio打开 harmony 目录"
echo "2. 配置签名信息"
echo "3. 连接鸿蒙设备或启动模拟器"
echo "4. 点击运行安装到设备"
echo ""
echo "📚 更多信息请参考: https://developer.harmonyos.com/" 