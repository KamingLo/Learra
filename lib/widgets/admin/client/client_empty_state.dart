import 'package:flutter/material.dart';

class ClientEmptyState extends StatelessWidget {
  const ClientEmptyState({super.key});

  static const Color _kPrimary = Color(0xFF06A900);
  static const Color _kTextPrimary = Color(0xFF111111);
  static const Color _kTextSecondary = Color(0xFF3F3F3F);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha:0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  size: 60,
                  color: _kPrimary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Belum ada data pengguna",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Gunakan form registrasi atau impor data untuk menambahkan pengguna.",
                textAlign: TextAlign.center,
                style: TextStyle(color: _kTextSecondary.withValues(alpha:0.7)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
