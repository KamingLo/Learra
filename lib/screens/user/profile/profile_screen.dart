import 'package:flutter/material.dart';
import '../../../screens/user/profile/edit_profile_screen.dart';
import '../../../services/session_service.dart';
import '../../../main.dart'; // Untuk AuthCheck

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
    final bool isAdmin = role.toLowerCase() == 'admin';
    final Color accentColor = isAdmin ? const Color(0xFFE53935) : const Color(0xFF2ECC71);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAdmin
                    ? [const Color(0xFFFF9A8B), const Color(0xFFE53935)]
                    : [const Color(0xFFB5FFFC), const Color(0xFF2ECC71)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              children: [
                _buildProfileHeroCard(accentColor, isAdmin),
                const SizedBox(height: 24),
                _buildMenuSection(
                  title: "Pengaturan Akun",
                  subtitle: "Atur preferensi dan keamanan profil Anda",
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: "Edit Profil",
                      subtitle: "Perbarui informasi personal",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.lock_outline_rounded,
                      title: "Ganti Password",
                      subtitle: "Perkuat keamanan akun",
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMenuSection(
                  title: "Lainnya",
                  subtitle: "Bantuan dan tindakan lainnya",
                  children: [
                    _buildMenuItem(
                      icon: Icons.help_center_outlined,
                      title: "Pusat Bantuan",
                      subtitle: "Temukan jawaban dan panduan",
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: "Keluar",
                      subtitle: "Akhiri sesi Anda saat ini",
                      isDestructive: true,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  "Versi Aplikasi 1.0.0",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeroCard(Color accentColor, bool isAdmin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor.withOpacity(0.9), accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Nama Pengguna",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFEFF3F8)),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ProfileMetaItem(
                icon: Icons.mail_outline,
                label: "Email",
                value: "Tersinkron otomatis",
              ),
              _ProfileMetaItem(
                icon: Icons.shield_outlined,
                label: "Keamanan",
                value: "Aktif",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final Color textColor = isDestructive ? Colors.redAccent : Colors.black87;
    final Color iconBg =
        isDestructive ? Colors.red.shade50 : Colors.blueGrey.shade50;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDestructive
                  ? Colors.redAccent.withOpacity(0.2)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: textColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileMetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}