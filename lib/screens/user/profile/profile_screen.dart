import 'package:flutter/material.dart';
import '../../../screens/user/profile/edit_profile_screen.dart';
import '../../../screens/user/bantuan/helpfaq.dart';
import '../../../services/session_service.dart';
import '../../../services/api_service.dart';
import '../../../main.dart'; // Untuk AuthCheck
import '../../../widgets/auth/forgot_password.dart';

class ProfileScreen extends StatefulWidget {
  final String role;

  const ProfileScreen({super.key, required this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Konstanta Warna dipindahkan ke dalam State agar mudah diakses
  static const Color _primaryText = Color(0xFF111111);
  static const Color _secondaryText = Color(0xFF3F3F3F);
  static const Color _surfaceLight = Color(0xFFF7F7F7);
  static const Color _primaryGreen = Color(0xFF06A900);
  static const Color _deepGreen = Color(0xFF024000);

  // 1. Variabel untuk menampung data user
  String _userName = 'Nama Pengguna';
  String _email = '';
  String _pekerjaan = '';

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // 2. Panggil fungsi load saat halaman pertama kali dibuat
    _loadUserData();
  }

  // 3. Fungsi Asynchronous untuk mengambil data profil
  Future<void> _loadUserData() async {
    // Load nama dari session dulu agar cepat tampil
    final name = await SessionService.getCurrentName();
    if (mounted && name != null) {
      setState(() {
        _userName = name;
      });
    }

    // Fetch detail lengkap dari API
    try {
      final response = await _apiService.get('/user/profile');
      if (!mounted) return;

      if (response['user'] != null) {
        final data = response['user'];
        setState(() {
          _userName = data['name'] ?? _userName;
          _email = data['email'] ?? '';
          _pekerjaan = data['pekerjaan'] ?? '';
        });

        // Update session jika nama berubah di server
        if (data['name'] != null) {
          await SessionService.saveName(data['name']);
        }
      }
    } catch (e) {
      // Silent error atau log, biarkan data session yang tampil
      debugPrint("Gagal load profile: $e");
    }
  }

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
    // Perhatikan penggunaan 'widget.role' karena kita ada di dalam State
    final bool isAdmin = widget.role.toLowerCase() == 'admin';
    final Color accentColor = isAdmin ? const Color(0xFFE53935) : _primaryGreen;
    final Color accentSecondary = isAdmin
        ? const Color(0xFFB71C1C)
        : _deepGreen;

    return Scaffold(
      backgroundColor: _surfaceLight,
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(color: _primaryText, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _primaryText,
      ),
      body: Stack(
        children: [
          // Background dengan desain baru
          Stack(
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isAdmin
                        ? [const Color(0xFFFFC1B6), accentColor]
                        : [_primaryGreen, _deepGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
              ),
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 80,
                left: -40,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              children: [
                _buildProfileHeroCard(accentColor, accentSecondary),
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
                        ).then((_) {
                          // Opsional: Reload nama setelah kembali dari edit profile
                          _loadUserData();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.lock_outline_rounded,
                      title: "Ganti Password",
                      subtitle: "Perkuat keamanan akun",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FAQPage()),
                        );
                      },
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
                const SizedBox(height: 24),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.8, // Agar tidak terlalu mencolok
                      child: SizedBox(
                        height: 48, // Ukuran logo proporsional
                        child: Image.asset(
                          'assets/IconApp/LearraFull.png',
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) => const Icon(
                            Icons.verified_user,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "© 2025 Learra. Hak Cipta Dilindungi.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Terdaftar dan diawasi oleh OJK",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 20), // Bottom safe area padding
                    const SizedBox(height: 32),
                    Text(
                      "Versi Aplikasi 1.0.0",
                      style: TextStyle(
                        color: _secondaryText.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeroCard(Color accentColor, Color accentSecondary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                    colors: [accentSecondary, accentColor],
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
                    Text(
                      _userName,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _primaryText,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_email.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: _secondaryText.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _email,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: _secondaryText.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (_pekerjaan.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 14,
                            color: _secondaryText.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _pekerjaan,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: _secondaryText.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (_email.isEmpty && _pekerjaan.isEmpty)
                      const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        widget.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
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
            color: Colors.black.withValues(alpha: 0.05),
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
              color: _primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: _secondaryText.withValues(alpha: 0.7),
              fontSize: 13,
            ),
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
    final Color textColor = isDestructive ? Colors.redAccent : _deepGreen;
    final Color iconBg = isDestructive ? Colors.red.shade50 : _surfaceLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: isDestructive
            ? Colors.redAccent.withValues(alpha: 0.1)
            : _primaryGreen.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDestructive
                  ? Colors.redAccent.withValues(alpha: 0.2)
                  : _surfaceLight,
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
                          color: _secondaryText.withValues(alpha: 0.7),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: _secondaryText.withValues(alpha: 0.6),
                size: 20,
              ),
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
