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

  Widget _buildBackButton(ThemeData theme) {
    return InkWell(
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

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll("Exception: ", "");
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

    return Container(
      width: double.infinity,
      color: const Color(0xFFEFF1F5),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(theme),
                const SizedBox(height: 20),
                Container(
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
                        decoration: _inputDecoration('Nomor Identitas'),
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
                        value: _rentangGajiController.text.isEmpty
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
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
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
                                        AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
