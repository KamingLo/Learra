import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../main.dart';

class LoginForm extends StatefulWidget {
  final bool isLoginMode; // true = login, false = register
  const LoginForm({super.key, required this.isLoginMode});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.post('/auth/login', body: {
        'email': _loginEmailController.text.trim(),
        'password': _loginPasswordController.text,
      });

      if (response['error'] != null) {
        throw Exception(response['message'] ?? 'Login gagal');
      }

      final token = response['token'] as String?;
      final role = response['user']?['role'] as String? ?? 'guest';

      if (token != null && token.isNotEmpty) {
        await SessionService.saveSession(role, token);

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthCheck()),
          (route) => false,
        );
      } else {
        throw Exception("Token tidak valid dari server");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage != null) ...[
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
        ],

        // === LOGIN FORM ===
        TextField(
          controller: _loginEmailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _loginPasswordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Login'),
        ),]
    );
  }
}
