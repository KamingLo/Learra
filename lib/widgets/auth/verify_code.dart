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
  String? _errorMessage;
  static const Color _fieldFillColor = Color(0xFFF8F8FA);

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _fieldFillColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFDCDDE4), width: 1.4)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF1ABC75), width: 1.6)),
    );
  }

  Future<void> _handleVerify() async {
    if (_codeController.text.isEmpty) {
      setState(() => _errorMessage = "Kode tidak boleh kosong");
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // TODO: API CALL
      await Future.delayed(const Duration(seconds: 1)); 

      if (!mounted) return;
      
      // Ke Halaman Ubah Password (Bawa Email & Code)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasswordScreen(
            email: widget.email,
            code: _codeController.text,
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
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 20), spreadRadius: -10)]),
              child: Column(
                children: [
                  Text('Verifikasi Kode', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text('Kode OTP dikirim ke:\n${widget.email}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 32),
                  if (_errorMessage != null) Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  TextField(controller: _codeController, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, letterSpacing: 2), decoration: _inputDecoration('Kode')),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleVerify,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1ABC75), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Verifikasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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