import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../main.dart'; // PENTING: Import main.dart untuk akses AuthCheck

enum AuthMode { login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();

  // Register Controllers
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerBirthDateController = TextEditingController();
  final _registerNikController = TextEditingController();
  final _registerJobController = TextEditingController();

  AuthMode _mode = AuthMode.login;
  bool _isLoading = false;
  
  // --- STATE BARU UNTUK ERROR ---
  String? _errorMessage; 

  final _incomeRanges = const [
    '0 - 14.999.999',
    '15.000.000 - 49.999.999',
    '50.000.000 - 250.000.000',
    '250.000.000 - 499.000.000',
    '>= 500.000.000',
  ];

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _registerBirthDateController.dispose();
    _registerNikController.dispose();
    _registerJobController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Reset error sebelum request baru
    setState(() {
      _isLoading = true;
      _errorMessage = null; 
    });

    try {
      final response = await _apiService.post('/auth/login', body: {
        'email': _loginEmailController.text.trim(),
        'password': _loginPasswordController.text,
      });

      // Cek apakah response valid (tergantung format API kamu)
      // Jika API mengembalikan error code tapi tidak throw exception, handle di sini
      if (response['error'] != null) {
        throw Exception(response['message'] ?? 'Login gagal');
      }

      final token = response['token'] as String?;
      final role = response['user']?['role'] as String? ?? 'guest';

      if (token != null && token.isNotEmpty) {
        await SessionService.saveSession(role, token);
        
        if (!mounted) return;

        // --- PERBAIKAN NAVIGASI UTAMA ---
        // Restart aplikasi ke AuthCheck agar role terbaca ulang
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthCheck()), 
          (route) => false, // Hapus semua history back
        );

      } else {
        throw Exception("Token tidak valid dari server");
      }

    } catch (e) {
      // Tampilkan error di UI (bukan SnackBar)
      if (mounted) {
        setState(() {
          // Bersihkan string error agar lebih enak dibaca user
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol Back (Opsional jika login adalah halaman utama)
                if (Navigator.canPop(context))
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF111111)),
                  ),
                
                const SizedBox(height: 12),
                _buildLogo(),
                const SizedBox(height: 24),
                
                Center(
                  child: Column(
                    children: [
                      Text(
                        _mode == AuthMode.login ? 'Masuk' : 'Buat Akun',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF024000),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _mode == AuthMode.login ? 'Masuk ke akunmu' : 'Buat akun sekarang',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF3F3F3F), fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Login / Register
                if (_mode == AuthMode.login)
                  _buildLoginForm()
                else
                  _buildRegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF06A900), width: 2),
        ),
        child: const Icon(
          Icons.login,
          color: Color(0xFF06A900),
          size: 36,
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _loginEmailController,
          label: 'Email',
          hint: 'Masukkan email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _loginPasswordController,
          label: 'Password',
          hint: 'Masukkan password',
          obscureText: true,
        ),
        
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF06A900),
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('Lupa Password?'),
          ),
        ),
        
        // --- ERROR MESSAGE AREA ---
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

        _buildPrimaryButton(
          label: 'Masuk',
          onPressed: _isLoading ? null : _handleLogin,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 24),
        _buildDividerWithText('atau Daftar'),
        const SizedBox(height: 16),
        _buildSecondaryButton(
          label: 'Daftar Akun Baru',
          onPressed: () {
            setState(() {
              _mode = AuthMode.register;
              _errorMessage = null; // Reset error saat pindah mode
            });
          },
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ... (Field register lainnya sama, saya persingkat untuk fokus ke logic)
        _buildTextField(
            controller: _registerNameController, label: 'Nama', hint: 'Nama Lengkap'),
        const SizedBox(height: 12),
        _buildTextField(
            controller: _registerEmailController, label: 'Email', hint: 'Email'),
        const SizedBox(height: 12),
        _buildTextField(
            controller: _registerPasswordController, label: 'Password', hint: 'Password', obscureText: true),
        
        // ... Tambahkan field lainnya sesuai kebutuhan ...

        const SizedBox(height: 24),
        
        // Error Message untuk Register (jika ada)
        if (_errorMessage != null)
           Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),

        _buildPrimaryButton(
          label: 'Daftar Akun Baru',
          onPressed: () {
            // Tambahkan logic register di sini
          },
        ),
        const SizedBox(height: 16),
        _buildDividerWithText('atau punya akun?'),
        const SizedBox(height: 16),
        _buildSecondaryButton(
          label: 'Masuk ke akunmu',
          onPressed: () {
            setState(() {
              _mode = AuthMode.login;
              _errorMessage = null;
            });
          },
        ),
      ],
    );
  }

  // --- Helper Widgets Tetap Sama ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    const borderColor = Color(0xFF3F3F3F);
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF06A900), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    // ... Kode dropdown sama ...
    return Container(); // Placeholder agar kode tidak kepanjangan
  }

  Widget _buildPrimaryButton({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF06A900),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildSecondaryButton({required String label, required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF06A900),
        side: const BorderSide(color: Color(0xFF06A900), width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        backgroundColor: Colors.white,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF3F3F3F), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: const TextStyle(color: Color(0xFF3F3F3F))),
        ),
        const Expanded(child: Divider(color: Color(0xFF3F3F3F), thickness: 1)),
      ],
    );
  }
}