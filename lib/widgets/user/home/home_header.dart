import 'package:flutter/material.dart';
import '../../../screens/auth/auth_screen.dart'; 

class HomeHeader extends StatelessWidget {
  final String? userName;
  final bool isLoggedIn;
  final Color primaryColor;
  final VoidCallback? onToProfile; 

  const HomeHeader({
    super.key,
    required this.userName,
    required this.isLoggedIn,
    this.primaryColor = const Color(0xFF0FA958),
    this.onToProfile,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = userName ?? "User";

    return GestureDetector(
      onTap: () {
        if (isLoggedIn) {
          if (onToProfile != null) {
            onToProfile!();
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.green.shade800,
              Colors.green.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isLoggedIn ? Icons.person_rounded : Icons.person_outline_rounded,
                color: primaryColor,
                size: 36,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoggedIn ? "Halo, $displayName!" : "Selamat Datang!",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLoggedIn
                        ? "Semoga harimu menyenangkan"
                        : "Klik disini untuk masuk",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade300),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}