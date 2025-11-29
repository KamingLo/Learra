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

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}