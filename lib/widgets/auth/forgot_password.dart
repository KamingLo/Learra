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

  Future<void> _handleSendCode() async {
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = "Email tidak boleh kosong");
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // TODO: API CALL
      // await _apiService.post('/auth/forgot-password', body: {'email': _emailController.text});
      await Future.delayed(const Duration(seconds: 1)); 

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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 20), spreadRadius: -10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lupa Password', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('Masukkan email Anda yang terdaftar.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 32),
                  if (_errorMessage != null) Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  TextField(controller: _emailController, decoration: _inputDecoration('Email')),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSendCode,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1ABC75), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Kirim Kode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  InkWell(onTap: () => Navigator.pop(context), child: const Text("Kembali ke Login", style: TextStyle(fontWeight: FontWeight.bold)))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}