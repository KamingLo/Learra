import 'package:flutter/material.dart';
import '../../widgets/auth/login_form.dart';
import '../../widgets/auth/register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginMode = true;

  void _toggleAuthMode() {
    setState(() => isLoginMode = !isLoginMode);
  }

 // File: auth_screen.dart

@override
Widget build(BuildContext context) {
  return Scaffold(
    // AppBar transparan (opsional)
    appBar: AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 0,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    // Gunakan LayoutBuilder untuk mendapatkan tinggi layar
    body: LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          // ConstrainedBox memaksa konten minimal setinggi layar
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            // IntrinsicHeight membantu menjaga layout tetap rapi
            child: IntrinsicHeight(
              child: Center( // Center ini yang membuat Vertikal & Horizontal
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: isLoginMode
                      ? LoginForm(
                          isLoginMode: true,
                          onSwitchToRegister: _toggleAuthMode,
                        )
                      : RegisterForm(
                          onSwitchToLogin: _toggleAuthMode,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
}