import 'dart:async';
import 'package:flutter/foundation.dart';

/// 用户模型
class User {
  final String id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? avatar;
  final bool isPremium;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.avatar,
    required this.isPremium,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatar: json['avatar'] ?? '',
      isPremium: json['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'isPremium': isPremium,
    };
  }
}

/// 认证服务
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _needs2FA = false;
  String? _pending2FAUser;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get needs2FA => _needs2FA;

  // 模拟用户数据库
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'username': '音乐爱好者',
      'email': 'music@example.com',
      'phoneNumber': '+86 138 0013 8000',
      'password': '123456',
      'isPremium': true,
    },
    {
      'id': '2',
      'username': '普通用户',
      'email': 'test@example.com',
      'phoneNumber': '+86 139 0013 9000',
      'password': 'test123',
      'isPremium': false,
    },
  ];

  /// 使用邮箱或手机号登录
  Future<bool> login(String emailOrPhone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 1));

      // 查找用户（支持邮箱或手机号）
      final userData = _mockUsers.firstWhere(
        (user) => 
          user['email'] == emailOrPhone || 
          user['phoneNumber'] == emailOrPhone,
        orElse: () => {},
      );

      if (userData.isNotEmpty && userData['password'] == password) {
        // 模拟Apple需要2FA验证
        _pending2FAUser = userData['id'];
        _needs2FA = true;
        _isLoading = false;
        notifyListeners();
        return true; // 返回true表示第一步验证成功，需要2FA
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 验证2FA码
  Future<bool> verify2FA(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 1));

      // 模拟2FA验证（简单的6位数字验证）
      if (code == '123456' && _pending2FAUser != null) {
        // 查找用户数据
        final userData = _mockUsers.firstWhere(
          (user) => user['id'] == _pending2FAUser,
        );

        _currentUser = User(
          id: userData['id'],
          username: userData['username'],
          email: userData['email'],
          phoneNumber: userData['phoneNumber'],
          isPremium: userData['isPremium'],
        );

        _isLoggedIn = true;
        _needs2FA = false;
        _pending2FAUser = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 重新发送2FA验证码
  Future<bool> resend2FA() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();
      return true; // 模拟发送成功
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 注册
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 2));

      // 检查邮箱是否已存在
      final existingUser = _mockUsers.any((user) => user['email'] == email);
      
      if (!existingUser) {
        final newUser = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'username': username,
          'email': email,
          'password': password,
          'avatar': 'https://via.placeholder.com/100',
          'isPremium': false,
        };
        
        _mockUsers.add(newUser);
        _currentUser = User.fromJson(newUser);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 登出
  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    _needs2FA = false;
    _pending2FAUser = null;
    notifyListeners();
  }

  /// 自动登录（从本地存储恢复）
  Future<void> tryAutoLogin() async {
    // 这里可以从SharedPreferences或其他本地存储中恢复用户信息
    // 暂时跳过自动登录
  }
} 