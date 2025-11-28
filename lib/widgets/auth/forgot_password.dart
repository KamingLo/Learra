import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'verify_code.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final ApiService _apiService = ApiService(); 
  
  bool _isLoading = false;
  String? _errorMessage;
  static const Color _fieldFillColor = Color(0xFFF8F8FA);
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
    final lower = cleaned.toLowerCase();

    if (lower.isEmpty) return 'Terjadi kesalahan, silakan coba lagi.';
    if (_containsAll(lower, ['email', 'used']) ||
        _containsAll(lower, ['email', 'sudah', 'digunakan']) ||
        _containsAll(lower, ['email', 'already'])) {
      return 'Email sudah digunakan.';
    }
    if (_containsAll(lower, ['email', 'not', 'registered']) ||
        _containsAll(lower, ['email', 'belum', 'terdaftar'])) {
      return 'Email tidak terdaftar.';
    }
    if (_containsAll(lower, ['email', 'empty']) ||
        _containsAll(lower, ['email', 'required']) ||
        _containsAll(lower, ['email', 'kosong'])) {
      return 'Silakan isi email.';
    }
    if (_containsAll(lower, ['email', 'invalid']) ||
        _containsAll(lower, ['email', 'not valid'])) {
      return 'Email tidak valid.';
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 16, color: Colors.black54),
      floatingLabelStyle: const TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.w600, 
        color: Colors.black87,
        backgroundColor: _fieldFillColor
      ),
      filled: true,
      fillColor: _fieldFillColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFDCDDE4), width: 1.4)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFDCDDE4), width: 1.4)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF1ABC75), width: 1.6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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

  Future<void> _handleSendCode() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Silakan isi email.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final response = await _apiService.post(
        '/auth/forgot-password',
        body: {'email': _emailController.text.trim()},
      );

      if (response['error'] != null) {
        throw Exception(response['message'] ?? 'Gagal mengirim kode reset');
      }

      if (!mounted) return;
      _showSuccessMessage('Kode OTP berhasil dikirim.');
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      
      // Ke halaman Verifikasi (Kirim Parameter Email)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyCodeScreen(
            email: _emailController.text, // DATA DIKIRIM KE SINI
          ),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = _friendlyErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                                      'Lupa Password',
                                      style:
                                          theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Center(
                                    child: Text(
                                      'Masukkan email Anda yang terdaftar',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  if (_errorMessage != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _errorMessage == 'Kode OTP berhasil dikirim.'
                                            ? _successColor.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: _errorMessage == 'Kode OTP berhasil dikirim.'
                                              ? _successColor
                                              : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                  ],
                                  TextField(
                                    controller: _emailController,
                                    decoration: _inputDecoration('Email'),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildPrimaryButton(
                                    label: 'Kirim Kode',
                                    onPressed: _handleSendCode,
                                    isLoading: _isLoading,
                                  ),
                                  const SizedBox(height: 24),
                                  Center(
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF156E2F),
                                      ),
                                      child: const Text(
                                        'Kembali ke Login',
                                        style:
                                            TextStyle(fontWeight: FontWeight.w600),
                                      ),
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