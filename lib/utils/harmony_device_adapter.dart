import 'package:flutter/material.dart';
import 'dart:math';

/// 鸿蒙设备类型
enum HarmonyDeviceType {
  phone,      // 手机
  tablet,     // 平板
  tv,         // 智慧屏/电视
  car,        // 车机
  watch,      // 手表
  unknown,    // 未知设备
}

/// 鸿蒙多终端设备适配器（简化版）
class HarmonyDeviceAdapter {
  static HarmonyDeviceAdapter? _instance;
  static HarmonyDeviceAdapter get instance {
    _instance ??= HarmonyDeviceAdapter._internal();
    return _instance!;
  }

  HarmonyDeviceAdapter._internal();

  HarmonyDeviceType _deviceType = HarmonyDeviceType.unknown;
  bool _isHarmonyOS = false;
  Size _screenSize = const Size(400, 800);
  Orientation _orientation = Orientation.portrait;

  /// 初始化设备适配器
  Future<void> initialize(BuildContext context) async {
    // 获取屏幕信息
    final mediaQuery = MediaQuery.of(context);
    _screenSize = mediaQuery.size;
    _orientation = mediaQuery.orientation;

    // 暂时通过屏幕尺寸推断设备类型（后续集成鸿蒙SDK后启用真实检测）
    _deviceType = _inferDeviceTypeFromScreen();
    
    // TODO: 后续集成鸿蒙Flutter SDK后启用
    // _isHarmonyOS = await FlutterOhosPlugin.isRunningOnHarmonyOS;
    print('设备适配器初始化完成，设备类型: $_deviceType');
  }

  /// 通过屏幕尺寸推断设备类型
  HarmonyDeviceType _inferDeviceTypeFromScreen() {
    final diagonal = _calculateScreenDiagonal();
    
    if (diagonal >= 32) {
      return HarmonyDeviceType.tv; // 大屏设备
    } else if (diagonal >= 10) {
      return HarmonyDeviceType.tablet; // 平板
    } else if (diagonal >= 2) {
      return HarmonyDeviceType.phone; // 手机
    } else {
      return HarmonyDeviceType.watch; // 手表或小屏设备
    }
  }

  /// 计算屏幕对角线尺寸（英寸）
  double _calculateScreenDiagonal() {
    final width = _screenSize.width;
    final height = _screenSize.height;
    final diagonal = sqrt(width * width + height * height);
    // 假设密度为160 DPI作为基准
    return diagonal / 160;
  }

  /// 获取设备类型
  HarmonyDeviceType get deviceType => _deviceType;

  /// 是否为鸿蒙系统
  bool get isHarmonyOS => _isHarmonyOS;

  /// 是否为手机
  bool get isPhone => _deviceType == HarmonyDeviceType.phone;

  /// 是否为平板
  bool get isTablet => _deviceType == HarmonyDeviceType.tablet;

  /// 是否为智慧屏/电视
  bool get isTV => _deviceType == HarmonyDeviceType.tv;

  /// 是否为车机
  bool get isCar => _deviceType == HarmonyDeviceType.car;

  /// 是否为手表
  bool get isWatch => _deviceType == HarmonyDeviceType.watch;

  /// 是否为横屏
  bool get isLandscape => _orientation == Orientation.landscape;

  /// 是否为竖屏
  bool get isPortrait => _orientation == Orientation.portrait;

  /// 获取屏幕尺寸
  Size get screenSize => _screenSize;

  /// 获取适配的边距
  EdgeInsets getAdaptivePadding() {
    switch (_deviceType) {
      case HarmonyDeviceType.tv:
        return const EdgeInsets.all(48.0); // 大屏需要更大边距
      case HarmonyDeviceType.tablet:
        return const EdgeInsets.all(24.0); // 平板中等边距
      case HarmonyDeviceType.car:
        return const EdgeInsets.all(32.0); // 车机考虑操作安全距离
      case HarmonyDeviceType.phone:
        return const EdgeInsets.all(16.0); // 手机标准边距
      case HarmonyDeviceType.watch:
        return const EdgeInsets.all(8.0);  // 手表紧凑边距
      default:
        return const EdgeInsets.all(16.0);
    }
  }

  /// 获取适配的字体大小
  double getAdaptiveFontSize(double baseFontSize) {
    switch (_deviceType) {
      case HarmonyDeviceType.tv:
        return baseFontSize * 1.8; // 大屏字体放大
      case HarmonyDeviceType.tablet:
        return baseFontSize * 1.3; // 平板字体适中放大
      case HarmonyDeviceType.car:
        return baseFontSize * 1.5; // 车机字体清晰易读
      case HarmonyDeviceType.phone:
        return baseFontSize; // 手机标准字体
      case HarmonyDeviceType.watch:
        return baseFontSize * 0.8; // 手表字体紧凑
      default:
        return baseFontSize;
    }
  }

  /// 获取适配的图标大小
  double getAdaptiveIconSize(double baseIconSize) {
    switch (_deviceType) {
      case HarmonyDeviceType.tv:
        return baseIconSize * 2.0; // 大屏图标明显放大
      case HarmonyDeviceType.tablet:
        return baseIconSize * 1.4; // 平板图标适度放大
      case HarmonyDeviceType.car:
        return baseIconSize * 1.6; // 车机图标便于操作
      case HarmonyDeviceType.phone:
        return baseIconSize; // 手机标准图标
      case HarmonyDeviceType.watch:
        return baseIconSize * 0.7; // 手表图标紧凑
      default:
        return baseIconSize;
    }
  }

  /// 获取适配的布局列数
  int getAdaptiveColumns() {
    switch (_deviceType) {
      case HarmonyDeviceType.tv:
        return isLandscape ? 6 : 4; // 大屏多列显示
      case HarmonyDeviceType.tablet:
        return isLandscape ? 4 : 3; // 平板适中列数
      case HarmonyDeviceType.car:
        return isLandscape ? 3 : 2; // 车机简化布局
      case HarmonyDeviceType.phone:
        return isLandscape ? 3 : 2; // 手机标准布局
      case HarmonyDeviceType.watch:
        return 1; // 手表单列显示
      default:
        return 2;
    }
  }

  /// 是否应该显示侧边栏
  bool shouldShowSidebar() {
    return (isTablet || isTV) && isLandscape;
  }

  /// 是否应该使用底部导航
  bool shouldUseBottomNavigation() {
    return isPhone || (isTablet && isPortrait);
  }

  /// 是否应该显示更多详细信息
  bool shouldShowDetailedInfo() {
    return isTablet || isTV;
  }

  /// 获取适配的动画时长
  Duration getAdaptiveAnimationDuration(Duration baseDuration) {
    switch (_deviceType) {
      case HarmonyDeviceType.tv:
        return Duration(milliseconds: (baseDuration.inMilliseconds * 1.2).round()); // 大屏动画稍慢
      case HarmonyDeviceType.car:
        return Duration(milliseconds: (baseDuration.inMilliseconds * 0.8).round()); // 车机动画快速
      case HarmonyDeviceType.watch:
        return Duration(milliseconds: (baseDuration.inMilliseconds * 0.6).round()); // 手表动画快速
      default:
        return baseDuration; // 其他设备标准动画
    }
  }

  /// 更新屏幕方向
  void updateOrientation(Orientation orientation) {
    _orientation = orientation;
  }
} 