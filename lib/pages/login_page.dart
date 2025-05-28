import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musicplayer/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _2faController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _2faController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    
    bool success = await authService.login(
      _emailOrPhoneController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      // 第一步验证成功，显示2FA界面
      if (authService.needs2FA) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 验证码已发送到您的设备'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ 登录失败，请检查Apple ID和密码'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handle2FA() async {
    if (_2faController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ 请输入6位验证码'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authService = context.read<AuthService>();
    
    bool success = await authService.verify2FA(_2faController.text.trim());

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/demo');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ 验证码错误，请重试'),
          backgroundColor: Colors.red,
        ),
      );
      _2faController.clear();
    }
  }

  Future<void> _resend2FA() async {
    final authService = context.read<AuthService>();
    
    bool success = await authService.resend2FA();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📱 验证码已重新发送'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  String? _validateAppleID(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入Apple ID';
    }
    
    // 检查是否为邮箱格式
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // 检查是否为手机号格式（简化版，支持+86格式）
    final phoneRegex = RegExp(r'^\+86\s\d{3}\s\d{4}\s\d{4}$');
    
    if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
      return '请输入有效的邮箱或手机号';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF007AFF),  // Apple蓝色
              Color(0xFF5AC8FA),
              Color(0xFF34AADC),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Consumer<AuthService>(
                        builder: (context, authService, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Apple Logo和标题
                              const Icon(
                                Icons.apple,
                                size: 64,
                                color: Color(0xFF007AFF),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Apple Music',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                authService.needs2FA 
                                  ? '输入验证码' 
                                  : '使用您的Apple ID登录',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // 根据状态显示不同界面
                              if (!authService.needs2FA) ...[
                                // 登录表单
                                _buildLoginForm(authService),
                              ] else ...[
                                // 2FA验证表单
                                _build2FAForm(authService),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthService authService) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Apple ID字段（支持邮箱和手机号）
          TextFormField(
            controller: _emailOrPhoneController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Apple ID',
              hintText: '邮箱或手机号',
              prefixIcon: const Icon(Icons.account_circle),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: _validateAppleID,
          ),
          const SizedBox(height: 16),
          
          // 密码字段
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '密码',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              if (value.length < 6) {
                return '密码至少需要6位';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // 登录按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: authService.isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: authService.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '登录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 演示账户提示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Text(
                  '🍎 演示Apple ID',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'music@example.com / 123456',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '+86 138 0013 8000 / 123456',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2FA验证码: 123456',
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build2FAForm(AuthService authService) {
    return Column(
      children: [
        // 2FA说明
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.security,
                size: 48,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 8),
              Text(
                '双重认证',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '请输入发送到您受信任设备的6位验证码',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 2FA验证码输入
        TextFormField(
          controller: _2faController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          decoration: InputDecoration(
            labelText: '验证码',
            hintText: '123456',
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 验证按钮
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: authService.isLoading ? null : _handle2FA,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authService.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '验证',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 重新发送按钮
        TextButton(
          onPressed: authService.isLoading ? null : _resend2FA,
          child: Text(
            '没有收到验证码？',
            style: TextStyle(
              color: Colors.blue.shade600,
            ),
          ),
        ),
        
        // 返回登录按钮
        TextButton(
          onPressed: () {
            final authService = context.read<AuthService>();
            authService.logout(); // 重置状态
            _emailOrPhoneController.clear();
            _passwordController.clear();
            _2faController.clear();
          },
          child: Text(
            '使用其他Apple ID',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
} 