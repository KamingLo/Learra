import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../screens/auth/auth_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const ChangePasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  static const Color _fieldFillColor = Color(0xFFF8F8FA);
  static const Color _iconColor = Color(0xFF6B6B6B);
  static const LinearGradient _primaryGradient = LinearGradient(
    colors: [Color(0xFF1ED760), Color(0xFF0EAD3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color _successColor = Color(0xFF1ED760);

  bool _containsAll(String source, List<String> tokens) {
    final lower = source.toLowerCase();
    return tokens.every(lower.contains);
  }

  String _friendlyErrorMessage(Object error) {
    final raw = error.toString().replaceAll('Exception: ', '').trim();
    final cleaned = raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final lower = cleaned.toLowerCase();

    if (lower.isEmpty) return 'Terjadi kesalahan, silakan coba lagi.';
    if (_containsAll(lower, ['email', 'used']) ||
        _containsAll(lower, ['email', 'sudah', 'digunakan']) ||
        _containsAll(lower, ['email', 'already'])) {
      return 'Email sudah digunakan.';
    }
    if (_containsAll(lower, ['email', 'not', 'registered']) ||
        _containsAll(lower, ['email', 'belum', 'terdaftar'])) {
      return 'Email belum terdaftar.';
    }
    if (_containsAll(lower, ['password', 'invalid'])) {
      return 'Password tidak valid.';
    }
    if (_containsAll(lower, ['password', 'empty']) ||
        _containsAll(lower, ['password', 'required'])) {
      return 'Silakan isi password baru.';
    }
    if (_containsAll(lower, ['password', 'minimum']) ||
        _containsAll(lower, ['password', 'minimal']) ||
        lower.contains('8 characters')) {
      return 'Password minimal 8 karakter.';
    }
    if ((_containsAll(lower, ['confirm', 'password']) ||
            _containsAll(lower, ['konfirmasi', 'password'])) &&
        (lower.contains('match') || lower.contains('sama'))) {
      return 'Password tidak sama.';
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

  InputDecoration _inputDecoration(
    String label, {
    required bool obscureValue,
    required VoidCallback onToggle,
  }) {
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
      suffixIcon: IconButton(
        icon: Icon(
          obscureValue ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: _iconColor,
        ),
        onPressed: onToggle,
      ),
    );
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
                : Text(
                    label,
                    style: const TextStyle(
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

  void _showSuccessMessage(String message) {
    setState(() => _errorMessage = message);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _errorMessage == message) {
        setState(() => _errorMessage = null);
      }
    });
  }
  Future<void> _handleChange() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Silakan isi password baru.');
      return;
    }
    if (confirm.isEmpty) {
      setState(() => _errorMessage = 'Silakan isi konfirmasi password.');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorMessage = 'Password minimal 8 karakter.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Password tidak sama.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    bool poppedDueToToken = false;
    try {
      final response = await _apiService.post(
        '/auth/reset-password',
        body: {
          'token': widget.resetToken,
          'password': _passwordController.text,
          'confirmPassword': _confirmController.text,
        },
      );

      if (response['error'] != null) {
        throw Exception(response['message'] ?? 'Gagal mengubah password');
      }

      await SessionService.clearSession();

      if (!mounted) return;
      
      _showSuccessMessage('Password berhasil diubah, silakan login.');
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      // KEMBALI KE LOGIN
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      final lower = e.toString().toLowerCase();
      final tokenError = lower.contains('invalid or expired token') ||
          (lower.contains('token') && lower.contains('expired'));

      if (tokenError) {
        poppedDueToToken = true;
        if (mounted) {
          Navigator.pop(context, 'Kode OTP sudah kadaluarsa, silakan kirim ulang kode.');
        }
        return;
      }

      if (mounted) {
        setState(() => _errorMessage = _friendlyErrorMessage(e));
      }
    } finally {
      if (mounted && !poppedDueToToken) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildBackButton(theme),
                          const SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                      'Password Baru',
                                      style:
                                          theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  if (_errorMessage != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _errorMessage == 'Password berhasil diubah, silakan login.'
                                            ? _successColor.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: _errorMessage == 'Password berhasil diubah, silakan login.'
                                              ? _successColor
                                              : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                  ],
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: _inputDecoration(
                                      'Password Baru',
                                      obscureValue: _obscurePassword,
                                      onToggle: () => setState(
                                        () => _obscurePassword = !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: _confirmController,
                                    obscureText: _obscureConfirm,
                                    decoration: _inputDecoration(
                                      'Konfirmasi Password',
                                      obscureValue: _obscureConfirm,
                                      onToggle: () => setState(
                                        () => _obscureConfirm = !_obscureConfirm,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildPrimaryButton(
                                    label: 'Ubah Password',
                                    onPressed: _handleChange,
                                    isLoading: _isLoading,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}