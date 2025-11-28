import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback? onSwitchToLogin;
  const RegisterForm({super.key, this.onSwitchToLogin});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _apiService = ApiService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _identitasController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _rentangGajiController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  void _showSuccessMessage(String message) {
    setState(() => _errorMessage = message);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _errorMessage == message) {
        setState(() => _errorMessage = null);
      }
    });
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
    final raw = error.toString().replaceAll("Exception: ", "").trim();
    final cleaned = raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final lower = cleaned.toLowerCase();

    if (lower.isEmpty) return 'Terjadi kesalahan, silakan coba lagi';
    if (_containsAll(lower, ['email', 'not', 'registered']) ||
        _containsAll(lower, ['email', 'belum', 'terdaftar'])) {
      return 'Email belum terdaftar';
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
    if (_containsAll(lower, ['email', 'empty']) ||
        _containsAll(lower, ['email', 'required'])) {
      return 'Silakan isi email';
    }
    if (_containsAll(lower, ['password', 'invalid']) ||
        _containsAll(lower, ['password', 'not valid'])) {
      return 'Password tidak valid';
    }
    if (_containsAll(lower, ['password', 'empty']) ||
        _containsAll(lower, ['password', 'required'])) {
      return 'Silakan isi password';
    }
    if (_containsAll(lower, ['confirm', 'password']) &&
        (lower.contains('match') || lower.contains('sama'))) {
      return 'Konfirmasi password harus sama';
    }
    if (_containsAll(lower, ['nomor', 'identitas'])) {
      return 'Nomor identitas tidak valid';
    }
    return cleaned;
  }

  Widget _buildBackButton(ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (widget.onSwitchToLogin != null) {
          widget.onSwitchToLogin!();
        } else {
          Navigator.of(context).maybePop();
        }
      },
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

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  bool _validateFields() {
    String? message;
    if (_nameController.text.trim().isEmpty) {
      message = 'Silakan isi nama lengkap';
    } else if (_emailController.text.trim().isEmpty) {
      message = 'Silakan isi email';
    } else if (_passwordController.text.isEmpty) {
      message = 'Silakan isi password';
    } else if (_confirmPassController.text.isEmpty) {
      message = 'Silakan isi konfirmasi password';
    } else if (_passwordController.text != _confirmPassController.text) {
      message = 'Konfirmasi password harus sama';
    } else if (_identitasController.text.trim().isEmpty) {
      message = 'Silakan isi nomor identitas';
    } else if (_phoneController.text.trim().isEmpty) {
      message = 'Silakan isi nomor HP';
    } else if (_birthDateController.text.trim().isEmpty) {
      message = 'Silakan isi tanggal lahir';
    } else if (_addressController.text.trim().isEmpty) {
      message = 'Silakan isi alamat';
    } else if (_pekerjaanController.text.trim().isEmpty) {
      message = 'Silakan isi pekerjaan';
    } else if (_rentangGajiController.text.trim().isEmpty) {
      message = 'Silakan pilih rentang gaji';
    }

    if (message != null) {
      setState(() => _errorMessage = message);
      return false;
    }

    return true;
  }

  Future<void> _selectBirthDate() async {
    final initialDate = _birthDateController.text.isNotEmpty
        ? DateTime.tryParse(_birthDateController.text) ?? DateTime(2000, 1, 1)
        : DateTime(2000, 1, 1);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final colorScheme = Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF1ABC75),
              onSurface: Colors.black87,
            );
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: colorScheme),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _birthDateController.text = _formatDate(pickedDate);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_validateFields()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.post('/auth/register', body: {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
        "confirmPassword": _confirmPassController.text,
        "nomorIdentitas": _identitasController.text.trim(),
        "phone": _phoneController.text.trim(),
        "birthDate": _birthDateController.text.trim(),
        "address": _addressController.text.trim(),
        "pekerjaan": _pekerjaanController.text.trim(),
        "rentangGaji": _rentangGajiController.text.trim(),
        "role": "user",
      });

      if (response['error'] != null) {
        throw Exception(response['message'] ?? 'Register gagal');
      }

      if (!mounted) return;
      _showSuccessMessage('Registrasi berhasil, silakan login.');
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      widget.onSwitchToLogin?.call();

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyErrorMessage(e);
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    color: Colors.black.withValues(alpha:0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Daftar',
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
                        color: _errorMessage == 'Registrasi berhasil, silakan login.'
                            ? _successColor.withValues(alpha:0.1)
                            : Colors.red.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: _errorMessage == 'Registrasi berhasil, silakan login.'
                              ? _successColor
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration('Nama Lengkap'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
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
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPassController,
                    obscureText: _obscureConfirmPassword,
                    decoration: _inputDecoration(
                      'Konfirmasi Kata Sandi',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: _iconColor,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _identitasController,
                    decoration: _inputDecoration('Nomor Identitas (NIK)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: _inputDecoration('Nomor HP'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _birthDateController,
                    readOnly: true,
                    onTap: _selectBirthDate,
                    decoration: _inputDecoration(
                      'Tanggal Lahir',
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    decoration: _inputDecoration('Alamat'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pekerjaanController,
                    decoration: _inputDecoration('Pekerjaan'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _rentangGajiController.text.isEmpty
                        ? null
                        : _rentangGajiController.text,
                    items: const [
                      DropdownMenuItem(
                        value: '1.000.000 - 9.999.999',
                        child: Text('1.000.000 - 9.999.999'),
                      ),
                      DropdownMenuItem(
                        value: '10.000.000 - 49.999.999',
                        child: Text('10.000.000 - 49.999.999'),
                      ),
                      DropdownMenuItem(
                        value: '50.000.000 - 99.999.999',
                        child: Text('50.000.000 - 99.999.999'),
                      ),
                      DropdownMenuItem(
                        value: '100.000.000 +',
                        child: Text('≥ 100.000.000'),
                      ),
                    ],
                    onChanged: (value) {
                      _rentangGajiController.text = value ?? '';
                    },
                    decoration: _inputDecoration('Rentang Gaji'),
                  ),
                  const SizedBox(height: 24),
                  _buildPrimaryButton(
                    label: 'Daftar',
                    onPressed: _handleRegister,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: widget.onSwitchToLogin,
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black54),
                          children: [
                            TextSpan(text: 'Sudah punya akun? '),
                            TextSpan(
                              text: 'Masuk di sini',
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
