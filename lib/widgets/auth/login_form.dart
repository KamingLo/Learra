import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../main.dart'; 
import 'forgot_password.dart'; // Pastikan file ini ada di folder yang sama atau sesuaikan path

class LoginForm extends StatefulWidget {
  final bool isLoginMode;
  final VoidCallback? onSwitchToRegister;

  const LoginForm({
    super.key,
    required this.isLoginMode,
    this.onSwitchToRegister,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  static const Color _fieldFillColor = Color(0xFFF8F8FA);
  static const Color _iconColor = Color(0xFF6B6B6B);
  static const LinearGradient _primaryGradient = LinearGradient(
    colors: [Color(0xFF1ED760), Color(0xFF0EAD3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  bool _containsAll(String source, List<String> tokens) {
    final lower = source.toLowerCase();
    return tokens.every(lower.contains);
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _friendlyErrorMessage(Object error) {
    final raw = error.toString().replaceAll('Exception: ', '').trim();
    final cleaned = raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final lower = cleaned.toLowerCase();

    if (lower.isEmpty) return 'Terjadi kesalahan, silakan coba lagi.';
    if (_containsAll(lower, ['email', 'empty']) ||
        _containsAll(lower, ['email', 'required']) ||
        _containsAll(lower, ['email', 'kosong'])) {
      return 'Silakan isi email.';
    }
    if (_containsAll(lower, ['password', 'empty']) ||
        _containsAll(lower, ['password', 'required']) ||
        _containsAll(lower, ['password', 'kosong'])) {
      return 'Silakan isi password.';
    }
    if (_containsAll(lower, ['email', 'not', 'registered']) ||
        _containsAll(lower, ['email', 'belum', 'terdaftar'])) {
      return 'Email belum terdaftar.';
    }
    if (_containsAll(lower, ['email', 'used']) ||
        _containsAll(lower, ['email', 'sudah', 'digunakan']) ||
        _containsAll(lower, ['email', 'already'])) {
      return 'Email sudah digunakan.';
    }
    if (_containsAll(lower, ['email', 'invalid']) ||
        _containsAll(lower, ['email', 'not valid'])) {
      return 'Email tidak valid.';
    }
    if (_containsAll(lower, ['password', 'invalid']) ||
        _containsAll(lower, ['password', 'not valid'])) {
      return 'Password tidak valid.';
    }
    if (lower.contains('credential') ||
        lower.contains('unauthorized') ||
        lower.contains('user tidak ditemukan') ||
        lower.contains('user not found')) {
      return 'Email atau password tidak valid.';
    }
    return cleaned;
  }

  Widget _buildBackButton(ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 16, color: Colors.black54),
      floatingLabelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        backgroundColor: _fieldFillColor,
      ),
      filled: true,
      fillColor: _fieldFillColor,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDCDDE4), width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDCDDE4), width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF1ABC75), width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Silakan isi email.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Silakan isi password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.post('/auth/login', body: {
        'email': _loginEmailController.text.trim(),
        'password': _loginPasswordController.text,
      });

      if (response['error'] != null) {
        throw Exception(response['message'] ?? 'Login gagal');
      }

      final token = response['token'] as String?;
      final role = response['user']?['role'] as String? ?? 'guest';
      final id = response['user']?['id'] as String? ?? '';
      final name = response['user']?['name'] as String? ?? '';

      if (token != null && token.isNotEmpty) {
        await SessionService.saveSession(role, token, id, name);

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthCheck()),
          (route) => false,
        );
      } else {
        throw Exception("Token tidak valid dari server");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const cardColor = Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBackButton(theme),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      'Masuk',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  TextField(
                    controller: _loginEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _loginPasswordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(
                      'Kata Sandi',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: _iconColor,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // NAVIGASI KE FORGOT PASSWORD
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Lupa Password?',
                        style: TextStyle(color: Color(0xFF156E2F)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPrimaryButton(
                    label: 'Masuk',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: widget.onSwitchToRegister,
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                          children: const [
                            TextSpan(text: 'Belum punya akun? '),
                            TextSpan(
                              text: 'Daftar di sini',
                              style: TextStyle(
                                color: Color(0xFF156E2F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}