import 'package:flutter/material.dart';
import '../../../models/admin_user_model.dart';

class ClientCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onTap;

  const ClientCard({super.key, required this.user, required this.onTap});

  static const Color _kPrimary = Color(0xFF06A900);
  static const Color _kTextPrimary = Color(0xFF111111);
  static const Color _kTextSecondary = Color(0xFF3F3F3F);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: _kPrimary.withValues(alpha:0.12),
                child: const Icon(Icons.person, color: _kPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isEmpty ? "Nama belum diisi" : user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: _kTextSecondary.withValues(alpha:0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _infoChip(
                          Icons.phone,
                          user.phone.isEmpty ? "-" : user.phone,
                        ),
                        _infoChip(
                          Icons.badge_outlined,
                          user.nomorIdentitas.isEmpty
                              ? "-"
                              : user.nomorIdentitas,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _kTextSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _kTextSecondary.withValues(alpha:0.8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: _kTextSecondary.withValues(alpha:0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
