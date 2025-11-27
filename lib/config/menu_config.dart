import 'package:flutter/material.dart';
import 'package:learra/screens/admin/polis/admin_polis_screen.dart';
import 'package:learra/screens/user/polis/user_polis_screen.dart';

// --- IMPORT SCREEN SESUAI ROLE ---
import '../screens/admin/product/product_screen.dart';  // Screen Admin (CRUD)
import '../screens/user/product/product_screen.dart';   // Screen User (Belanja)
import '../screens/user/profile_screen.dart';   // Profile (Logout)
import 'package:learra/screens/user/home/home_screen.dart';

class NavItem {
  final String label;
  final IconData icon;
  final Widget screen;

  NavItem({required this.label, required this.icon, required this.screen});
}

class MenuConfig {
  static List<NavItem> getMenus(String role) {
    // --- 1. MENU ADMIN ---
    if (role == 'admin') {
      return [
        NavItem(
          label: "Produk", 
          icon: Icons.inventory_2_rounded,
          // Arahkan ke screen Admin yang punya fitur CRUD
          screen: const AdminProductScreen(), 
        ),
        NavItem(
          label: "Polis", 
          icon: Icons.my_library_books_rounded,
          // Arahkan ke screen Admin yang punya fitur CRUD
          screen: const AdminPolicyScreen(), 
        ),
        NavItem(
          label: "Akun",
          icon: Icons.person_rounded,
          screen: const ProfileScreen(role: 'admin'),
        ),
      ];
    } 
    
    // --- 2. MENU USER ---
    else if (role == 'user') {
      return [
        NavItem(
          label: "Home",
          icon: Icons.home_rounded,
          screen: const UserHomeScreen(role: "user") , // Placeholder
        ),
        NavItem(
          label: "Belanja",
          icon: Icons.shopping_cart_rounded,
          // Arahkan ke screen User yang punya fitur Beli
          screen: const UserProductScreen(), 
        ),
        NavItem(
          label: "Polis",
          icon: Icons.my_library_books_rounded,
          // Arahkan ke screen User yang punya fitur Beli
          screen: const PolicyScreen(), 
        ),
        NavItem(
          label: "Profil",
          icon: Icons.person_rounded,
          screen: const ProfileScreen(role: 'user'),
        ),
      ];
    } 
    
    // --- 3. MENU GUEST ---
    else {
      return [
        NavItem(
          label: "Home",
          icon: Icons.home_outlined,
          screen: const  UserHomeScreen(role: "public"), // Placeholder
        ),
        NavItem(
          label: "Produk",
          icon: Icons.grid_view_rounded,
          // Arahkan ke screen Public yang hanya Preview
          screen: const UserProductScreen(), 
        ),
        NavItem(
          label: "Masuk",
          icon: Icons.login_rounded,
          screen: const SizedBox(), // Screen dummy, karena di-intercept oleh MainNavbar
        ),
      ];
    }
  }
}