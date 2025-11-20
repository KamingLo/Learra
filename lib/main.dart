import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'services/session_service.dart';
import 'widgets/main_navbar.dart';
import 'screens/auth/login_screen.dart'; // Import untuk rute opsional

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Env not found");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learra',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthCheck(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

// --- 1. Auth Check (Pintu Gerbang) ---
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initialize();
  }

  void _initialize() async {
    // Ambil role dari memori (Kalau kosong otomatis return 'guest')
    String role = await SessionService.getCurrentRole();
    
    if (!mounted) return;
    
    // Langsung arahkan ke Navbar dengan role yang didapat
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => MainNavbar(role: role))
    );
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}