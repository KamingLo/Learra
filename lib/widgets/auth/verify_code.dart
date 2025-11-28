import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'change_password.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codeController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  static const Color _fieldFillColor = Color(0xFFF8F8FA);
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
  String _friendlyErrorMessage(Object error) {
    final raw = error.toString().replaceAll('Exception: ', '').trim();
    final cleaned = raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final cleanedEntities = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', '\'')
        .trim();

    final lower = cleanedEntities.toLowerCase();

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
    if (_containsAll(lower, ['code', 'invalid']) ||
        _containsAll(lower, ['kode', 'invalid'])) {
      return 'Kode OTP tidak valid.';
    }
    if (_containsAll(lower, ['code', 'empty']) ||
        _containsAll(lower, ['kode', 'kosong'])) {
      return 'Silakan isi kode OTP.';
    }
    if (lower.contains('expired') || lower.contains('kadaluarsa')) {
      return 'Kode OTP kadaluarsa, silakan kirim ulang kode.';
    }
    return cleanedEntities;
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

  InputDecoration _inputDecoration(String label) {
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
    );
  }

  Future<void> _handleVerify() async {
    if (_codeController.text.isEmpty) {
      setState(() => _errorMessage = 'Silakan isi kode OTP.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final response = await _apiService.post(
        '/auth/verify-code',
        body: {
          'email': widget.email,
          'code': _codeController.text.trim(),
        },
      );

      if (response['error'] != null) {
        throw Exception(response['message'] ?? 'Kode OTP tidak valid');
      }

      final resetToken = response['token'] ??
          response['data']?['token'] ??
          response['resetToken'] ??
          response['data']?['resetToken'];

      if (resetToken == null || resetToken.toString().isEmpty) {
        throw Exception('Kode OTP tidak ditemukan.');
      }

      if (!mounted) return;

      // Ke Halaman Ubah Password (Bawa Token Reset)
      final result = await Navigator.push<String?>(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasswordScreen(
            email: widget.email,
            resetToken: resetToken.toString(),
          ),
        ),
      );

      if (!mounted) return;
      if (result != null && result.isNotEmpty) {
        setState(() => _errorMessage = result);
      }
    } catch (e) {
      setState(() => _errorMessage = _friendlyErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.post(
        '/auth/forgot-password',
        body: {'email': widget.email},
      );

      if (response['error'] != null) {
        throw Exception(response['message'] ?? 'Gagal mengirim ulang kode');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP berhasil dikirim ulang.')),
      );
    } catch (e) {
      setState(() => _errorMessage = _friendlyErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isResending = false);
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
                                      'Verifikasi Kode',
                                      style:
                                          theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Text(
                                      'Kode OTP dikirim ke\n${widget.email}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
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
                                    controller: _codeController,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      letterSpacing: 2,
                                    ),
                                    decoration: _inputDecoration('Kode'),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildPrimaryButton(
                                    label: 'Verifikasi',
                                    onPressed: _handleVerify,
                                    isLoading: _isLoading,
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      onPressed:
                                          _isResending ? null : _handleResend,
                                      child: _isResending
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Kirim ulang kode OTP'),
                                    ),
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