import 'package:flutter/material.dart';
import 'package:learra/screens/admin/polis/admin_polis_screen.dart';
import 'package:learra/screens/user/polis/user_polis_screen.dart';
import '../screens/admin/product/product_screen.dart';
import '../screens/admin/client/client_screen.dart'; 
import '../screens/user/product/product_screen.dart';
import '../screens/user/profile/profile_screen.dart';
import 'package:learra/screens/user/home/home_screen.dart';
import '../screens/user/claim/claim_menu.dart';
import 'package:learra/screens/admin/payment/ad_payment_menu.dart';
import 'package:learra/screens/admin/claim/ad_claim_menu.dart';

class NavItem {
  final String label;
  final IconData icon;
  final Widget screen;

  NavItem({required this.label, required this.icon, required this.screen});
}

class MenuConfig {
  static List<NavItem> getMenus(String role) {
    if (role == 'admin') {
      return [
        NavItem(
          label: "Client",
          icon: Icons.diversity_3_rounded,
          screen: const ClientScreen(),
        ),
        NavItem(
          label: "Produk",
          icon: Icons.inventory_2_rounded,
          screen: const AdminProductScreen(),
        ),
        NavItem(
          label: "Polis",
          icon: Icons.my_library_books_rounded,
          screen: const AdminPolicyScreen(),
        ),
        NavItem(
          label: "Payment",
          icon: Icons.payment,
          screen: const AdminPembayaranScreen(),
        ),
        NavItem(
          label: "Klaim",
          icon: Icons.receipt_long,
          screen: const AdminKlaimScreen(),
        ),
        NavItem(
          label: "Akun",
          icon: Icons.person_rounded,
          screen: const ProfileScreen(role: 'admin'),
        ),
      ];
    }
    else if (role == 'user') {
      return [
        NavItem(
          label: "Home",
          icon: Icons.home_rounded,
          screen: const UserHomeScreen(role: "user"),
        ),
        NavItem(
          label: "Belanja",
          icon: Icons.shopping_cart_rounded,
          screen: const UserProductScreen(),
        ),
        NavItem(
          label: "Polis",
          icon: Icons.my_library_books_rounded,
          screen: const PolicyScreen(),
        ),
        NavItem(
          label: "Klaim",
          icon: Icons.assignment_rounded,
          screen: const KlaimSayaScreen(),
        ),
        NavItem(
          label: "Profil",
          icon: Icons.person_rounded,
          screen: const ProfileScreen(role: 'user'),
        ),
      ];
    }
    else {
      return [
        NavItem(
          label: "Home",
          icon: Icons.home_outlined,
          screen: const UserHomeScreen(role: "public"),
        ),
        NavItem(
          label: "Produk",
          icon: Icons.grid_view_rounded,
          screen: const UserProductScreen(),
        ),
        NavItem(
          label: "Masuk",
          icon: Icons.login_rounded,
          screen:
              const SizedBox(),
        ),
      ];
    }
  }
}
