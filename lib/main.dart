import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // Pastikan import ini ada
import 'services/session_service.dart';
import 'widgets/main_navbar.dart';
import 'screens/auth/login_screen.dart';

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
    // Definisi Warna Modern
    const Color modernGreen = Color(0xFF00C853);
    const Color offWhite = Color(0xFFF4F7F6);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learra',
      
      theme: ThemeData(
        // 1. GUNAKAN OPEN SANS UNTUK TEXT GLOBAL
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),

        // Skema Warna
        colorScheme: ColorScheme.fromSeed(
          seedColor: modernGreen,
          primary: modernGreen,
          surface: offWhite,
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: offWhite,
        useMaterial3: true,

        // 2. GUNAKAN OPEN SANS UNTUK APP BAR JUGA
        appBarTheme: AppBarTheme(
          backgroundColor: offWhite,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          
          // Judul AppBar wajib diset manual agar berubah
          titleTextStyle: GoogleFonts.openSans( 
            color: Colors.black87,
            fontWeight: FontWeight.w700, // Bold agar tegas
            fontSize: 22,
          ),
        ),
      ),
      
      home: const AuthCheck(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

// ... (Bagian AuthCheck ke bawah tetap sama, tidak perlu diubah)
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
    String role = await SessionService.getCurrentRole();
    if (!mounted) return;
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => MainNavbar(role: role))
    );
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
  );
}