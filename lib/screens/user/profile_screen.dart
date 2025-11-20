import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../../main.dart'; // Untuk AuthCheck

class ProfileScreen extends StatelessWidget {
  final String role;

  const ProfileScreen({super.key, required this.role});

  void _performLogout(BuildContext context) async {
    await SessionService.clearSession();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthCheck()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Profil Saya",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            // HEADER
            _buildProfileHeader(),
            const SizedBox(height: 30),

            // MENU SETTINGS
            _buildSectionTitle("Pengaturan Akun"),
            Container(
              decoration: _boxDecoration(),
              child: Column(
                children: [
                  _buildMenuItem(Icons.person_outline, "Edit Profil", () {}),
                  _buildDivider(),
                  _buildMenuItem(Icons.notifications_outlined, "Notifikasi", () {}),
                  _buildDivider(),
                  _buildMenuItem(Icons.lock_outline, "Ganti Password", () {}),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MENU LAINNYA
            _buildSectionTitle("Lainnya"),
            Container(
              decoration: _boxDecoration(),
              child: Column(
                children: [
                  _buildMenuItem(Icons.help_outline, "Pusat Bantuan", () {}),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.logout, 
                    "Keluar", 
                    () => _showLogoutDialog(context),
                    isDestructive: true
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            Text("Versi Aplikasi 1.0.0", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: const NetworkImage("https://i.pravatar.cc/300"),
              onBackgroundImageError: (_, __) {}, 
              child: const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF00C853),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        const Text("Nama Pengguna", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: role == 'admin' ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: role == 'admin' ? Colors.red.shade200 : Colors.green.shade200
            ),
          ),
          child: Text(
            role.toUpperCase(),
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold,
              color: role == 'admin' ? Colors.red : Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isDestructive ? Colors.red : Colors.black54, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : Colors.black87),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200, indent: 60);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }
}