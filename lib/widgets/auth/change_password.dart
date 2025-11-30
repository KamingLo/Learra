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
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;

  // Style constants
  static const Color _fieldFillColor = Color(0xFFF8F8FA);
  static const Color _successColor = Color(0xFF1ED760); // Warna sukses (Hijau)
  static const LinearGradient _primaryGradient = LinearGradient(
    colors: [Color(0xFF1ED760), Color(0xFF0EAD3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  bool _containsAll(String source, List<String> tokens) {
    final lower = source.toLowerCase();
    return tokens.every(lower.contains);
  }

  // Helper untuk membersihkan pesan error dari backend
  String _friendlyErrorMessage(Object error) {
    final raw = error.toString().replaceAll('Exception: ', '').trim();
    final cleaned = raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final lower = cleaned.toLowerCase();
    if (lower.isEmpty) return 'Terjadi kesalahan, silakan coba lagi.';

    if (_containsAll(lower, ['password', 'match']) ||
        _containsAll(lower, ['password', 'tidak', 'sama'])) {
      return 'Konfirmasi password tidak sesuai.';
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
              color: Colors.black.withValues(alpha:0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back, color: Colors.black87),
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

  InputDecoration _inputDecoration({
    required String label,
    Widget? suffixIcon,
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
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _handleSubmit() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    // --- Validasi Client Side ---
    if (newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => _errorMessage = 'Silakan lengkapi semua kolom.');
      return;
    }

    if (newPass.length < 8) {
      setState(() => _errorMessage = 'Password minimal 8 karakter.');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'Konfirmasi password tidak cocok.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Endpoint API Reset Password
      final response = await _apiService.post(
        '/auth/reset-password',
        body: {
          'resetToken': widget.resetToken,
          'newPassword': newPass,
          'confirmNewPassword': confirmPass,
        },
      );

      if (response['error'] != null) {
        throw Exception(response['message'] ?? 'Gagal mengubah password');
      }

      if (!mounted) return;

      // --- SUKSES ---
      // 1. Tampilkan pesan sukses di box notifikasi (Hijau)
      setState(() {
        _errorMessage = 'Password berhasil diubah.';
      });

      // 2. Beri jeda waktu 2 detik agar user membaca notifikasi
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // 3. Bersihkan sesi (Logout) dan redirect ke Halaman Login
      await SessionService.clearSession();
      
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false, // Hapus semua route sebelumnya agar tidak bisa back
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
    
    // Cek apakah pesan saat ini adalah pesan sukses
    final isSuccessMessage = _errorMessage == 'Password berhasil diubah.';

    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: SizedBox(
          height: 48,
          child: Image.asset(
            'assets/IconApp/LearraFull.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text("Learra",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold));
            },
          ),
        ),
      ),
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
                                    color: Colors.black.withValues(alpha:0.08),
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
                                      'Buat Password Baru',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Center(
                                    child: Text(
                                      'Masukkan password baru Anda yang aman\ndan mudah diingat.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // --- NOTIFIKASI ERROR / SUKSES ---
                                  if (_errorMessage != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        // Ubah warna background berdasarkan status sukses/gagal
                                        color: isSuccessMessage
                                            ? _successColor.withValues(alpha:0.1)
                                            : Colors.red.withValues(alpha:0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          // Ubah warna teks berdasarkan status sukses/gagal
                                          color: isSuccessMessage
                                              ? _successColor
                                              : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                  ],

                                  // Field Password Baru
                                  TextField(
                                    controller: _newPasswordController,
                                    obscureText: !_isNewPasswordVisible,
                                    decoration: _inputDecoration(
                                      label: 'Password Baru',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isNewPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isNewPasswordVisible =
                                                !_isNewPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Field Konfirmasi Password
                                  TextField(
                                    controller: _confirmPasswordController,
                                    obscureText: !_isConfirmPasswordVisible,
                                    decoration: _inputDecoration(
                                      label: 'Konfirmasi Password',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isConfirmPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  _buildPrimaryButton(
                                    label: 'Simpan Password',
                                    onPressed: _handleSubmit,
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