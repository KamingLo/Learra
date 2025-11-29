import 'package:flutter/material.dart';
import '../../../models/admin_user_model.dart';

class ClientDetailSheet extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClientDetailSheet({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color _kPrimary = Color(0xFF06A900);
  static const Color _kTextPrimary = Color(0xFF111111);
  static const Color _kTextSecondary = Color(0xFF3F3F3F);
  static const Color _kBackground = Color(0xFFF4F7F6);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.85,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: _kPrimary.withValues(alpha:0.15),
                  child: const Icon(Icons.person, color: _kPrimary),
                ),
                title: Text(
                  user.name.isEmpty ? "Nama belum diisi" : user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
                subtitle: Text(
                  user.email,
                  style: TextStyle(color: _kTextSecondary.withValues(alpha:0.8)),
                ),
                trailing: Chip(
                  backgroundColor: _kPrimary.withValues(alpha:0.1),
                  label: Text(
                    user.role.toUpperCase(),
                    style: const TextStyle(
                      color: _kPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _detailRow("Nomor Identitas", user.nomorIdentitas),
              _detailRow("No. Telepon", user.phone),
              _detailRow("Alamat", user.address),
              _detailRow("Pekerjaan", user.pekerjaan),
              _detailRow("Rentang Gaji", user.rentangGaji),
              _detailRow("Tanggal Lahir", user.birthDate),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text(
                    "Edit Data Pengguna",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Colors.redAccent.withValues(alpha:0.2),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(
                    "Hapus Pengguna",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _kTextSecondary.withValues(alpha:0.7),
              fontSize: 12.5,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _kBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(
                color: _kTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
