import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../widgets/main_navbar.dart'; 
// Impor screens dari lokasi baru
import '../screens/auth/login_screen.dart'; 
import '../screens/user/profile_screen.dart';

// Model Menu
class NavItem {
  final String label;
  final IconData icon;
  final Widget screen; 
  NavItem({required this.label, required this.icon, required this.screen});
}

// --- PLACEHOLDER SCREENS (Nanti diganti dengan file asli di folder screens/) ---
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final Color color;
  const PlaceholderScreen(this.title, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    color: color.withOpacity(0.1),
    child: Center(child: Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color))),
  );
}
// -----------------------------------------------------------------------------

class MenuConfig {
  // Daftar "Gudang" Semua Menu
  static final Map<String, NavItem> _allMenus = {
    // Public Screens
    'home': NavItem(label: 'Home', icon: Icons.home, screen: const PlaceholderScreen('Home Page', Colors.blue)),
    'produk': NavItem(label: 'Produk', icon: Icons.shopping_bag, screen: const PlaceholderScreen('Daftar Produk', Colors.orange)),
    
    // Restricted Screens (User/Admin)
    'klaim': NavItem(label: 'Klaim', icon: Icons.assignment_turned_in, screen: const PlaceholderScreen('Klaim Asuransi', Colors.red)),
    'pembayaran': NavItem(label: 'Bayar', icon: Icons.payment, screen: const PlaceholderScreen('Pembayaran', Colors.green)),
    
    // Profile (Isinya beda antara Guest vs User)
    'profile': NavItem(label: 'Profil', icon: Icons.person, screen: const ProfileScreen()), // <-- Diarahkan ke ProfileScreen
    'login_nav': NavItem(label: 'Masuk', icon: Icons.login, screen: const LoginScreen()), // <-- Diarahkan ke LoginScreen
  };

  // LOGIC UTAMA: Menentukan List Menu berdasarkan Role
  static List<NavItem> getMenus(String role) {
    List<String> keys = [];

    switch (role) {
      case 'admin':
        // Admin: Full Access
        keys = ['home', 'produk', 'klaim', 'pembayaran', 'profile'];
        break;

      case 'user':
        // User: Full Access
        keys = ['home', 'produk', 'klaim', 'pembayaran', 'profile'];
        break;

      case 'guest':
      default:
        // Guest: Terbatas (Home, Produk, dan menu Login/Profile)
        keys = ['home', 'produk', 'login_nav']; 
        break;
    }

    return keys.map((k) => _allMenus[k]!).toList();
  }
}