import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../../main.dart'; // Diperlukan untuk navigasi ke AuthCheck

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _performLogout(BuildContext context) async {
    // 1. Hapus Session
    await SessionService.clearSession();

    if (!context.mounted) return;

    // 2. Reload Aplikasi ke AuthCheck (yang nanti mengarah ke MainNavbar role 'guest')
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthCheck()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Pengguna"),
        backgroundColor: Colors.grey.shade100,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_pin, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 10),
              // Menampilkan Role saat ini
              FutureBuilder<String>(
                future: SessionService.getCurrentRole(),
                builder: (context, snapshot) {
                  return Text(
                    "Anda Login Sebagai: ${snapshot.data?.toUpperCase() ?? 'GUEST'}", 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  );
                },
              ),
              const SizedBox(height: 50),
              
              // Tombol Logout
              ElevatedButton.icon(
                onPressed: () => _performLogout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("LOGOUT", style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}