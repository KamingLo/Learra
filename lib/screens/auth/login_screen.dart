import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

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

  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerBirthDateController = TextEditingController();
  final _registerNikController = TextEditingController();
  final _registerJobController = TextEditingController();

  String? _selectedIncomeRange;
  AuthMode _mode = AuthMode.login;
  bool _isLoginLoading = false;

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
    setState(() => _isLoginLoading = true);
    try {
      final response = await _apiService.post('/auth/login', body: {
        'email': _loginEmailController.text.trim(),
        'password': _loginPasswordController.text,
      });
      debugPrint('Login response: $response');
      final token = response['token'] as String?;
      final role = response['user']?['role'] as String? ?? 'guest';

      if (token != null && token.isNotEmpty) {
        await SessionService.saveSession(role, token);
      } else {
        debugPrint('Token tidak ditemukan pada response login.');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Login berhasil')),
      );
    } catch (e) {
      debugPrint('Login error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoginLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              if (_mode == AuthMode.login)
                _buildLoginForm()
              else
                _buildRegisterForm(),
            ],
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
        const SizedBox(height: 0),
        _buildPrimaryButton(
          label: 'Masuk',
          onPressed: _isLoginLoading ? null : _handleLogin,
          isLoading: _isLoginLoading,
        ),
        const SizedBox(height: 24),
        _buildDividerWithText('atau Daftar'),
        const SizedBox(height: 16),
        _buildSecondaryButton(
          label: 'Daftar Akun Baru',
          onPressed: () => setState(() => _mode = AuthMode.register),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _registerNameController,
          label: 'Nama',
          hint: 'Masukkan nama lengkap',
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerEmailController,
          label: 'Email',
          hint: 'Masukkan email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerPasswordController,
          label: 'Password',
          hint: 'Masukkan password',
          obscureText: true,
          suffixIcon: const Icon(Icons.visibility_off, color: Color(0xFF3F3F3F)),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerConfirmPasswordController,
          label: 'Ulangi password',
          hint: 'Konfirmasi password',
          obscureText: true,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerBirthDateController,
          label: 'Tanggal lahir',
          hint: 'DD/MM/YYYY',
          keyboardType: TextInputType.datetime,
          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF3F3F3F), size: 20),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerNikController,
          label: 'Nomor identitas (NIK)',
          hint: 'Masukkan NIK',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerJobController,
          label: 'Pekerjaan',
          hint: 'Masukkan pekerjaan',
        ),
        const SizedBox(height: 12),
        _buildDropdownField(),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          label: 'Daftar Akun Baru',
          onPressed: () {},
        ),
        const SizedBox(height: 16),
        _buildDividerWithText('atau punya akun?'),
        const SizedBox(height: 16),
        _buildSecondaryButton(
          label: 'Masuk ke akunmu',
          onPressed: () => setState(() => _mode = AuthMode.login),
        ),
      ],
    );
  }

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
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Rentang pendapatan',
        hintText: 'Pilih rentang pendapatanmu',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3F3F3F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3F3F3F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF06A900), width: 2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedIncomeRange,
          hint: const Text('Pilih rentang pendapatanmu  '),
          isExpanded: true,
          items: _incomeRanges
              .map((range) => DropdownMenuItem(
                    value: range,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(range),
                    ),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedIncomeRange = value),
        ),
      ),
    );
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
        const Expanded(
          child: Divider(color: Color(0xFF3F3F3F), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF3F3F3F)),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0xFF3F3F3F), thickness: 1),
        ),
      ],
    );
  }
}