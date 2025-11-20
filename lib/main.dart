import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'services/session_service.dart';
import 'widgets/main_navbar.dart';

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
      title: 'Multi-Role App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthCheck(),
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

// --- 2. Halaman Login (Simulasi) ---
// Nanti file ini dipindah ke screens/auth/login_screen.dart
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _performLogin(BuildContext context, String role) async {
    // CERITANYA: Request ke API berhasil, dapet Token "abc123xyz"
    String fakeToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."; 
    
    // 1. Simpan Role & Token
    await SessionService.saveSession(role, fakeToken);

    if (!context.mounted) return;

    // 2. Reload Aplikasi ke Navbar dengan Role Baru
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainNavbar(role: role)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Pilih Akun Simulasi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            
            _loginButton(context, 'User Biasa', 'user', Colors.blue),
            const SizedBox(height: 15),
            _loginButton(context, 'Admin Toko', 'admin', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context, String label, String role, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _performLogin(context, role),
      icon: const Icon(Icons.login, color: Colors.white),
      label: Text("Masuk sebagai $label", style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
    );
  }
}