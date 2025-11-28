import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const ChangePasswordScreen({super.key, required this.email, required this.code});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscure = true;

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8F8FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFDCDDE4), width: 1.4)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF1ABC75), width: 1.6)),
      suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure)),
    );
  }

  Future<void> _handleChange() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = "Password tidak sama");
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // TODO: API CALL RESET PASSWORD
      await Future.delayed(const Duration(seconds: 1)); 

      if (!mounted) return;
      
      // KEMBALI KE LOGIN
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password berhasil diubah, silakan login.")));
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 20), spreadRadius: -10)]),
              child: Column(
                children: [
                  Text('Password Baru', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 32),
                  if (_errorMessage != null) Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  TextField(controller: _passwordController, obscureText: _obscure, decoration: _inputDecoration('Password Baru')),
                  const SizedBox(height: 20),
                  TextField(controller: _confirmController, obscureText: _obscure, decoration: _inputDecoration('Konfirmasi Password')),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleChange,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1ABC75), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Ubah Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}