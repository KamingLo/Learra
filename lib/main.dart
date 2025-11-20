 // 1. Wajib import ini untuk HttpOverrides
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/users_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      home: Scaffold(
        appBar: AppBar(title: Text('Halo Dunia')),
        body: Center(child: Text('Selamat datang di Flutte r!')),
=======
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
>>>>>>> origin/review
      ),
      home: const UsersScreen(), 
    );
  }
}