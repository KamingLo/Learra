// main.dart
import 'package:flutter/material.dart';
import 'login/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF06A900),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      home: const LoginPage(),
    );
  }
}