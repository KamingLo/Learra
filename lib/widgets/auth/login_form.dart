import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../main.dart'; // Pastikan path ini sesuai dengan struktur project kamu

class LoginForm extends StatefulWidget {
  final bool isLoginMode; // true = login, false = register
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

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black54,
      ),
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

      if (token != null && token.isNotEmpty) {
        await SessionService.saveSession(role, token);

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
          _errorMessage = e.toString().replaceAll("Exception: ", "");
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

    // HAPUS Center & SingleChildScrollView di sini karena sudah dihandle AuthScreen
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
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
          mainAxisSize: MainAxisSize.min, // PENTING: Agar card tidak stretch full height
          children: [
            // Tombol Kembali
            InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => Navigator.of(context).maybePop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.arrow_back, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Kembali',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            
            // Judul Login
            Center(
              child: Text(
                'Login',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Error Message
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

            // Input Email
            TextField(
              controller: _loginEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Email'),
            ),
            const SizedBox(height: 20),

            // Input Password
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
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Lupa Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Lupa Password?',
                  style: TextStyle(color: Color(0xFF156E2F)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol Masuk
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1ABC75),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Link ke Register
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
    );
  }
}